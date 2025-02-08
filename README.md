# TIL

## 목차

1. [AWS Study Notes](#aws-study-notes)
2. [Docker Study Notes](#docker-study-notes)
3. [Webpack/Babel Study Notes](#webpack-study-notes)
4. [Node.js Study Notes](#nodejs-study-notes)

## AWS Study Notes

### Contents

#### 1. AWS 활용을 위한 사전세팅

- [Route53 도메인 설정과 AWS Certificate Manager](https://github.com/dltlaos11/TIL/tree/main/AWS#11-route53-도메인-설정과-aws-certificate-manager)
- [AWS Certificate Manager에서 인증서 생성 시 주의사항](https://github.com/dltlaos11/TIL/tree/main/AWS#12-aws-certificate-manager에서-인증서-생성-시-주의사항)
- [VPC 설정과 Subnet ↔️ Routing Table ↔️ Internet Gateway](https://github.com/dltlaos11/TIL/tree/main/AWS#13-vpc-설정과-subnet-️-routing-table-️-internet-gateway)

#### 2. Elastic Compute Cloud (EC2)로 서비스 배포

- [EC2 인스턴스 생성과 Nginx 설치](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2-인스턴스-생성과-nginx-설치)
- [EC2 단독으로 SSL 인증서를 활용하는 방법과 Elastic IP](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2-단독으로-ssl-인증서를-활용하는-방법과-elastic-ip)
- [Elastic Load Balancer ↔️ EC2](https://github.com/dltlaos11/TIL/tree/main/AWS#elastic-load-balancer-️-ec2)
- [Bastion을 활용한 EC2 instance 접근](https://github.com/dltlaos11/TIL/tree/main/AWS#bastion을-활용한-ec2-instance-접근)
- [EC2 auto scaling을 활용한 안정적인 서비스 운영](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2-auto-scaling을-활용한-안정적인-서비스-운영)
- [Auto Scaling Group Scheduled Action 설정](https://github.com/dltlaos11/TIL/tree/main/AWS#auto-scaling-group-scheduled-action-설정)
- [EC2에서 docker로 어플리케이션을 배포하는 방법](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2에서-docker로-어플리케이션을-배포하는-방법)

#### 3. Elastic Container Service (ECS)로 서비스 배포

- [Elastic Container Registry를 활용한 container 관리](https://github.com/dltlaos11/TIL/tree/main/AWS#elastic-container-registryecr를-활용한-container-관리)
- [ECS Cluster에서 Fargate로 서비스 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#ecs-cluster에서-fargate로-서비스-배포)
- [AWS Console에서 ECS Service를 업데이트하는 방법](https://github.com/dltlaos11/TIL/tree/main/AWS#aws-console에서-ecs-service를-업데이트하는-방법)
- [AWS CodePipeline을 활용한 ECS Rolling CI/CD 구성](https://github.com/dltlaos11/TIL/tree/main/AWS#aws-codepipeline을-활용한-ecs-rolling-cicd-구성)
- [ECS Fargate를 활용한 Blue/Green 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#ecs-fargate를-활용한-bluegreen-배포)
- [ECS Blue/Green CI/CD 구성](https://github.com/dltlaos11/TIL/tree/main/AWS#ecs-bluegreen-cicd-구성)
- [EC2를 활용한 ECS 클러스터 구성과 SSM Manager 설정](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2를-활용한-ecs-클러스터-구성과-ssm-manager-설정)

#### 4. 도커를 사용하지 않는 경우

- [Lambda + API Gateway를 활용하는 방법](https://github.com/dltlaos11/TIL/tree/main/AWS#lambda--api-gateway-를-활용하는-방법)
- [S3 + CloudFront를 활용한 프론트엔드 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#s3--cloudfront를-활용한-프론트엔드-배포)
- [AWS Amplify를 활용한 프론트엔드 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#aws-amplify를-활용한-프론트엔드-배포)

#### 5. 안정적인 서비스 운영을 위한 고민

- [안정적인 운영을 위한 서비스 아키텍처와 CloudWatch를 활용한 모니터링](https://github.com/dltlaos11/TIL/tree/main/AWS#안정적인-운영을-위한-서비스-아키텍처와-cloudwatch를-활용한-모니터링)

## Docker Study Notes

### Contents

#### 1. Docker 기본 개념

- [Docker 명령어](https://github.com/dltlaos11/TIL/tree/main/Docker#docker-명령어)
- [포트 매핑](https://github.com/dltlaos11/TIL/tree/main/Docker#포트-매핑)
- [이미지 레이어](https://github.com/dltlaos11/TIL/tree/main/Docker#이미지-레이어)

#### 2. Docker 구성 요소

- [도커 컴포즈](https://github.com/dltlaos11/TIL/tree/main/Docker#도커-컴포즈)
- [도커 볼륨](https://github.com/dltlaos11/TIL/tree/main/Docker#도커-볼륨)
- [도커 네트워크](https://github.com/dltlaos11/TIL/tree/main/Docker#도커-네트워크)
- [스토리지와 볼륨](https://github.com/dltlaos11/TIL/tree/main/Docker#스토리지와-볼륨)

#### 3. 이미지 빌드와 최적화

- [레이어 관리](https://github.com/dltlaos11/TIL/tree/main/Docker#레이어-관리)
- [캐싱을 활용한 빌드](https://github.com/dltlaos11/TIL/tree/main/Docker#캐싱을-활용한-빌드)
- [동적 서버 구성](https://github.com/dltlaos11/TIL/tree/main/Docker#동적-서버-구성)
- [도커파일 지시어](https://github.com/dltlaos11/TIL/tree/main/Docker#도커파일-지시어)
- [멀티 스테이지 빌드](https://github.com/dltlaos11/TIL/tree/main/Docker#멀티-스테이지-빌드)
- [싱글 스테이지 빌드](https://github.com/dltlaos11/TIL/tree/main/Docker#싱글-스테이지-빌드)

#### 4. 실전 서버 구성

- [PostgreSQL Server](https://github.com/dltlaos11/TIL/tree/main/Docker#postgresql-server)
- [SpringBoot Back Server](https://github.com/dltlaos11/TIL/tree/main/Docker#springboot-back-server)
- [Vue.js Server](https://github.com/dltlaos11/TIL/tree/main/Docker#vuejs-server)

#### 5. 고급 구성

- [이중화 DB](https://github.com/dltlaos11/TIL/tree/main/Docker#이중화-db)
- [컨테이너 애플리케이션 리소스 관리](https://github.com/dltlaos11/TIL/tree/main/Docker#컨테이너-애플리케이션-리소스-관리)
- [컨테이너 내부에서 개발환경 구성](https://github.com/dltlaos11/TIL/tree/main/Docker#컨테이너-내부에서-개발환경-구성)

## Webpack Study Notes

### Contents

#### 1. 웹팩 기본 개념

- [프론트엔드 개발환경의 이해](https://github.com/dltlaos11/TIL/tree/main/Webpack#프론트엔드-개발환경의-이해)
- [Background](https://github.com/dltlaos11/TIL/tree/main/Webpack#background)
- [IIFE 방식의 모듈](https://github.com/dltlaos11/TIL/tree/main/Webpack#iife-방식의-모듈)
- [다양한 모듈 스펙](https://github.com/dltlaos11/TIL/tree/main/Webpack#다양한-모듈-스펙)

#### 2. 엔트리/아웃풋과 로더

- [엔트리/아웃풋](https://github.com/dltlaos11/TIL/tree/main/Webpack#엔트리아웃풋)
- [로더의 역할](https://github.com/dltlaos11/TIL/tree/main/Webpack#로더의-역할)
- [자주 사용하는 로더](https://github.com/dltlaos11/TIL/tree/main/Webpack#자주-사용하는-로더)
- [커스텀 로더 만들기](https://github.com/dltlaos11/TIL/tree/main/Webpack#커스텀-로더-만들기)

#### 3. 플러그인과 바벨

- [플러그인의 역할](https://github.com/dltlaos11/TIL/tree/main/Webpack#플러그인의-역할)
- [자주 사용하는 플러그인](https://github.com/dltlaos11/TIL/tree/main/Webpack#자주-사용하는-플러그인)
- [바벨의 기본 동작](https://github.com/dltlaos11/TIL/tree/main/Webpack#바벨의-기본-동작)
- [env 프리셋 설정과 폴리필](https://github.com/dltlaos11/TIL/tree/main/Webpack#env-프리셋-설정과-폴리필)

#### 4. 웹팩 개발 서버

- [기본 설정](https://github.com/dltlaos11/TIL/tree/main/Webpack#기본-설정)
- [API 연동](https://github.com/dltlaos11/TIL/tree/main/Webpack#api-연동)
- [핫 모듈 리플레이스먼트](https://github.com/dltlaos11/TIL/tree/main/Webpack#핫-모듈-리플레이스먼트)

#### 5. 웹팩 최적화

- [production 모드](https://github.com/dltlaos11/TIL/tree/main/Webpack#production-모드)
- [최적화](https://github.com/dltlaos11/TIL/tree/main/Webpack#최적화)
- [코드 스플리팅](https://github.com/dltlaos11/TIL/tree/main/Webpack#코드-스플리팅)
- [externals](https://github.com/dltlaos11/TIL/tree/main/Webpack#externals)

## Node.js Study Notes

### Contents

#### 1. Node.js 기본 개념

- [노드의 정의](https://github.com/dltlaos11/TIL/tree/main/Node#노드의-정의)
- [런타임](https://github.com/dltlaos11/TIL/tree/main/Node#런타임)
- [내부 구조](https://github.com/dltlaos11/TIL/tree/main/Node#내부-구조)
- [노드의 특성](https://github.com/dltlaos11/TIL/tree/main/Node#노드의-특성)
- [서버로서의 노드](https://github.com/dltlaos11/TIL/tree/main/Node#서버로서의-노드)

#### 2. JavaScript 기본 문법

- [var, const, let](https://github.com/dltlaos11/TIL/tree/main/Node#var-const-let)
- [템플릿 리터럴](https://github.com/dltlaos11/TIL/tree/main/Node#템플릿-리터럴)
- [화살표 함수](https://github.com/dltlaos11/TIL/tree/main/Node#화살표-함수)
- [구조분해 할당](https://github.com/dltlaos11/TIL/tree/main/Node#구조분해-할당)
- [클래스](https://github.com/dltlaos11/TIL/tree/main/Node#클래스)
- [Promise와 async/await](https://github.com/dltlaos11/TIL/tree/main/Node#promise-asyncawait)

#### 3. Node.js 핵심 개념

- [호출 스택](https://github.com/dltlaos11/TIL/tree/main/Node#호출-스택)
- [이벤트 루프](https://github.com/dltlaos11/TIL/tree/main/Node#이벤트-루프)
- [모듈과 this](https://github.com/dltlaos11/TIL/tree/main/Node#module-this-require-순환참조)
- [내장 모듈](https://github.com/dltlaos11/TIL/tree/main/Node#노드-내장-객체)

#### 4. 웹 서버 만들기

- [http 모듈로 서버 만들기](https://github.com/dltlaos11/TIL/tree/main/Node#node-http-server)
- [REST API와 라우팅](https://github.com/dltlaos11/TIL/tree/main/Node#restful-server)
- [쿠키와 세션](https://github.com/dltlaos11/TIL/tree/main/Node#cookie-and-session)
- [https와 http2](https://github.com/dltlaos11/TIL/tree/main/Node#https-http2)
- [cluster](https://github.com/dltlaos11/TIL/tree/main/Node#cluster)

#### 5. Express

- [Express 기본](https://github.com/dltlaos11/TIL/tree/main/Node#express)
- [미들웨어](https://github.com/dltlaos11/TIL/tree/main/Node#morgan-bodyparser-cookieparser)
- [라우팅](https://github.com/dltlaos11/TIL/tree/main/Node#req-res-라우터-분리)
- [템플릿 엔진](https://github.com/dltlaos11/TIL/tree/main/Node#템플릿-엔진)

#### 6. 데이터베이스

- [시퀄라이즈 ORM](https://github.com/dltlaos11/TIL/tree/main/Node#시퀄라이즈-orm)
- [시퀄라이즈 모델](https://github.com/dltlaos11/TIL/tree/main/Node#시퀄라이즈-모델)
- [관계 정의](https://github.com/dltlaos11/TIL/tree/main/Node#관계-정의하기)
- [쿼리와 관계 쿼리](https://github.com/dltlaos11/TIL/tree/main/Node#관계-쿼리)
