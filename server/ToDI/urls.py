from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('ToDI/', include('statistic.urls')),  # statistic 앱의 URL 패턴을 추가합니다
]
