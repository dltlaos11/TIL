# 직렬화와 역직렬화

## 1. 핵심 개념

**직렬화(Serialization)**

- 메모리 내 데이터 구조/객체 → 바이트 스트림으로 변환
- 목적: 데이터 저장, 네트워크 전송
- 방식: 텍스트 기반(JSON, XML) 또는 바이너리 기반(Protocol Buffers)

**역직렬화(Deserialization)**

- 바이트 스트림 → 메모리 내 데이터 구조/객체로 변환
- 목적: 받은 데이터를 프로그램에서 사용 가능한 형태로 복원

## 2. 데이터 전송 사이클

1. **송신 측**: 객체를 직렬화(바이트 스트림으로 변환)
2. **전송**: 네트워크 또는 저장소를 통해 바이트 스트림 전달
3. **수신 측**: 바이트 스트림을 역직렬화(객체로 변환)

## 3. 언어별 구현

**JavaScript**

- 직렬화: `JSON.stringify(object)` → JSON 문자열
- 역직렬화: `JSON.parse(jsonString)` → JavaScript 객체

**Python**

- 직렬화: `json.dumps(object)` → JSON 문자열
- 역직렬화: `json.loads(jsonString)` → Python 객체

## 4. React에서의 적용

**직렬화 사용 상황**

- UI에 객체 표시: `<div>{JSON.stringify(object)}</div>`
- API 요청: `fetch('/api', { body: JSON.stringify(data) })`
- 로컬 스토리지: `localStorage.setItem('key', JSON.stringify(data))`

**역직렬화 사용 상황**

- API 응답 처리: `.then(response => response.json())`
- 로컬 스토리지: `JSON.parse(localStorage.getItem('key'))`

## 5. 시스템 간 통신 예시

**클라이언트 → 서버**

1. 클라이언트: 객체를 직렬화하여 전송
2. 서버: 받은 데이터를 역직렬화하여 처리

**서버 → 클라이언트**

1. 서버: 객체를 직렬화하여 응답
2. 클라이언트: 받은 데이터를 역직렬화하여 사용

## 6. 직렬화 형식 특징

**텍스트 기반**

- 장점: 사람이 읽기 쉬움, 디버깅 용이
- 단점: 크기가 큼, 처리 속도 느림
- 예시: JSON, XML, YAML

**바이너리 기반**

- 장점: 공간 효율적, 처리 속도 빠름
- 단점: 사람이 직접 읽기 어려움
- 예시: Protocol Buffers, MessagePack, BSON

## 요약

- **데이터를 보낼 때는 직렬화**: 객체 → 바이트 스트림
- **데이터를 받을 때는 역직렬화**: 바이트 스트림 → 객체
- 직렬화/역직렬화는 다른 시스템 간 데이터 교환의 필수 과정
- React에서는 UI 렌더링 시 객체를 문자열로 직렬화해야 함
- 일반적으로 JSON 형식이 가장 널리 사용됨
