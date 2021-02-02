# GitHub 에 GPG를 이용하여 서명된 commit 사용하기

## GPG 설치
MacOS 에서 GPG를 사용하기 위해서 homebrew 를 이용하여 gpg를 설치

```
brew install gpg2
```

## GPG Suite 설치

GPG 관리를 편리하기 하기 위해서 GPG Keychain 등이 포함된 GPG Suite 설치

```
brew install gpg-suite
```

## GPG Key pair 생성

* GPG Keychain 을 실행한 후 **New** 버튼 클릭 후 새로운 Key pairs 생성

![](https://hbn-blog-assets.s3.ap-northeast-2.amazonaws.com/sungkwang/2021/02/Screen_Shot_2021-02-02_at_1_04_31_AM.png)

* Key pairs 생성 후 Public key는 GPG 서버에 업로드

![](https://hbn-blog-assets.s3.ap-northeast-2.amazonaws.com/sungkwang/2021/02/Screen_Shot_2021-02-02_at_1_05_38_AM.png)

## 터미널에서 gpg 명령어로 Key pairs 의 secrets key 확인

```
gpg --list-secret-keys --keyid-format LONG
```

![](https://hbn-blog-assets.s3.ap-northeast-2.amazonaws.com/sungkwang/2021/02/Screen_Shot_2021-02-02_at_11_12_52_AM.png)

## GitHub 에 GPG public key 등록

* GitHub 사이트에서 **Settings > SSH and GPG Key** 메뉴 이동
* GPG Keys 에 새로운 GPG 추가
    * 앞에 GPG Suite 의 GPG Keychain 에서 새로 생성한 key pair 중에 public key를 복사해서 붙여넣기 함

![](https://hbn-blog-assets.s3.ap-northeast-2.amazonaws.com/sungkwang/2021/02/Screen_Shot_2021-02-02_at_10_58_22_AM.png)    

## git config 에 gpg 사용 설정

* git config 에 **gpgsign** 사용 활성화

```
git config commit.gpgsign true
```

* git config 에 **signingkey** 추가
ABC1234567 대신 생성한 Key pairs 의 Secret Key ID 추가
```
git config commit.gpgsignkey ABC1234567
```

* git 저장소에 commit 하고 push 할 때 gpg 비밀번호 입력
* GitHub 사이트에서 commit 로그에 GPG signed commit 인증 확인

![](https://hbn-blog-assets.s3.ap-northeast-2.amazonaws.com/sungkwang/2021/02/Screen%20Shot%202021-02-02%20at%2011.18.19%20AM.png)