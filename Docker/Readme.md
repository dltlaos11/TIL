# Docker 명령어

- [cheatsheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf)

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

docker run (실행옵션) 이미지명 // 컨테이너 실행 Docker pull + create + start

docker rm 컨테이너명/ID // 컨테이너 삭제

docker image ls (이미지명) // 로컬 이미지 조회

docker rmi 이미지 // 이미지 삭제, 컨테이너 삭제 후 진행

// 메타데이터
docker image inspect 이미지명 // 이미지의 세부 정보 조회

docker container inspect 컨테이너명 // 컨테이너의 세부 정보 조회

docker run 이미지명(실행명령) // 컨테이너 실행 시 메타데이터의 cmd 덮어쓰기

docker run -d -p 8080:3000 --name defaulColorApp devwikirepo/envnodecolorapp // 기본 이미지의 메타데이터를 사용해 컨테이너 실행

docker run --env KEY=VALUE 이미지명 // 컨테이너 실행 시 메타데이터의 env 덮어쓰기

docker logs (컨테이너명) // 컨테이너의 로그 조회

// 컨테이너 라이프 사이클
docker create --name tencounter devwikirepo/tencounter // 컨테이너를 created 상태로 생성

docker start tencounter // 컨테이너를 실행

docker start -i tencounter // 컨테이너를 실행 및 출력 연결

docker pause hundredcounter // 일시정지

docker unpause hundredcounter // 도커 재실행

docker stop hundredcounter (컨테이너 이름) or (컨테이너ID) // 10초 뒤 종료,

docker restart hundredcounter // 컨테이너 재시작

docker logs hundredcounter // 컨테이너의 로그 확인

docker logs -f hundredcounter // 컨테이너의 로그를 터미널로 연결(실시간 로그 확인)

// 컨테이너 전체 삭제
docker rm $(docker ps -aq) // 모든 컨테이너 삭제

docker rm -f `docker ps -aq` // 실행되고 있는 컨테이너 삭제

docker ps -aq // 현재 모든 컨테이너의 ID를 나열, -a 옵션은 모든 컨테이너를 나열하고 -q 옵션은 컨테이너 ID만 출력

docker rmi $(docker images -aq) // 모든 이미지 삭제
docker images -aq // 현재 모든 이미지 ID 나열

docker rm -f <container_id> // 컨테이너를 강제로 정지하고 제거

// 이미지 커밋
docker commit -m 커밋명 실행중인컨테이너명 생성할이미지명 // 실행 중인 컨테이너를 이미지로 생성
docker commit -m "edited index.html by dltlaos11" -c 'CMD ["nginx", "-g", "daemon off;"]' officialNginx dltlaos11/commitnginx // 'CMD ["nginx", "-g", "daemon off;"]' foreground로 실행(프로세스 실행), nginx이미지의 CMD필드 지정
```

### 포트 매핑

```c
-p <host_port>:<container_port> // host_port: 호스트 시스템의 포트, 고유해야 | container_port: 중복 o
```

### 이미지 레이어

```c
docker image history 이미지명 // 이미지의 레이어 이력 조회

docker image inspect nginx // 이미지의 히스토리 조회

 docker build -t spirng-helloworld . // 도커파일 생성 후 로컬 이미지 만들기
```

### 도커 컴포즈

여러 컨테이너를 정의하고 실행하기 위한 도구다. YAML 파일을 사용하여 애플리케이션의 서비스, 네트워크, 볼륨 등을 구성

```c
docker compose up/down // 서비스 생성/중지, down시 네트워크까지 삭제
```

### 도커 볼륨

```c
docker volume create // 새로운 볼륨을 생성한다.
docker volume ls // 생성된 볼륨 목록을 조회한다.
docker volume rm // 지정한 볼륨을 삭제한다.
docker volume inspect // 지정한 볼륨의 상세 정보를 조회한다.
```

### 도커 네트워크

```c
docker network create redmine-network // 사용자 정의 도커 네트워크를 생성

docker run --name some-mysql --network redmine-network -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=redmine -d mysql:8 // 사용자 정의 네트워크에 MySQL 컨테이너를 실행

docker run --name some-redmine --network redmine-network -e REDMINE_DB_MYSQL=some-mysql -e REDMINE_DB_PASSWORD=my-secret-pw -p 3000:3000 -d redmine // MySQL 데이터베이스에 연결된 레드마인 컨테이너를 실행
```

### 도커파일 지시어

```c
FROM 이미지명 // 베이스 이미지를 지정

COPY 파일경로 복사할경로 // 파일을 레이어에 복사

CMD [”명령어”] // 컨테이너 실행 시 명령어 지정

docker build -t dltlaos11/buildnginx . // dltlaos11/buildnginx라는 태그를 붙이고, .는 현재 파일의 Dockerfile을 사용하여 이미지 빌드
```
