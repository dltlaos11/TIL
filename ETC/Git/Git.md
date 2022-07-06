# GIT 사용법
----
## github에 commit&push하는 과정..!

```
git remote add origin '생성한 저장소url'
```
작업 및 수정 후

```
git add .

git commit -m "message"

git push origin master
```

## vs code에서 git clone하여 사용하는 경우
```
git config --list // github primary email 설정 되어있나 확인 안되어있다면 아래로

git config user.email "이메일" // 이후에 정상 작동
```
