# docker-compose 명령어 실행시 docker-compose.yml 지원하지 않는 에러 발생시

AWS Lightsail 에 Ubuntu 16.04 에서 apt install docker-compose 설치후 다음과 같은 에러 발생할 경우

```
ERROR: Version in "./docker-compose.yml" is unsupported. You might be seeing this error because you're using the wrong Compose file version. Either specify a version of "2" (or "2.0") and place your service definitions under the `services` key, or omit the `version` key and place your service definitions at the root of the file to use version 1.
```

1. 설치된 docker-compose 패키지를 삭제 
```
sudo apt remove docker-compose
```
2. 최신 docker-compose 설치
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
3. 권한 수정
```
sudo chmod +x /usr/local/bin/docker-compose
```
4. 심볼릭링크 추가
```
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```