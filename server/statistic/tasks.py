# # tasks.py
# from datetime import datetime, timedelta
# from django.db.models import Count, F
# from .models import Calendar, UserStatistic
# from django.contrib.auth.models import User
# from rest_framework.decorators import api_view

# from django.db.models import Count
# from .models import Calendar

# @api_view(['POST'])
# def calculate_completion_rate(tasks):
#     # 달성한 할 일 개수와 총 할 일 개수 계산
#     completed_tasks = tasks.filter(checks=True).count()
#     total_tasks = tasks.count()

#     # 달성률 계산
#     completion_rate = (completed_tasks / total_tasks) * 100 if total_tasks > 0 else 0
#     return completion_rate



# def update_user_statistics_task():
#     # 매달 1일 자정에 실행되는 작업
    
#     # 현재 년, 월 계산
#     current_date = datetime.now()
#     year = current_date.year
#     month = current_date.month
    
#     # 모든 사용자에 대해 통계 업데이트
#     users = User.objects.all()
#     for user in users:
#         # 해당 월의 시작일과 마지막일 계산
#         start_date = datetime(year, month, 1).date()
#         if month == 12:
#             end_date = datetime(year + 1, 1, 1).date() - timedelta(days=1)
#         else:
#             end_date = datetime(year, month + 1, 1).date() - timedelta(days=1)

#         # 해당 월의 할 일 목록 가져오기
#         tasks = Calendar.objects.filter(nickname=user.username, start_date__gte=start_date, end_date__lte=end_date)
#         user_completion_rate = calculate_completion_rate(tasks)

#         # 해당 월의 사용자 통계 데이터 가져오기
#         user_statistic, created = UserStatistic.objects.get_or_create(nickname=user.username, year=year, month=month)

#         # 달성률 업데이트
#         user_statistic.completion_rate = user_completion_rate
#         user_statistic.save()

# @api_view(['POST'])
# def calculate_accomplishment_rate(tasks):
#     # 완료된 작업 계산
#     completed_tasks = tasks.filter(checks=True).count()
    
#     # 전체 작업 계산
#     total_tasks = tasks.count()

#     # 성취율 계산
#     accomplishment_rate = (completed_tasks / total_tasks) * 100 if total_tasks > 0 else 0
#     return accomplishment_rate

