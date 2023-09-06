# serializers.py

from rest_framework import serializers
from rest_framework.serializers import ModelSerializer
from .models import AuthUser, Users, Friendrequest,Admins,Board,BoardType,Calendar,Diary

class AuthUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    class Meta:
        model = AuthUser
        fields = ('id', 'username', 'password', 'phone_number', 'verification_code')
    
    def create(self, validated_data):
        user = AuthUser.objects.create(
            username=validated_data['username'],
            password=validated_data['password'],
            phone_number=validated_data['phone_number']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

class UsersSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True, required=False)
    
    def create(self, validated_data):
        image_data = validated_data.pop('image', None)
        user = Users.objects.create(**validated_data)
        
        if image_data:
            user.image = image_data
            user.save()
        
        return user
    
    class Meta:
        model = Users
        fields = '__all__'

class FriendrequestSerializer(ModelSerializer):
    sender = UsersSerializer(read_only=True)
    receiver = UsersSerializer(read_only=True)

    class Meta:
        model = Friendrequest
        fields = '__all__' # 전체 필드 사용

class AdminsSerializer(serializers.ModelSerializer):
    class Meta:
        model = Admins
        fields = '__all__'

class BoardTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = BoardType
        fields = '__all__'

class BoardSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True, required=False)
    def create(self, validated_data):
        image_data = validated_data.pop('image', None)

        board = Board.objects.create(**validated_data)  # Board 객체 생성

        if image_data:
            board.image = image_data
            board.save()  # 이미지 필드가 제출된 경우, 해당 이미지를 저장

        return board

    class Meta:
        model = Board
        fields = '__all__'

class CalendarSerializer(serializers.ModelSerializer):
    class Meta:
        model = Calendar
        fields = '__all__'

class DiarySerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True, required=False)
    def create(self, validated_data):
        image_data = validated_data.pop('image', None)

        diary = Diary.objects.create(**validated_data)  # diary 객체 생성

        if image_data:
            diary.image = image_data
            diary.save()  # 이미지 필드가 제출된 경우, 해당 이미지를 저장

        return diary
    class Meta:
        model = Diary
        fields = '__all__'
        