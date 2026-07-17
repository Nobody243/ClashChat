@echo off
"C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot\bin\keytool.exe" -genkeypair -v -keystore "android\app\my-release-key.jks" -alias clashchatkey -keyalg RSA -keysize 2048 -validity 10000 -storepass ChangeMe123! -keypass ChangeMe123! -dname "CN=SUcoders,OU=Dev,O=SUcoders,L=City,ST=State,C=US"
exit /b %ERRORLEVEL%
