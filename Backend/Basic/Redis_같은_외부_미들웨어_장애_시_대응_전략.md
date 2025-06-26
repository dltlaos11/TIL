# Redis 같은 외부 미들웨어 장애 시 대응 전략

## 🔥 핵심 포인트

외부 미들웨어 다운 시 서버 증설이 "불가능"한 게 아니라 **"비효율적"**인 경우가 대부분

## 📊 1단계: 즉시 모니터링 & 분석

### 장애 진단 (30초 내)

- **메트릭 확인**: CPU, 메모리, 네트워크, 응답시간
- **로그 분석**: 에러 패턴, 요청 실패율
- **의존성 체크**: Redis 연결, DB 상태, 외부 API

### 영향도 파악

- **사용자 수**: 동시 접속자, 요청 급증 여부
- **비즈니스 임계**: 주요 기능 vs 부가 기능
- **장애 범위**: 전체 다운 vs 부분 장애

## 📝 2단계: 애플리케이션 레벨 응급 대응

### 즉시 적용 가능한 대응

- **Graceful Degradation**: 핵심 기능만 유지, 성능 저하 허용
- **Rate Limiting**: 요청 제한으로 DB 부하 감소
- **DB Connection Pool 조정**: 동시 연결 수 증가
- **Circuit Breaker 활성화**: 실패 시 즉시 우회

### 데이터 처리 전략 변경

- **Batch Processing**: 실시간 → 배치 처리로 전환
- **Read Replica**: 읽기 부하 분산
- **Data Denormalization**: 자주 쓰는 데이터 미리 계산
- **In-Memory Cache**: 애플리케이션 메모리 활용

### 성능 최적화

- **쿼리 최적화**: N+1 문제 해결, 불필요한 SELECT 제거
- **비동기 처리**: 즉시 응답 불필요한 작업 큐잉
- **Static Content 증가**: 동적 → 정적 콘텐츠 전환

## ⚡ 3단계: 서킷 브레이커 패턴 적용

외부 서비스 호출 실패 시 시스템 보호하는 디자인 패턴

### 3가지 상태

- **CLOSED**: 정상 상태, 모든 요청 전달
- **OPEN**: 차단 상태, 즉시 실패 처리 (Fail Fast)
- **HALF_OPEN**: 제한된 요청만 전달해서 복구 테스트

```javascript
// 실제 구현 예시
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000) {
    this.failureCount = 0;
    this.threshold = threshold;
    this.timeout = timeout;
    this.state = "CLOSED";
  }

  async call(service) {
    if (this.state === "OPEN") {
      if (Date.now() - this.nextAttempt > this.timeout) {
        this.state = "HALF_OPEN";
      } else {
        throw new Error("Circuit breaker is OPEN");
      }
    }

    try {
      const result = await service();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
}
```

## 🚀 4단계: 인프라 대응 전략

### 서버 프로비저닝 시간

- **클라우드**: 수분~수십분 (Auto Scaling)
- **컨테이너**: 수초~수분 (Kubernetes HPA)
- **물리서버**: 수일~수주

### 증설 전 고려사항

```
⚠️  증설만으로 해결되지 않는 경우:
1. 아키텍처 의존성 (서버 목록이 Redis에 저장)
2. 세션 공유 문제 (Redis 세션 스토어)
3. DB 병목 (DB가 진짜 문제)
4. 네트워크 제약 (대역폭 한계)
```

## 🔧 5단계: 장기적 해결책

### 고가용성 설계

- **Redis Cluster**: 마스터-슬레이브 구성
- **Sentinel**: 자동 페일오버
- **Multi-AZ**: 지역 분산
- **Backup Strategy**: 정기 백업 + 복구 테스트

### 아키텍처 개선

- **Microservices**: 장애 격리
- **Event-Driven**: 비동기 처리
- **CQRS**: 읽기/쓰기 분리
- **Bulkhead Pattern**: 리소스 격리

## 🎯 면접 포인트별 답변 전략

### "왜 서버만 늘리면 안 되나요?"

> "Redis 장애 시 새 서버를 추가해도 **근본 원인**이 해결되지 않습니다. 캐시 미스로 인한 DB 부하가 여전히 남아있어서, 오히려 더 많은 서버가 DB를 공격하게 됩니다."

### "그럼 어떻게 대응하시겠어요?"

> "1분 내에 **서킷 브레이커**로 Redis 호출을 차단하고, **애플리케이션 메모리 캐시**로 우회합니다. 동시에 **쿼리 최적화**와 **Rate Limiting**으로 DB 부하를 줄이겠습니다."

### "장기적으로는 어떻게 예방하나요?"

> "**Redis Cluster**와 **Sentinel**로 고가용성을 구축하고, **Circuit Breaker**와 **Bulkhead Pattern**으로 장애 전파를 차단하겠습니다."

## 💡 결론

미들웨어 장애 시 증설은 "물리적 불가능" ✗  
→ **"근본 원인 미해결로 비효율적, 시스템 안정성 우선"** ✓

**핵심은 장애 격리와 우회 전략을 통한 빠른 복구, 그 후 고가용성 설계로 예방**
