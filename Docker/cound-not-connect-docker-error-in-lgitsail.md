# AWS Lightsail Ubuntu 에서 Docker 데몬 접속할 수 없는 에러 발생시

AWS Lightsail Ubuntu 16.04에서 docker 설치 후 docker 명령어 실행할 때 다음 에러 발생할 경우

```
ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
```

user 에 권한 문제로 `docker.sock` 파일의 권한을 변경하고 실행하면 문제가 해결된다.

```
sudo chmod 666 /var/run/docker.sock
```