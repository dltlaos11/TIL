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
## git 설치 명령어 모음
```
sudo apt-get install git-core // git 설치

git version //git 버전 확인

git config --global user.email "dltlaos14@naver.com" //사용자 정보 입력
git config --global user.name "dltlaos11"

git init // git 로컬저장소 생성

sudo git remote add origin url // origin은 원격저장소(remote repository) url 참조하기위한 대명사

git remote -v // remote에 origin이 잘 등록됬는지 확인

git add naver/ or git add .
git status //특정 파일이나 전체를 staging area에 올리는 작업

git commit -m "공지사항 생성" // stage 상태인 풀더나 파일을 commit 명령을 통해 로컬저장소로 commit

git push origin master //github에 올리기 위한 git push

git branch [브랜치명] // 브런치 새로 생성

git checkout [브랜치명] // git head가 가리키는 곳을 해당 브랜치로 이동

git log --online --decorate // 로그 확인(head가 새로 생성한 브랜치를 가리키면 Ok)
```
## 원격저장소에 잘못 push된 풀더 및 파일 삭제
```
git rm -r --cached [풀더 및 파일명] <-> git rm -r[풀더 및 파일명]
//로컬 저장소에서는 삭제 X              // 로컬저장소에서도 삭제
git add .
git commit -m "remove mistake push"
git push origin master
```
