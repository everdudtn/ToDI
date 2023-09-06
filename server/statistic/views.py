from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import datetime
from .models import Calendar
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from django.http import HttpRequest
from .models import Users
from django.http import JsonResponse
from dateutil.relativedelta import relativedelta


@api_view(['GET'])
def statistics(request, nickname):
    total_tasks = Calendar.objects.filter(nickname=nickname).count()
    completed_tasks = Calendar.objects.filter(nickname=nickname, checks=True).count()
    own_completion_rate =0.0
    own_completion_rate = (completed_tasks / total_tasks) * 100 if total_tasks > 0 else 0

    friends_completion_rate = []
    friends = Users.objects.exclude(id=request.user.id)
    
    for friend in friends:
        total_friend_tasks = Calendar.objects.filter(nickname=friend.nickname).count()
        completed_friend_tasks = Calendar.objects.filter(nickname=friend.nickname, checks=True).count()
        completion_rate = (completed_friend_tasks / total_friend_tasks) * 100 if total_friend_tasks > 0 else 0
        friend_data = {
            'username': friend.nickname,
            'completion_rate': completion_rate,
        }
        friends_completion_rate.append(friend_data)

    # 친구들을 달성률 기준으로 내림차순 정렬합니다.
    friends_completion_rate.sort(key=lambda x: x['completion_rate'], reverse=True)

    own_rank = None
    rank_counter = 1

    for rank, friend in enumerate(friends_completion_rate, start=1):
        if friend['username'] == nickname:
            own_rank = rank_counter
            friend['rank'] = rank_counter
            break # 자기 자신을 찾았으면 반복문 종료
        else:
            friend['rank'] = rank_counter
            rank_counter += 1
    
     # 상위 3명의 친구만 남깁니다.
    top_friends = friends_completion_rate[:3]

    top_user_data_list=[]
    for i in range(len(top_friends)):
        user_data={
            'username':top_friends[i]['username'],
            'completion_rate':top_friends[i]['completion_rate'],
            'rank':i+1,
        }
        top_user_data_list.append(user_data)

    context ={
        'own_username': nickname,
        'own_completion_rate': own_completion_rate,
        'own_rank': own_rank,
        'top_users' : top_user_data_list,
    }

    return Response(context)


def update_user_statistic_job():
    now = datetime.now()
    # current_month = now.strftime('%Y-%m')
    
    # 사용자 정보와 이전 월 정보 가져오기
    previous_month = (now - relativedelta(months=1)).strftime('%Y-%m')
    users = Users.objects.all()
    
    for user in users:
        data = {
            'nickname': user.nickname,
            'current_month': previous_month,  # 이전 월로 변경
        }
        
        # update_user_statistic 함수 호출하여 데이터 전달
        update_user_statistic(data)


# 스케줄러 설정
scheduler = BackgroundScheduler()
scheduler.add_job(update_user_statistic_job, CronTrigger(day='3', hour=21, minute=49))
# 스케줄러 시작
scheduler.start()

from datetime import datetime, timedelta

def update_user_statistic(data):
    print("시발")
    user_nickname = data.get('nickname')
    
    # 현재 연도와 이전 월 가져오기
    current_year = datetime.now().year
    current_month = datetime.now().month
    
    if current_month == 1:
        previous_year = current_year - 1
        previous_month = 12
    else:
        previous_year = current_year
        previous_month = current_month - 1
    
    start_date = datetime(previous_year, previous_month, 1)
    
    if previous_month == 12:
        end_date = datetime(previous_year + 1, 1, 1) - timedelta(days=1)
    else:
        end_date = datetime(previous_year, previous_month + 1, 1) - timedelta(days=1)

    tasks= Calendar.objects.filter(nickname=user_nickname,
                                     start_date__gte=start_date,
                                     end_date__lte=end_date)

    completed_tasks= tasks.filter(checks=True).count()
    total_tasks= tasks.count()

    user_completion_rate= (completed_tasks / total_tasks) *100 if total_tasks >0 else 0

   # 업데이트할 유저 가져오기
    user, created= Users.objects.get_or_create(nickname="user_nickname")

   # 유저의 기록 업데이트
    user.accomplishment_rate= user_completion_rate
    user.save()

    return Response({"message": "User statistics updated successfully."}, status=status.HTTP_200_OK)



# views.py

from django.contrib.auth import login
import logging
from django.contrib.auth.hashers import check_password
from .models import AuthUser, Friendrequest, Users, Admins, BoardType, Board, Calendar, Diary
from .sms import send_sms
import random
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.tokens import TokenError, RefreshToken
from .serializers import UsersSerializer, FriendrequestSerializer, AuthUserSerializer, AdminsSerializer, BoardTypeSerializer, BoardSerializer, CalendarSerializer, DiarySerializer
from django.db.models import Q
import requests
import json
from urllib.parse import unquote


def verify_token(access_token):
    try:
        refresh = RefreshToken(access_token)
        user = refresh.user
        return user
    except TokenError:
        return None

@api_view(['POST'])
def verify_access_token(request):
    if request.method == 'POST':
        access_token = request.data.get('access_token')

        user = verify_token(access_token)
        if user:
            return Response({'user': user.username, 'message': '유효한 토큰입니다.'}, status=status.HTTP_200_OK)
        else:
            return Response({'message': '유효하지 않은 토큰입니다.'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
def refresh_access_token(request):
    if request.method == 'POST':
        refresh_token = request.data.get('refresh_token')

        try:
            refresh = RefreshToken(refresh_token)
            access_token = str(refresh.access_token)
            user = refresh.user

            return Response({'access_token': access_token, 'user': user.username, 'message': '새로운 access 토큰이 발급되었습니다.'}, status=status.HTTP_200_OK)
        except TokenError as e:
            return Response({'message': '유효하지 않은 refresh 토큰입니다.'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
def signup(request):
    if request.method == 'POST':
        serializer = AuthUserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()

            # 사용자가 처음 가입하는 경우에만 인증 코드와 문자를 전송합니다.
            if not user.verification_code:
                verification_code = str(random.randint(100000, 999999))
                user.verification_code = verification_code
                user.save()

                sms_content = f"인증 코드: {verification_code}"
                send_result = send_sms(user.phone_number, sms_content)

                if send_result:  # 인증 문자 전송에 성공한 경우에만 응답을 반환합니다.
                    refresh = RefreshToken.for_user(user)
                    access_token = str(refresh.access_token)
                    return Response({'access_token': access_token, 'username':user.username, 'message': '회원 가입이 완료되었습니다.'}, status=status.HTTP_201_CREATED)
                else:
                    return Response({'message': '인증 문자 전송에 실패했습니다.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)
            
            return Response({'access_token': access_token, 'username':user.username, 'message': '회원 가입이 완료되었습니다.'}, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def login_with_verification(request):
    if request.method == 'POST':
        phone_number = request.data.get('phone_number')
        verification_code = request.data.get('verification_code')
        
        try:
            user = AuthUser.objects.get(phone_number=phone_number)
            print(user.verification_code)
            if user.verification_code is None:
                return Response({'message': '인증 번호가 설정되지 않았습니다.'}, status=status.HTTP_400_BAD_REQUEST)

            if user.verification_code != verification_code:
                print(f"Client verification_code: {verification_code}")
                print(f"User verification_code: {user.verification_code}")
                return Response({'message': '인증 번호가 올바르지 않습니다.1'}, status=status.HTTP_400_BAD_REQUEST)
            
            # 인증 번호가 올바른 경우, 사용자를 로그인 처리하는 코드 추가
            login(request, user)

            if user is not None:
                refresh = RefreshToken.for_user(user)
                access_token = str(refresh.access_token)
                return Response({'username': user.username, 'access_token': access_token, 'message': '로그인이 완료되었습니다.'}, status=status.HTTP_200_OK)
            else:
                return Response({'message': '인증 번호가 올바르지 않습니다.2'}, status=status.HTTP_400_BAD_REQUEST) 

        except AuthUser.DoesNotExist:
            return Response({'message': '핸드폰 번호가 올바르지 않습니다.'}, status=status.HTTP_400_BAD_REQUEST)
        
@api_view(['POST'])
def user_login(request):
    if request.method == 'POST':
        username = request.data.get('username')
        password = request.data.get('password')
        
        user = AuthUser.objects.filter(username=username).first()
        if user and check_password(password, user.password):
            # 인증 성공
            login(request, user)
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)
            refresh_token = str(refresh)

            # 인증 코드 초기화
            user.verification_code = None
            user.save()

            # Users에서 nickname 가져오기
            try:
                user_info = Users.objects.get(username=user.username)
                nickname = user_info.nickname
            except Users.DoesNotExist:
                nickname = None

            return Response(
                {
                    'status': 'success',
                    'username': user.username,
                    'nickname': nickname,
                    'access_token': access_token,
                    'refresh_token': refresh_token,
                    'message': '로그인이 완료되었습니다.'
                },
                status=status.HTTP_200_OK
            )
        else:
            # 인증 실패
            logger = logging.getLogger(__name__)
            logger.error(f'Failed login attempt for username: {username}')
            return Response(
                {
                    'status': 'fail',
                    'message': '로그인에 실패했습니다.'
                },
                status=status.HTTP_401_UNAUTHORIZED
            )

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def users_view(request):
    if request.method == 'GET':
        username = request.query_params.get('username')
        nickname = request.query_params.get('nickname')
        
        queryset = Users.objects.all()
        
        if username:
            queryset = queryset.filter(username=username)
        if nickname:
            queryset = queryset.get(nickname=nickname)  # get() 메서드로 단일 객체 가져오기
        
        serializer = UsersSerializer(queryset, many=False if nickname else True)  # 필요한 경우에만 many=False로 설정
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = UsersSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'PUT':
        try:
            username = request.data.get('username')
            if not username:
                return Response({'error': 'username is required for updating'},
                                status=status.HTTP_400_BAD_REQUEST)
            
            user = Users.objects.get(username=username)
            serializer = UsersSerializer(user, data=request.data)
            
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Users.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

    elif request.method == 'DELETE':
        try:
            nickname = request.data.get('nickname')
            if not nickname:
                return Response({'error': 'Nickname is required for deleting'},
                                status=status.HTTP_400_BAD_REQUEST)
            
            user = Users.objects.get(nickname=nickname)
            user.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Users.DoesNotExist:
            return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
def get_user_by_username(request):
    nickname = request.query_params.get('nickname')  # 쿼리 파라미터에서 nickname을 가져온다
    
    if nickname:
        decoded_nickname = unquote(nickname)
        
        queryset = Users.objects.filter(nickname__contains=decoded_nickname)
        serializer = UsersSerializer(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    else:
        return Response({"error": "Nickname parameter is missing."}, status=status.HTTP_400_BAD_REQUEST)

    
# 친구 요청 전송 API
@api_view(['POST'])
def send_friend(request):
    sender_username = request.data.get('sender_username')
    receiver_username = request.data.get('receiver_username')

    if not sender_username or not receiver_username:
        return Response({"error": "Both sender_username and receiver_username fields are required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        sender = Users.objects.get(username=sender_username)
        receiver = Users.objects.get(username=receiver_username)
    except Users.DoesNotExist:
        return Response({"error": "Sender or receiver user does not exist."}, status=status.HTTP_404_NOT_FOUND)

    if sender == receiver:
        return Response({"error": "You cannot send a friend request to yourself."}, status=status.HTTP_400_BAD_REQUEST)

    if Friendrequest.objects.filter(sender=sender, receiver=receiver).exists() or Friendrequest.objects.filter(sender=receiver, receiver=sender).exists():
        return Response({"error": "Friend request already exists."}, status=status.HTTP_400_BAD_REQUEST)

    friend_request = Friendrequest(sender=sender, receiver=receiver, status='pending')
    friend_request.save()

    serializer = FriendrequestSerializer(friend_request)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


# 받은 친구 요청 목록 조회 API
@api_view(['GET'])
def get_pending_friends(request, username):  # username 인자 추가
    try:
        user = Users.objects.get(username=username)  # username으로 사용자 검색
        pending_friend_requests = user.received_friend_requests.filter(status='pending')
    except Users.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

    serializer = FriendrequestSerializer(pending_friend_requests, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

# 친구 list
@api_view(['GET'])
def get_accepted_friends(request, username):
    try:
        user = Users.objects.get(username=username)
        accepted_friend_requests = Friendrequest.objects.filter(Q(sender=user, status='accepted') | Q(receiver=user, status='accepted'))
    except Users.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

    # 상대방의 정보만 추출하여 리스트로 반환
    friends_list = []
    for friend_request in accepted_friend_requests:
        friend = friend_request.sender if friend_request.receiver == user else friend_request.receiver
        serializer = UsersSerializer(friend)  # 사용자 객체를 Serializer를 사용하여 직렬화
        friends_list.append(serializer.data)

    return Response(friends_list, status=status.HTTP_200_OK)


# 친구 요청 수락 API
@api_view(['PUT'])
def friend_accept(request, username):  # username 인자 추가
    sender_username = request.data.get('sender_username')
    if not sender_username:
        return Response({"error": "Sender username is required."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        sender = Users.objects.get(username=sender_username)
        receiver = Users.objects.get(username=username)  # Use the passed username here
        friend_request = Friendrequest.objects.get(sender=sender, receiver=receiver, status='pending')
    except Users.DoesNotExist:
        return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)
    except Friendrequest.DoesNotExist:
        return Response({"error": "Pending friend request not found."}, status=status.HTTP_404_NOT_FOUND)

    friend_request.status = 'accepted'
    friend_request.save()

    return Response({"message": "Friend request accepted successfully."}, status=status.HTTP_200_OK)
  

@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def admins_view(request):
    if request.method == 'GET':
        admin_name = request.query_params.get('admin_name')

        # 기본 쿼리 셋 생성
        queryset = Admins.objects.all()

        if admin_name:
            queryset = queryset.filter(admin_name=admin_name)

        serializer = AdminsSerializer(queryset, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = AdminsSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        admin_name = request.query_params.get('admin_name')
        try:
            data = Admins.objects.get(admin_name=admin_name)
            serializer = AdminsSerializer(data, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Admins.DoesNotExist:
            return Response({'error': 'Admins not found'}, status=status.HTTP_404_NOT_FOUND)
    
    elif request.method == 'DELETE':
        admin_name = request.query_params.get('admin_name')
        try:
            data = Admins.objects.get(admin_name=admin_name)
            data.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Admins.DoesNotExist:
            return Response({'error': 'BoardType not found'}, status=status.HTTP_404_NOT_FOUND)
    
# BoardType 수정
@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def board_type_view(request):
    if request.method == 'GET':
        board_type_id = request.query_params.get('board_type_id')

        # 기본 쿼리 셋 생성
        queryset = BoardType.objects.all()

        if board_type_id:
            queryset = queryset.filter(board_type_id=board_type_id)

        serializer = BoardTypeSerializer(queryset, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = BoardTypeSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        board_type_id = request.query_params.get('board_type_id')
        try:
            data = BoardType.objects.get(board_type_id=board_type_id)
            serializer = BoardTypeSerializer(data, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except BoardType.DoesNotExist:
            return Response({'error': 'BoardType not found'}, status=status.HTTP_404_NOT_FOUND)
    
    elif request.method == 'DELETE':
        board_type_id = request.query_params.get('board_type_id')
        try:
            data = BoardType.objects.get(board_type_id=board_type_id)
            data.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except BoardType.DoesNotExist:
            return Response({'error': 'BoardType not found'}, status=status.HTTP_404_NOT_FOUND)

# Board 수정
@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def board_view(request):
    if request.method == 'GET':
        title = request.query_params.get('title')

        # 기본 쿼리 셋 생성
        queryset = Board.objects.all()

        if title:
            queryset = queryset.filter(title=title)  # title 필터 추가

        serializer = BoardSerializer(queryset, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = BoardSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        board_id = request.query_params.get('board_id')
        try:
            data = Board.objects.get(board_id=board_id)
            serializer = BoardSerializer(data, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Board.DoesNotExist:
            return Response({'error': 'Board not found'}, status=status.HTTP_404_NOT_FOUND)
    
    elif request.method == 'DELETE':
        board_id = request.query_params.get('board_id')
        try:
            data = Board.objects.get(board_id=board_id)
            data.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Board.DoesNotExist:
            return Response({'error': 'Board not found'}, status=status.HTTP_404_NOT_FOUND)
    
# Calendar
@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def calendar_view(request):
    if request.method == 'GET':
        nickname = request.query_params.get('nickname')

        # 기본 쿼리 셋 생성
        queryset = Calendar.objects.all()

        if nickname:
            queryset = queryset.filter(nickname=nickname)  # nickname 필터 추가

        serializer = CalendarSerializer(queryset, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = CalendarSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        calendar_id = request.query_params.get('calendar_id')
        try:
            data = Calendar.objects.get(calendar_id=calendar_id)
            serializer = CalendarSerializer(data, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Calendar.DoesNotExist:
            return Response({'error': 'Calendar not found'}, status=status.HTTP_404_NOT_FOUND)
    
    elif request.method == 'DELETE':
        calendar_id = request.query_params.get('calendar_id')
        try:
            data = Calendar.objects.get(calendar_id=calendar_id)
            data.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Calendar.DoesNotExist:
            return Response({'error': 'Calendar not found'}, status=status.HTTP_404_NOT_FOUND)

# Diary
@api_view(['GET', 'POST', 'PUT', 'DELETE'])
def diary_view(request):
    if request.method == 'GET':
        nickname = request.query_params.get('nickname')

        # 기본 쿼리 셋 생성
        queryset = Diary.objects.all()

        if nickname:
            queryset = queryset.filter(nickname=nickname)  # nickname 필터 추가

        serializer = DiarySerializer(queryset, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = DiarySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'PUT':
        diary_id = request.query_params.get('diary_id')  # URL 파라미터에서 diary_id 값을 가져옴
        try:
            data = Diary.objects.get(diary_id=diary_id)
            serializer = DiarySerializer(data, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Diary.DoesNotExist:
            return Response({'error': 'Diary not found'}, status=status.HTTP_404_NOT_FOUND)
    
    elif request.method == 'DELETE':
        diary_id = request.query_params.get('diary_id')  # URL 파라미터에서 diary_id 값을 가져옴
        try:
            data = Diary.objects.get(diary_id=diary_id)
            data.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Diary.DoesNotExist:
            return Response({'error': 'Diary not found'}, status=status.HTTP_404_NOT_FOUND)
    

@api_view(['GET'])
def get_random_data(request):
    url = "https://raw.githubusercontent.com/golbin/hubot-maxim/master/data/maxim.json"

    # 외부 링크에서 JSON 데이터 가져옴
    response = requests.get(url)
    json_data = response.text

    # JSON 데이터 파싱
    parsed_data = json.loads(json_data)

    # 0자 이하인 아이템들 필터링
    filtered_data = [item for item in parsed_data if len(item['message']) <= 40]

    # 랜덤하게 1개의 아이템 선택
    if filtered_data:
        random_item = random.choice(filtered_data)
    else:
        random_item = None

    # 선택된 아이템을 응답으로 사용
    response_data = random_item

    # JSON 응답 생성
    return Response(response_data)
