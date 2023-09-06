# models.py

# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.contrib.auth.hashers import make_password
from django.utils import timezone
import os

def image_upload(instance, filename):
    model_name = instance.__class__.__name__
    timestamp = timezone.now().strftime('%Y-%m-%d-%H:%M:%S.%f')[:-3]
    image_extension = os.path.splitext(filename)[1]
    image = f'image/{model_name}/{timestamp}{image_extension}'

    return image


class Admins(models.Model):
    admin_id = models.CharField(unique=True, max_length=20)
    admin_password = models.CharField(max_length=30)
    admin_name = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'admins'

class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField(default=False)
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    phone_number = models.CharField(max_length=20)
    verification_code = models.CharField(max_length=6, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'auth_user'

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

def create_user(username, password):
    user = AuthUser(username=username)
    user.set_password(password)
    user.save()

class Board(models.Model):
    board_id = models.AutoField(primary_key=True)
    board_type = models.ForeignKey('BoardType', models.DO_NOTHING, db_column='board_type', to_field='board_type')
    board_writer = models.ForeignKey(Admins, models.DO_NOTHING, db_column='board_writer', to_field='admin_id')
    board_title = models.TextField()
    board_content = models.TextField()
    board_date = models.DateField()
    board_image = models.ImageField(upload_to=image_upload, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'board'

class BoardType(models.Model):
    board_type_id = models.AutoField(primary_key=True)
    board_type = models.CharField(unique=True, max_length=20)

    class Meta:
        managed = False
        db_table = 'board_type'

class Calendar(models.Model):
    calendar_id = models.AutoField(primary_key=True)
    table_title = models.CharField(max_length=100)
    table_content = models.TextField(blank=True, null=True)
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()
    nickname = models.ForeignKey('Users', models.DO_NOTHING, db_column='nickname', to_field='nickname')
    checks = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'calendar'

class Diary(models.Model):
    diary_id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=50)
    content = models.TextField()
    diary_date = models.DateField()
    diary_image = models.ImageField(upload_to=image_upload, blank=True, null=True)
    nickname = models.ForeignKey('Users', models.DO_NOTHING, db_column='nickname', to_field='nickname')

    class Meta:
        managed = False
        db_table = 'diary'

class Friendrequest(models.Model):
    sender = models.ForeignKey('Users', on_delete=models.CASCADE, related_name='sent_friend_requests')
    receiver = models.ForeignKey('Users', on_delete=models.CASCADE, related_name='received_friend_requests')
    status = models.CharField(max_length=8)

    class Meta:
        managed = False
        db_table = 'friendrequest'


class Users(models.Model):
    id = models.AutoField(primary_key=True)
    username = models.OneToOneField(AuthUser, on_delete=models.CASCADE, db_column='username', to_field='username')
    nickname = models.CharField(unique=True, max_length=20)
    image = models.ImageField(upload_to=image_upload, blank=True, null=True)
    accomplishment_rate = models.FloatField(db_column='Accomplishment_rate', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'users'