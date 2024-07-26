# GIT 사용법

---

## github에 commit&push하는 과정..!

```sh
git remote add origin '생성한 저장소url'
```

작업 및 수정 후

```sh
git add .

git commit -m "message"

git push origin master
```

## vs code에서 git clone하여 사용하는 경우

```sh
git config --list // github primary email 설정 되어있나 확인 안되어있다면 아래로

git config user.email "이메일" // 이후에 정상 작동
```

## push 성공은 했지만 repo에서 커밋변경이 확인이 안되는 경우 remote 제거 후 다시 추가

```sh
git remote remove origin

git remote -v

git remote add 주소
```

## git 설치 명령어 모음

```sh
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

```sh
git rm -r --cached [풀더 및 파일명] <-> git rm -r[풀더 및 파일명]
//로컬 저장소에서는 삭제 X              // 로컬저장소에서도 삭제
git add .
git commit -m "remove mistake push"
git push origin master
```

## 브랜치 분리, 버전 관리 rebase

```sh
# 브랜치 생성
> git checkout -b [브랜치 이름]

# 생성된 브랜치 목록 확인
> git branch

# Rebase는 하위 브랜치의 뿌리를 변경하는 과정
> git fetch origin
> git rebase origin/[브랜치 이름]

( 충돌 해결 후 add, commit, push )

>Git rebase --continue

# 작업이 끝난 브랜치 삭제
> git branch -d [브랜치 이름]
```

## 작업한 내용을 보류하거나, 다른 브랜치로 이동 stash

```sh
# 커밋 로그로 남기기에는 아직 불충분하거나 불확실한 작업내역을 일단 하나로 묶어서 보류
> git stash

# Stash한 파일들은 임시 저장공간에 보관되며 현재 작업 공간에서는 사라짐
> git stash pop // 임시 저장공간 삭제 후, working directory(unstaged)
> git stash apply // 임시 저장공간에 보유한 상태에서 꺼내기

# stash 목록 확인
> git stash list

# 특정 stash 꺼내기
> git stash apply stash@{[number]}

# 특정 stash 삭제
> git stash drop stash@{[number]}
```

## repository를 clone할 때 모든 branch를 local에 받기

```sh
# git clone --mirror
# 이 옵션을 사용하면 원격 저장소의 모든 파일을 형상 관리 하는 .git 폴더를 받아올 수 있다.

> mkdir repo_folder && cd repo_folder

# 두번째 --mirror옵션을 이용하여 내부의 .git폴더로 파일들을 받는다.
> git clone --mirror repo_URL .git

# 세번째 git 구성의 bare 값을 false로 바꿔서 빈 저장소에서 일반 저장소로 변경한다.
> git config --bool core.bare false

# 네번째 reset --hard 를 이용해서 .git 폴더의 내용들을 기준으로 정상적인 저장소로 변경한다.
> git reset --hard
```

## rebase

- 다른 인원들과 같은 브랜치를 개발할 때 수시로 rebase하는 습관
  - ide에서 제공하는 기능 사용해서 직관적으로 보기
- 말 그대로 develop에 추가로 개발된 것들을 `base`로 삼는다는 것.
  - 커밋 로그는 순서대로 보장되진 않을 수도 있지만, 선형적인 깔끔한 커밋 히스토리 구조를 갖게된다.
    - 머지는 다이아몬드 구조

```sh
(작업중인 branch)> git rebase develop
```

- 온전히 `origin`의 `develop`은 최신 상태
- 작업 중인 `branch`로 이동
