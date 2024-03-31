# Docker 명령어

```c
docker ps // 실행중인 컨테이너 목록
// c.f. ps는 프로세스의 줄임말

docker ps -a // 종료된 컨테이너 포함 모든 컨테이너 조회

docker rm -f multinginx1 multinginx2 multinginx3 // 실행중인 컨테이너 삭제
// c.f. -f 옵션으로 실행중인 컨테이너 여러개 삭제 가능

docker version // Client, Server의 버전 및 상태 확인

docker info // 플러그인, 현재 실행중인 호스트OS의 시스템 상세 정보 확인

docker --help // 메뉴얼 확인

docker (Management Command) Command // docker (대분류) 소분류, (대분류) 생략 가능

docker container run // 컨테이너를 실행하는 전체 명령어, docker run 으로 생략 가능

docker pull 이미지명 // 이미지 다운

docker run (실행옵션) 이미지명 // 컨테이너 실행

docker rm 컨테이너명/ID // 컨테이너 삭제

docker image ls (이미지명) // 로컬 이미지 조회

//메타데이터
docker image inspect 이미지명 // 이미지의 세부 정보 조회

docker container inspect 컨테이너명 // 컨테이너의 세부 정보 조회

docker run 이미지명(실행명령) // 컨테이너 실행 시 메타데이터의 cmd 덮어쓰기

docker run -d -p 8080:3000 --name defaulColorApp devwikirepo/envnodecolorapp // 기본 이미지의 메타데이터를 사용해 컨테이너 실행

docker run --env KEY=VALUE 이미지명 // 컨테이너 실행 시 메타데이터의 env 덮어쓰기
```
