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

docker image history dltlaos11/leafy-postgres:1.0.0 // leafy-postgres 이미지의 레이어 확인
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

ifconfig en0 // ipconfig

ping 8.8.8.8 // check server res

nslookup google.com // DNS 서버로 google.com 주소의 IP 검색

docker network ls // 네트워크 리스트 조회

docker network inspect NETWORKNAME // 네트워크 상세 정보 조회, ip 확인

docker network create NETWORKNAME // 네트워크 생성

docker network rm NETWORKNAME // 네트워크 삭제

docker network create --driver bridge --subnet 10.0.0.0/24 --gateway 10.0.0.1 second-bridge // 새로운 브릿지 네트워크 생성
// subnet: 네트워크가 사용할 IP 대역대 지정, gateway: bridge(default network)의 주소를 지정

docker run -it --network second-bridge --name ubuntuC devwikirepo/pingbuntu bin/bash // 네트워크 지정 후 컨테이너 실행

docker run -p HostOS의포트:컨테이너의포트 포트포워딩 옵션 // 포트포워딩 옵션

docker run -d -p 8001:80 --name nginx2 nginx // 포트포워딩을 설정한 nginx 실행, PC의 8001 포트로 접근했을 때 컨테이너의 80포트로 포트포워딩

docker network create redmine-network // 사용자 정의 도커 네트워크를 생성

docker run --name some-mysql --network redmine-network -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=redmine -d mysql:8 // 사용자 정의 네트워크에 MySQL 컨테이너를 실행, --network 네트워크 지정

docker run --name some-redmine --network redmine-network -e REDMINE_DB_MYSQL=some-mysql -e REDMINE_DB_PASSWORD=my-secret-pw -p 3000:3000 -d redmine // MySQL 데이터베이스에 연결된 레드마인 컨테이너를 실행, -e 환경변수 지정

docker run -d -—name leafy-postgres —network leafy-network devwikirepo/leafy-postgres:1.0.0 // 네트워크 지정

docker run -d -p 8080:8080 -e DB_URL=leafy-postgres —-network leafy-network —-name leafy devwikirepo/leafy-backend:1.0.0 // DB접속 URL을 컨테이너의 이름으로 지정
```

- `172.17.0.0/16(172.0.0 ~172.17.255.255)`, `CIDR` 방식
- `docker0`: 가상 공유기의 역할을 하는 브리지, 기본 브릿지
- `브리지 네트워크`: 이러한 브리지(`docker0`)를 생성하고 관리하는 네트워크 드라이버
- 기본 네트워크(`브릿지`)는 `DNS` 기능이 없기에 새로운 브릿지 생성
- 컨테이너 재시작시 IP는 자동으로 할당되기에 서버의 `도메인` 사용

### 스토리지와 볼륨

```c

docker volume ls // 볼륨 리스트 조회

docker volume inspect VOLUMENAME // 볼륨 상세 정보 조회

docker volume create VOLUMENAME // 볼륨 생성

docker volume rm VOLUMENAME // 볼륨 삭제

docker run -v VOLUMENAME:/var/lib/postgresql/data // 도커의 볼륨을 컨테이너의 디렉터리로 마운트

docker run -v VOLUMENAME:/var/lib/postgresql/data -v VOLUMENAME2:/var/lib/postgresql // 하나의 컨테이너에 여러개의 볼륨 마운트

docker stats (컨테이너명/ID) // 컨테이너의 리소스 사용량 조회

docker events // HOSTOS에서 발생하는 이벤트 로그 조회
```

- `바인드마운트`: 호스트OS의 디렉터리를 컨테이너가 마운트하여 공유, nginxA에서 변경한 파일이 nginxB에서도 변경, 볼륨 만들지 ❌
- 컨테이너는 `Stateless`, 실행 후 변경 사항은 `컨테이너 레이어`에만 존재하고 종료되면 모두 사라진다
  - 쉽게 개수를 증가시킬 수 있고, 다른 환경에서도 빠르게 배포가 가능
- 소프트웨어의 버전(상태를 의미, OS..) 등 컨테이너의 상태 변경이 필요한 경우 `새로운 버전의 이미지를 만들어서 재배포`
- `클라우드 네이티브 환경`에서는 `MSA 아키텍처`에 따라 서버의 개수가 매우 많아지며 서버 관리 방법론이 변화(`Pet` -> `Cattle`)
  - `Pet`
    문제 발생시, 리소스가 많이 듦(전통적, `VM`)
    - 상태: 상태가 내부에 저장
    - 교체: 교체가 어려움
    - 적용사례: `Monolithic`, `OnPremise`
  - `Cattle`
    삭제 후 생성(컨테이너 방식)
    - 상태: 상태 없음, 필요시 외부 `마운트`
    - 교체: 교체가 쉬움
    - 적용사례: `MSA`, `WEBAPP`
- 컨테이너의 이미지는 한번 지정된 후 변하지 않음(불변성)
  - 상태가 없기에 저장 및 공유가 필요한 데이터는 무조건 외부에 저장(`마운트`)
  - 중요한 정보(사용자 세션정보, 캐시)는 파일이나 메모리가 아닌 캐시 서버나 쿠키를 통해 관리
  - 동일한 요청은 항상 동일한 결과를 제공해야
  - 환경 변수나 구성 파일을 통해 설정을 외부에서 주입할 수 있어야

### 레이어 관리

```docker
# 빌드 스테이지
FROM golang:alpine AS builder
WORKDIR /app
COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o helloworld main.go
# golang 이미지를 사용해서 main.go파일을 바로
# 실행 가능한 형태인 helloworld라는 프로그램으로 build 하는 부분

# 운영 스테이지
FROM scratch
COPY --from=builder /app/helloworld .
EXPOSE 8080
ENTRYPOINT ["./helloworld"]
# 빈 이미지인 스크래치 이미지를 불러온 다음, 빌드 스테이지에서 빌드한 helloworld라는
# 파일을 복사해와서 엔트리 포인트에서 컨테이너를 실행할 때 helloworld 파일을 실행
```

- `멀티 스테이지 빌드`
  - 첫 번째 스테이지에서 애플리케이션을 빌드하고, 두 번째 스테이지에서는 빌드된 실행 파일만을 가져와 최소한의 운영 이미지를 생성. 이 방식은 최종 이미지의 크기를 크게 줄이고 보안을 향상
- 이미지의 크기를 작게 구성하는 데 있어서 정적 바이너리 파일로 빌드할 수 있는 `go언어`를 사용하는 것은 좋은 방법

### 캐싱을 활용한 빌드

```docker
# 빌드 이미지로 node:14 지정
FROM node:14 AS build

WORKDIR /app

# 라이브러리 설치에 필요한 파일만 복사
COPY package.json .
COPY package-lock.json .

# 라이브러리 설치
RUN npm ci

# 소스코드 복사
COPY . /app

# 소스코드 빌드
RUN npm run build

# 런타임 이미지로 nginx 1.21.4 지정, /usr/share/nginx/html 폴더에 권한 추가
FROM nginx:1.21.4-alpine

# 빌드 이미지에서 생성된 dist 폴더를 nginx 이미지로 복사
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

### 동적 서버 구성

```docker
# 빌드 이미지로 node:14 지정
FROM node:14 AS build

WORKDIR /app

# 라이브러리 설치에 필요한 파일만 복사
COPY package.json .
COPY package-lock.json .

# 라이브러리 설치
RUN npm ci

# 소스코드 복사
COPY . /app

# 소스코드 빌드
RUN npm run build

# 프로덕션 스테이지🔥
FROM nginx:1.21.4-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf.template
ENV BACKEND_HOST leafy
ENV BACKEND_PORT 8080

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 빌드 이미지에서 생성된 dist 폴더를 nginx 이미지로 복사
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

- `ENTRYPOINT + CMD`
  - `docker-entrypoint.sh nginx -g daemon off;`

docker-entrypoint.sh

```c
#!/bin/sh
# 오류가 발생했을 떄 스크립트를 중단
set -e

# default.conf.template 파일에서 환경 변수를 대체하고 결과를 default.conf에 저장
envsubst '${BACKEND_HOST} ${BACKEND_PORT}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# 다음 명령어를 실행
# 옵션으로 제공받은 값을 실행
exec "$@"
```

- `COPY` 지시어를 여러번 쪼개서 라이브러리 설치 단계와 애플리케이션 빌드 과정을 분리

### 이중화 DB

```sh
#1. 네트워크 생성
docker network create postgres

#2. 프라이머리 노드 실행
docker run -d \
  --name postgres-primary-0 \
  --network postgres \
  -v postgres_primary_data:/bitnami/postgresql \
  -e POSTGRESQL_POSTGRES_PASSWORD=adminpassword \
  -e POSTGRESQL_USERNAME=myuser \
  -e POSTGRESQL_PASSWORD=mypassword \
  -e POSTGRESQL_DATABASE=mydb \
  # 프라이머리-스탠바이 구조
  -e REPMGR_PASSWORD=repmgrpassword \
  -e REPMGR_PRIMARY_HOST=postgres-primary-0 \
  -e REPMGR_PRIMARY_PORT=5432 \
  -e REPMGR_PARTNER_NODES=postgres-primary-0,postgres-standby-1:5432 \
  # 자신의 컨테이너 및 스텐바이 컨테이너명 지정
  -e REPMGR_NODE_NAME=postgres-primary-0 \
  -e REPMGR_NODE_NETWORK_NAME=postgres-primary-0 \
  -e REPMGR_PORT_NUMBER=5432 \
  bitnami/postgresql-repmgr:15
  # 이미지

#3. 스탠바이 노드 실행
docker run -d \
  --name postgres-standby-1 \
  --network postgres \
  # 프라이마리 컨테이너와 다른 볼륨 사용
  -v postgres_standby_data:/bitnami/postgresql \
  -e POSTGRESQL_POSTGRES_PASSWORD=adminpassword \
  -e POSTGRESQL_USERNAME=myuser \
  -e POSTGRESQL_PASSWORD=mypassword \
  -e POSTGRESQL_DATABASE=mydb \
  -e REPMGR_PASSWORD=repmgrpassword \
  -e REPMGR_PRIMARY_HOST=postgres-primary-0 \
  -e REPMGR_PRIMARY_PORT=5432 \
  -e REPMGR_PARTNER_NODES=postgres-primary-0,postgres-standby-1:5432 \
  -e REPMGR_NODE_NAME=postgres-standby-1 \
  -e REPMGR_NODE_NETWORK_NAME=postgres-standby-1 \
  -e REPMGR_PORT_NUMBER=5432 \
  bitnami/postgresql-repmgr:15

# 4. SHELL1, SHELL2 각 컨테이너의 로그 확인
docker logs -f postgres-primary-0
docker logs -f postgres-standby-1

# 5. 프라이머리 노드에 테이블 생성 및 데이터 삽입
docker exec -it -e PGPASSWORD=mypassword postgres-primary-0 psql -U myuser -d mydb -c "CREATE TABLE sample (id SERIAL PRIMARY KEY, name VARCHAR(255));"
docker exec -it -e PGPASSWORD=mypassword postgres-primary-0 psql -U myuser -d mydb -c "INSERT INTO sample (name) VALUES ('John'), ('Jane'), ('Alice');"

#6. 스탠바이 노드(서버)에 데이터가 동기화되어 있는지 확인
docker exec -it -e PGPASSWORD=mypassword postgres-standby-1 psql -U myuser -d mydb -c "SELECT * FROM sample;"

#7. 환경 정리
docker rm -f postgres-primary-0 postgres-standby-1
docker volume rm postgres_primary_data postgres_standby_data
docker network rm postgres
```

### 컨테이너 애플리케이션 리소스 관리

```sh
# 리소스 제약이 있는 상태로 컨테이너 실행 (0.5 Core / 256M Memory)
docker run -d --name with-limit --cpus=0.5 --memory=256M nginx

# 컨테이너 메타데이터 확인
docker inspect no-limit | grep -e Memory -e Cpus
```

- `Cpu Throttling`
- `OOM killer process`

### 컨테이너 내부에서 개발환경 구성

```json
{
  "name": "Leafy-frontend project based node.js",
  "dockerFile": "Dockerfile",
  "forwardPorts": [80], // 80(-p옵션과 유사), 포트 오픈
  "customizations": {
    // 확장팩 정보 및 세팅 정보
    "vscode": {
      "settings": {},
      "extensions": ["dbaeumer.vscode-eslint"]
    }
  },
  "postCreateCommand": "npm install", // 컨테이너가 생성된 다음에 실행할 커멘드 입력(cmd와 유사)
  "remoteUser": "node" // 기본 사용자
}
```

```docker
FROM node:14 // base image
RUN apt update && apt install -y less man-db sudo // os 패키지 업데이트 및 필요 유틸들 install
ARG USERNAME=node // 기본 사용자 권한 부여
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \ && chmod 0440 /etc/sudoers.d/$USERNAME

ENV DEVCONTAINER=true // for script, application
```

```sh
# 힙메모리 최대 값을 12G로 지정하면서 애플리케이션 실행, 자동으로 힙메모리 조정 ❌
java -jar -Xmx=12G app.jar

# 자동으로 힙메모리 조정
java -jar app.jar
```

- over Java 10 ver, default

### Docker Compose

```c
docker compose up -d // YAML 파일에 정의된 서비스 생성 및 시작

docker compose ps // 현재 실행중인 서비스 상태 표시

docker compose  build // 현재 실행중인 서비스의 이미지만 빌드

docker compose logs // 실행 중인 서비스의 로그 표시

docker compose down // YAML 파일에 정의된 서비스 종료 및 제거

docker compose up -d --build // 로컬에 이미지가 있어도 다시 이미지를 빌드
```

```yaml
version: "3" # API ver
services: # to start services
  hitchecker:
    build: ./ # 이미지 빌드 시 사용할 Dockerfile 경로
    image: hitchecker:1.0.0 # 이미지 빌드 및 컨테이너 실행 시 사용할 이미지 태그
    ports:
      - "5000:5000"
  restart: always # 컨테이너 종료 시 자동으로 재시작
  redis:
    image: "redis:alpine" # 컨테이너 실행 시 사용할 이미지 태그
```

```yaml
version: "3"
x-environment: &common_environment # 이중화DB, 공통 변수 활용
  POSTGRESQL_POSTGRES_PASSWORD: adminpassword
  POSTGRESQL_USERNAME: myuser
  POSTGRESQL_PASSWORD: mypassword
  POSTGRESQL_DATABASE: mydb
  REPMGR_PASSWORD: repmgrpassword
  REPMGR_PRIMARY_HOST: postgres-primary-0
  REPMGR_PRIMARY_PORT: 5432
  REPMGR_PORT_NUMBER: 5432

services:
  postgres-primary-0:
    image: bitnami/postgresql-repmgr:15
    volumes:
      - postgres_primary_data:/bitnami/postgresql
    environment:
      <<: *common_environment
      REPMGR_PARTNER_NODES: postgres-primary-0,postgres-standby-1:5432
      REPMGR_NODE_NAME: postgres-primary-0
      REPMGR_NODE_NETWORK_NAME: postgres-primary-0

  postgres-standby-1:
    image: bitnami/postgresql-repmgr:15
    volumes:
      - postgres_standby_data:/bitnami/postgresql
    environment:
      <<: *common_environment
      REPMGR_PARTNER_NODES: postgres-primary-0,postgres-standby-1:5432
      REPMGR_NODE_NAME: postgres-standby-1
      REPMGR_NODE_NETWORK_NAME: postgres-standby-1

volumes:
  postgres_primary_data:
  postgres_standby_data:
```

- 도커 컴포즈는 여러 개의 `Docker` 컨테이너들를 관리하는 도구
- 도커 컴포즈는 도커 데스크탑 설치 시 기본으로 설치
- 한 번의 명령어로 여러 개의 컨테이너를 한번에 실행하거나 종료
- 로컬 개발 환경에서 활용하기 편리
- 도커 컴포즈를 통해 관리할 컨테이너(서비스)를 `docker-compose.yml` 파일에 정의

### 도커파일 지시어

```docker

# 베이스 이미지를 지정
FROM 이미지명

# 빌드 컨텍스트의 파일을 기존 레이어에 복사(새로운 레이어 추가)
COPY 빌드컨텍스트경로 레이어경로

# 컨테이너 안에서 명령어 실행 결과를 새로운 레이어로 저장
RUN 명령어

# 컨테이너 실행 시 명령어 지정, 별도의 이미지 레이어 추가❌
CMD [”명령어”]

# dltlaos11/buildnginx라는 태그를 붙이고, .는 현재 파일의 Dockerfile을 사용하여 이미지 빌드, 빌드컨텍스트 이미지 빌드
docker build -t dltlaos11/buildnginx .

# 도커파일명이 Dockerfile이 아닌 경울 별도 지정
docker build -f 도커파일명 -t 이미지명 Dockerfile경로

# 시스템 관련 지시어
WORKDIR 폴더명 # 작업 디렉토리를 지정(cp), 새로운 레이어 추가

# 명령을 실행할 사용자 변경(su), 새로운 레이어 추가
USER 유저명

# 컨테이너가 사용할 네트워크 포트를 명시
# 컨테이너가 런타임에 지정된 네트워크 포트를 리스닝하도록 설정, 실제로 열지는 않음
EXPOSE 포트번호

## 환경변수 관련 지시어
# 이미지 빌드 시점의 환경 변수 설정
ARG 변수명 변수값
# 덮어쓰기 가능
docker build --build-arg 변수명=변수값

# 이미지 빌드 및 컨테이너 실행 시점의 환경 변수 설정
ENV 변수명 변수값
# 덮어쓰기 가능
docer run -e 변수명=변수값

## 프로세스 실행 지시어
# 고정된 명령어를 지정
# 컨테이너가 시작될 때 실행되는 명령을 설정
ENTRYPOINT ["명령어"]

# 컨테이너 실행 시 실행 명령어 지정
CMD ["명령어"]
```

```docker
FROM nginx:1.23

COPY index.html /usr/share/nginx/html/index.html

CMD ["nginx", "-g", "daemon off;"]
```

```docker
...
#postgresql.conf파일을 /etc/postgresql/postgresql.conf 로 복사, 기본 설정 파일을 덮어쓰기하여 새로운 설정 적용
COPY ./config/postgresql.conf /etc/postgresql/custom.conf

# postgres, postgres-> 실행 | -c, /etc/postgresql/custom.conf로 복사했던 config파일을 config_file로 지정, 설정파일 직적 지정시 이미지 안의 기본 default 설정 파일 말고 빌드를 통해 주입된 설정 파일 사용
CMD ["postgres", "-c", "config_file=/etc/postgresql/custom.conf"]
...
```

### 멀티 스테이지 빌드

```docker
# 첫번째 단계: 빌드 환경 설정
FROM maven:3.6 AS build
WORKDIR /app

# pom.xml과 src/ 디렉토리 복사
COPY pom.xml .
COPY src ./src

# 애플리케이션 빌드
RUN mvn clean package

# 두 번째 단계: 실행 환경 설정
FROM openjdk:11-jre-slim
WORKDIR /app

# 빌드 단계에서 생성된 JAR 파일을 복사
COPY --from=build /app/target/*.jar ./app.jar

# 애플리케이션 실행
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

### 싱글 스테이지 빌드

```docker
# 빌드 환경 설정
FROM maven:3.6-jdk-11
WORKDIR /app

# pom.xml과 src/ 디렉토리 복사
COPY pom.xml .
COPY src ./src

# 애플리케이션 빌드
RUN mvn clean package

# 빌드된 JAR 파일을 실행 환경으로 복사
RUN cp /app/target/*.jar ./app.jar

# 애플리케이션 실행
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```

### PostgreSQL Server

```c
docker exec -it postgres bin/bash // postgres 컨테이너로 shell 접속
// -it:  대화형 터미널을 의미. 
//-i는 대화형 모드를 의미하고, -t는 터미널을 할당. 이 두 옵션을 함께 사용하면 사용자가 컨테이너 내부에서 명령을 실행하고 결과를 실시간으로 확인 가능

docker cp ./config/postgresql.conf postgres:etc/postgresql/custom.conf // 호스트 머신의 `./config/postgresql.conf` 파일을 postgres 컨테이너의 `etc/postgresql/custom.conf` 파일로 복사

docker cp ./init/init.sql postgres:docker-entrypoint-initdb.d // 호스트 머신의 ./init/init.sql파일을 postgres 컨테이너의 docker-entrypoint-initdb.d 파일로 복사

// piip

brew install libpq // postgresql

docker cp ./piip-intra-api-staging-dump-20240424.sql postgres-12v-local:/ // dump하는 sql을 컨테이너의 루트로 이동

docker container exec -it postgres-12v-local /bin/bash // 특정 컨테이너에 대한 셀 세션을 시작
```

### SpringBoot Bakc Server

```docker
# 빌드 이미지로 OpenJDK 11 & Gradle을 지정, AS build 명시를 통해 빌드 스테이징을 명시
FROM gradle:7.6.1-jdk11 AS build

# 소스코드를 복사할 작업 디렉토리를 생성, mkdir && cd
WORKDIR /app

# 호스트 머신의 소스코드를 작업 디렉토리로 복사, gradle:app -> gradle컨테이너의 app폴더
COPY . /app

# Gradle 빌드를 실행하여 JAR 파일 생성
RUN gradle clean build --no-daemon

# 런타임 이미지로 OpenJDK 11 JRE-slim 지정
FROM openjdk:11-jre-slim

# 애플리케이션을 실행할 작업 디렉토리(app)를 생성
WORKDIR /app

# 빌드 이미지에서 생성된 JAR 파일을 런타임 이미지로 복사, a to b
COPY --from=build /app/build/libs/*.jar /app/leafy.jar

EXPOSE 8080
ENTRYPOINT ["java"]
CMD ["-jar", "leafy.jar"]
```

### Vue.js Server

```docker
# 빌드 이미지로 node:14(베이스이미지) 지정, 빌드 스테이지
FROM node:14 AS build

WORKDIR /app

# 빌드 컨텍스트의 소스코드를 작업 디렉토리로 복사, 라이브러리 설치 및 빌드
COPY . /app
# 의존성
RUN npm ci
# dist
RUN npm run build

# 런타임 이미지로 nginx 1.21.4 지정, /usr/share/nginx/html 폴더에 권한 추가, 실행 스테이지
FROM nginx:1.21.4-alpine

# 빌드 이미지에서 생성된 dist 폴더를 nginx 이미지로 복사
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]

```

### Info

#### 클라우드 네이티브(Cloud Native) 애플리케이션

[클라우드 환경에서 운영하는 애플리케이션의 요구 사항](https://12factor.net/ko/)

#### curl

```c
curl https://example.com

man curl
```

- API 테스트, 웹 스크래핑, 데이터 전송 등

#### mv, file rename

```c
 mv init init.sql // init -> init.sql
```
