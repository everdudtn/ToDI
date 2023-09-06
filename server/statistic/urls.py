from django.urls import path
from .views import update_user_statistic
from . import views


urlpatterns = [
    path('statistics/<str:nickname>/', views.statistics, name='statistics'),
    path('update-statistic', update_user_statistic, name='update-statistic'),    

    path('signup/', views.signup, name='api_signup'),
    path('login_with_verification/', views.login_with_verification, name='api_login_with_verification'),
    path('user_login/', views.user_login, name='api_user_login'),
    # path('verify_access_token/', TokenVerifyView.a s_view(), name='verify_access_token'),
    path('refresh_access_token/', views.refresh_access_token, name='refresh_access_token'),
    # 친구 요청 전송 API
    path('send_friend_request/', views.send_friend, name='send_friend_request'),
    # 받은 친구 요청 목록 조회 API
    path('pending/<str:username>/', views.get_pending_friends),
    path('accepts/<str:username>/', views.get_accepted_friends),
    # 친구 요청 수락 API
    path('friend_accept/<str:username>/', views.friend_accept, name='friend_accept'),
    path('user/', views.get_user_by_username, name='get_user_by_username'),
    path('users/', views.users_view ),
    path('admins/', views.admins_view),
    path('board-types/', views.board_type_view),
    path('boards/', views.board_view),
    path('calendars/', views.calendar_view, name='calendars'),
    path('diaries/', views.diary_view),
    path('data/', views.get_random_data),
]
