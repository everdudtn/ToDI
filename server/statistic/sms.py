# sms.py

import json
import requests
import time
import base64
import hashlib
import hmac

def make_signature(url, access_key, secret_key):
    timestamp = str(int(time.time() * 1000))
    method = "POST"
    message = method + " " + url + "\n" + timestamp + "\n" + access_key
    message = bytes(message, 'UTF-8')
    secret_key = bytes(secret_key, 'UTF-8')
    signingkey = base64.b64encode(hmac.new(secret_key, message, digestmod=hashlib.sha256).digest())
    return signingkey

def send_sms(phone_number, content):
    user_access_key = "8V0XchIyKCb6hWqxaD6Y"
    user_secret_key = "Mtab4h2ilXDajEoe4emsMA9IBIFolq0bCCGHHJBW"
    sms_service_id = "ncp:sms:kr:294780071838:sms"
    url = "/sms/v2/services/" + sms_service_id + "/messages"
    api_url = 'https://sens.apigw.ntruss.com' + url

    headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'x-ncp-apigw-timestamp': str(int(time.time() * 1000)),
        'x-ncp-iam-access-key': user_access_key,
        'x-ncp-apigw-signature-v2': make_signature(url, user_access_key, user_secret_key)
    }

    body = {
        "type": "SMS",
        "contentType": "COMM",
        "countryCode": "82",
        "from": "01075722191",
        "content": content,
        "messages": [
            {
                "to": phone_number,
            }
        ]
    }

    body_result = json.dumps(body)

    response = requests.post(api_url, headers=headers, data=body_result)
    response.raise_for_status()
    response_result = response.json()

    send_result = response_result.get('statusCode')

    if send_result == "202":
        return True
    else:
        return False