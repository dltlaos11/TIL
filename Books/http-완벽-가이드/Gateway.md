# 게이트웨이(Gateway)

## 📌 게이트웨이란?

**클라이언트와 서버 사이에서 중간자 역할을 하는 서버**

- 요청을 받아서 변환/처리 후 전달
- 최종 서비스가 아닌 중계 역할 (S3는 게이트웨이가 아님)

## 🔄 3가지 주요 게이트웨이 유형

### 1. 프로토콜 게이트웨이

서로 다른 프로토콜 간 통신을 가능하게 하는 게이트웨이

```
클라이언트 --HTTPS--> Gateway --HTTP--> Server
```

**주요 기능:**

- SSL 터미네이션 (HTTPS → HTTP)
- HTTP/2 → HTTP/1.1 변환
- HTTP → WebSocket 업그레이드

**대표 서비스:** nginx, HAProxy, AWS ALB

### 2. 변환 게이트웨이

같은 프로토콜이지만 데이터 형식이나 내용을 변경하는 게이트웨이

```
요청 헤더 추가 → 인증 토큰 삽입
응답 압축 → Gzip, Brotli
이미지 변환 → WebP 변환, 리사이징
```

**주요 기능:**

- 헤더 추가/삭제/수정
- 데이터 압축 및 최적화
- API 응답 포맷 변경 (JSON → XML)
- 이미지 처리 및 최적화

**대표 서비스:** API Gateway, CloudFlare Workers, Kong

### 3. 캐싱 게이트웨이

자주 요청되는 리소스를 저장해서 직접 응답하는 게이트웨이

```
Cache HIT:  클라이언트 → CDN (직접 응답)
Cache MISS: 클라이언트 → CDN → Origin Server
```

**주요 기능:**

- 정적 파일 캐싱 (이미지, CSS, JS)
- API 응답 캐싱
- 조건부 요청 처리 (304 Not Modified)
- 오리진 서버 부하 감소

**대표 서비스:** CloudFront, Fastly, Varnish

## 🏗️ 실무 포인트

### 복합적 사용

실제로는 하나의 게이트웨이가 여러 역할을 동시에 수행

```yaml
CDN (CloudFront):
  - SSL 터미네이션 [프로토콜]
  - 이미지 최적화 [변환]
  - 정적 파일 캐싱 [캐싱]
```

### 위치에 따른 분류

| 유형              | 위치          | 예시        | 용도                 |
| ----------------- | ------------- | ----------- | -------------------- |
| **Forward Proxy** | 클라이언트 측 | 회사 프록시 | 외부 접근 제어, 캐싱 |
| **Reverse Proxy** | 서버 측       | nginx, CDN  | 로드밸런싱, 보안     |

### 주요 사용 목적

1. **보안** 🔐

   - SSL/TLS 처리
   - DDoS 방어, WAF
   - 인증/인가

2. **성능** ⚡

   - 캐싱으로 응답 속도 향상
   - 압축으로 대역폭 절약
   - 로드밸런싱으로 부하 분산

3. **호환성** 🔧
   - 레거시 시스템 연동
   - 프로토콜 변환
   - API 버전 관리

## 💡 핵심 포인트

> ⚠️ **게이트웨이 = 중간자**
>
> - 최종 목적지가 아닌 중계 역할
> - S3, Database 등 최종 서비스는 게이트웨이가 아님

> 🌐 **현대 웹 아키텍처**
>
> - 거의 모든 트래픽이 어떤 형태의 게이트웨이를 거침
> - 마이크로서비스 환경에서는 필수 구성 요소

## 🔍 실제 사례

```
일반적인 웹 서비스 구조:
사용자 → CloudFront(CDN) → ALB → nginx → Application Server → RDS

각 단계별 게이트웨이 역할:
- CloudFront: 캐싱 + SSL 터미네이션
- ALB: 로드밸런싱 + 헬스체크
- nginx: 리버스 프록시 + 정적 파일 서빙
```

## 📚 추가 학습 키워드

- Service Mesh (Istio, Linkerd)
- API Gateway Pattern
- BFF (Backend for Frontend)
- Circuit Breaker Pattern
- Rate Limiting
- Edge Computing
