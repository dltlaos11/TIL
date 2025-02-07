# TIL

### 배운것을 정리합니다 😀

# AWS Study Notes

## Contents

### 1. AWS 활용을 위한 사전세팅

- [Route53 도메인 설정과 AWS Certificate Manager](https://github.com/dltlaos11/TIL/tree/main/AWS#11-route53-도메인-설정과-aws-certificate-manager)
- [AWS Certificate Manager에서 인증서 생성 시 주의사항](https://github.com/dltlaos11/TIL/tree/main/AWS#12-aws-certificate-manager에서-인증서-생성-시-주의사항)
- [VPC 설정과 Subnet ↔️ Routing Table ↔️ Internet Gateway](https://github.com/dltlaos11/TIL/tree/main/AWS#13-vpc-설정과-subnet-️-routing-table-️-internet-gateway)

### 2. Elastic Compute Cloud (EC2)로 서비스 배포

- [EC2 인스턴스 생성과 Nginx 설치](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2-인스턴스-생성과-nginx-설치)
- [EC2 단독으로 SSL 인증서를 활용하는 방법과 Elastic IP](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2-단독으로-ssl-인증서를-활용하는-방법과-elastic-ip)
- [Elastic Load Balancer ↔️ EC2](https://github.com/dltlaos11/TIL/tree/main/AWS#elastic-load-balancer-️-ec2)
- [Bastion을 활용한 EC2 instance 접근](https://github.com/dltlaos11/TIL/tree/main/AWS#bastion을-활용한-ec2-instance-접근)
- [EC2 auto scaling을 활용한 안정적인 서비스 운영](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2-auto-scaling을-활용한-안정적인-서비스-운영)
- [Auto Scaling Group Scheduled Action 설정](https://github.com/dltlaos11/TIL/tree/main/AWS#auto-scaling-group-scheduled-action-설정)
- [EC2에서 docker로 어플리케이션을 배포하는 방법](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2에서-docker로-어플리케이션을-배포하는-방법)

### 3. Elastic Container Service (ECS)로 서비스 배포

- [Elastic Container Registry를 활용한 container 관리](https://github.com/dltlaos11/TIL/tree/main/AWS#elastic-container-registryecr를-활용한-container-관리)
- [ECS Cluster에서 Fargate로 서비스 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#ecs-cluster에서-fargate로-서비스-배포)
- [AWS Console에서 ECS Service를 업데이트하는 방법](https://github.com/dltlaos11/TIL/tree/main/AWS#aws-console에서-ecs-service를-업데이트하는-방법)
- [AWS CodePipeline을 활용한 ECS Rolling CI/CD 구성](https://github.com/dltlaos11/TIL/tree/main/AWS#aws-codepipeline을-활용한-ecs-rolling-cicd-구성)
- [ECS Fargate를 활용한 Blue/Green 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#ecs-fargate를-활용한-bluegreen-배포)
- [ECS Blue/Green CI/CD 구성](https://github.com/dltlaos11/TIL/tree/main/AWS#ecs-bluegreen-cicd-구성)
- [EC2를 활용한 ECS 클러스터 구성과 SSM Manager 설정](https://github.com/dltlaos11/TIL/tree/main/AWS#ec2를-활용한-ecs-클러스터-구성과-ssm-manager-설정)

### 4. 도커를 사용하지 않는 경우

- [Lambda + API Gateway를 활용하는 방법](https://github.com/dltlaos11/TIL/tree/main/AWS#lambda--api-gateway-를-활용하는-방법)
- [S3 + CloudFront를 활용한 프론트엔드 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#s3--cloudfront를-활용한-프론트엔드-배포)
- [AWS Amplify를 활용한 프론트엔드 배포](https://github.com/dltlaos11/TIL/tree/main/AWS#aws-amplify를-활용한-프론트엔드-배포)

### 5. 안정적인 서비스 운영을 위한 고민

- [안정적인 운영을 위한 서비스 아키텍처와 CloudWatch를 활용한 모니터링](https://github.com/dltlaos11/TIL/tree/main/AWS#안정적인-운영을-위한-서비스-아키텍처와-cloudwatch를-활용한-모니터링)
