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

## push 성공은 했지만 repo에서 커밋변경이 확인이 안되는 경우 remote 제거 후 다시 추가
```
git remote remove origin

git remote -v

git remote add 주소
```
