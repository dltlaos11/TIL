# 서버/클라이언트 프록시, HTTPS 핸드셰이크, RestClient

## 🎭 클라이언트/서버 보조객체 (프록시)

### 현대 분산 시스템의 보조객체들

```java
// 클라이언트 보조객체 (원격 호출을 로컬처럼 만드는 것들)
@FeignClient("user-service")
public interface UserServiceClient {
    @GetMapping("/users/{id}")
    User getUser(@PathVariable Long id); // 마치 로컬 메서드처럼 사용
}

// 내부적으로는 HTTP 요청으로 변환됨
UserServiceClient client; // 실제로는 프록시 객체
User user = client.getUser(1L); // HTTP GET /users/1 호출
```

### 클라이언트 보조객체들

- **Spring Cloud OpenFeign**: HTTP 호출을 메서드 호출로 추상화
- **RestTemplate/WebClient**: HTTP 클라이언트 추상화
- **Axios (JavaScript)**: 브라우저 HTTP 클라이언트
- **Apollo Client**: GraphQL 클라이언트 (네트워크 + 캐싱 + 상태관리)

### 서버 보조객체들

- **Spring DispatcherServlet**: HTTP 요청을 적절한 컨트롤러로 분배
- **JAX-RS Runtime**: RESTful 웹서비스 요청 처리
- **gRPC Server**: protobuf 요청을 메서드 호출로 변환

---

## 🌐 RestClient: HTTP API 호출 라이브러리

### RestClient의 역할

```java
// RestClient 없이 직접 HTTP 통신 (복잡!)
URL url = new URL("https://api.example.com/users/1");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setRequestMethod("GET");
BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
// ... 복잡한 응답 처리

// RestClient 사용 (간단!)
User user = restTemplate.getForObject("https://api.example.com/users/1", User.class);
```

### 다양한 RestClient 구현체들

```java
// 1. Spring RestTemplate (동기)
RestTemplate restTemplate = new RestTemplate();
User user = restTemplate.getForObject("/users/1", User.class);

// 2. Spring WebClient (비동기)
WebClient webClient = WebClient.create("https://api.example.com");
Mono<User> user = webClient.get().uri("/users/1").retrieve().bodyToMono(User.class);

// 3. OkHttp (Java/Android)
OkHttpClient client = new OkHttpClient();
Request request = new Request.Builder().url("https://api.example.com/users/1").build();
```

---

## 🔐 HTTPS 핸드셰이크와 프로토콜 스택

### 프로토콜 계층 구조

```
애플리케이션: HTTP/HTTPS
보안 계층:   TLS/SSL (HTTPS에만 존재)
전송 계층:   TCP (연결 지향) / UDP (비연결)
네트워크:    IP
```

### HTTPS 연결의 완전한 과정

```javascript
// HTTPS 연결 전체 라이프사이클
async function httpsLifecycle() {
  // 1. TCP 3-way 핸드셰이크 (연결 설정)
  await tcpConnect(); // SYN → SYN-ACK → ACK

  // 2. TLS 핸드셰이크 (암호화 설정)
  await tlsHandshake(); // 인증서 교환 → 키 교환 → 암호화 활성화

  // 3. 암호화된 HTTP 통신
  await sendHTTPSRequests();

  // 4. TLS 연결 종료
  await tlsClose(); // Close Notify 교환

  // 5. TCP 4-way 핸드셰이크 (연결 종료)
  await tcpTerminate(); // FIN → ACK → FIN → ACK → TIME_WAIT
}
```

### TCP 연결 종료 (4-way 핸드셰이크)

```java
public void tcp4WayHandshake() {
    // 1. 클라이언트 → 서버: FIN (연결 종료 요청)
    sendFIN();

    // 2. 서버 → 클라이언트: ACK (요청 확인)
    receiveACK();

    // 3. 서버 → 클라이언트: FIN (서버도 종료 준비 완료)
    receiveFIN();

    // 4. 클라이언트 → 서버: ACK (종료 확인)
    sendACK();

    // 5. TIME_WAIT (2MSL 대기 - 약 60초)
    waitTimeWait(); // 늦은 패킷 대비, 마지막 ACK 재전송 대비
}
```

---

## 🔑 TLS 키 교환: 공개키 + 대칭키 하이브리드

### 정확한 TLS 핸드셰이크 과정

```java
public void tlsKeyExchange() {
    // 1. 서버가 인증서로 공개키 전송
    X509Certificate cert = serverHello.certificate;
    RSAPublicKey serverPublicKey = cert.getPublicKey();

    // 2. 클라이언트가 Pre-Master Secret(랜덤 데이터) 생성
    byte[] preMasterSecret = generateRandom48Bytes(); // 암호화 기법 아님!

    // 3. 공개키로 Pre-Master Secret 암호화 전송 ✅
    byte[] encrypted = RSA.encrypt(preMasterSecret, serverPublicKey);
    sendToServer(encrypted);

    // 4. 서버가 개인키로 복호화 ✅
    byte[] decrypted = RSA.decrypt(encrypted, serverPrivateKey);

    // 5. 양쪽에서 PRF 함수로 동일한 대칭키 생성
    SymmetricKeys keys = PRF(preMasterSecret, clientRandom, serverRandom);
}
```

### PRF (Pseudo-Random Function) - 대칭키 생성 함수

```java
// PRF는 의사 난수 함수 (암호화 기법 아님)
public SymmetricKeys generateKeys(byte[] preMasterSecret, byte[] clientRandom, byte[] serverRandom) {

    // 1. Master Secret 생성
    byte[] masterSecret = PRF(
        preMasterSecret,                    // 시크릿 (랜덤 데이터)
        "master secret",                    // 라벨 (문자열)
        concat(clientRandom, serverRandom), // 시드 (랜덤 데이터)
        48                                  // 출력 길이
    );

    // 2. Key Block 생성
    byte[] keyBlock = PRF(
        masterSecret,                       // 시크릿
        "key expansion",                    // 라벨
        concat(serverRandom, clientRandom), // 시드 (순서 바뀜!)
        104                                 // 필요한 모든 키 길이 합
    );

    // 3. 키들 추출
    return extractKeys(keyBlock); // clientWriteKey, serverWriteKey 등
}
```

---

## 🔄 HTTPS = RSA(키 교환) + AES(데이터 통신)

### 하이브리드 암호화 시스템

```java
public void httpsHybridSystem() {
    System.out.println("=== HTTPS 하이브리드 시스템 ===");

    // Phase 1: RSA로 AES 키 교환 (한 번만, 느림)
    RSAKeyPair serverKeys = generateRSAKeyPair();
    byte[] preMasterSecret = generateRandom48Bytes();
    byte[] encryptedPMS = RSA.encrypt(preMasterSecret, serverKeys.publicKey);
    SymmetricKeys aesKeys = generateAESKeys(preMasterSecret);
    System.out.println("✅ RSA로 AES 키 안전 교환 완료");

    // Phase 2: AES로 실제 데이터 통신 (계속, 빠름)
    String httpRequest = "GET /api/users HTTP/1.1";
    byte[] encryptedRequest = AES.encrypt(httpRequest, aesKeys.clientWriteKey);
    sendToServer(encryptedRequest);

    String httpResponse = "HTTP/1.1 200 OK\n{\"users\": [...]}";
    byte[] encryptedResponse = AES.encrypt(httpResponse, aesKeys.serverWriteKey);
    sendToClient(encryptedResponse);
    System.out.println("🔄 모든 HTTP 데이터가 AES로 암호화/복호화됨");
}
```

### 암호화는 연결 중 계속됩니다!

```java
// ❌ 잘못된 이해: "키 교환 후 평문 통신"
// ✅ 올바른 이해: "키 교환 후 모든 데이터가 AES 암호화"

public void continuousEncryption() {
    SymmetricKeys keys = getExchangedAESKeys();

    // 모든 웹 리소스가 암호화됨
    encryptAndSend("GET /index.html", keys.clientWriteKey);    // HTML
    encryptAndSend("GET /styles.css", keys.clientWriteKey);    // CSS
    encryptAndSend("GET /script.js", keys.clientWriteKey);     // JavaScript
    encryptAndSend("GET /image.png", keys.clientWriteKey);     // 이미지
    encryptAndSend("POST /api/login", keys.clientWriteKey);    // API 호출

    // 모든 응답도 암호화됨
    // 브라우저가 자동으로 복호화해서 화면에 표시
}
```

---

## 🎯 핵심 용어 정리

### 정확한 이해

```java
// 각 구성요소의 정확한 역할
public class ComponentRoles {

    // Pre-Master Secret: 랜덤 데이터 (48바이트)
    byte[] preMasterSecret = generateRandom48Bytes(); // 암호화 기법 아님!

    // RSA: 공개키 암호화 알고리즘
    byte[] encrypted = RSA.encrypt(data, publicKey);  // 공개키로 암호화
    byte[] decrypted = RSA.decrypt(encrypted, privateKey); // 개인키로 복호화

    // PRF: 의사 난수 생성 함수
    byte[] symmetricKey = PRF(secret, label, seed, length); // 대칭키 생성

    // AES: 대칭키 암호화 알고리즘
    byte[] encrypted = AES.encrypt(data, symmetricKey); // 빠른 대량 데이터 처리
}
```

### RSA vs AES 역할 분담

```
🔐 RSA (공개키 암호화):
   - 역할: Pre-Master Secret 안전 전송
   - 사용: 연결 시작 시 한 번만
   - 특징: 안전하지만 느림 (키 교환 전용)

🚀 AES (대칭키 암호화):
   - 역할: 모든 HTTP 데이터 암호화
   - 사용: 연결 중 모든 통신에 계속
   - 특징: 빠르고 안전 (실제 데이터 통신용)
```

---

## 🌍 실제 HTTPS 통신 시뮬레이션

### 웹 페이지 방문 시 일어나는 일

```javascript
// 실제 브라우저에서 https://example.com 방문 시
async function visitHTTPSWebsite() {
  // 1. TCP + TLS 핸드셰이크 (RSA 키 교환)
  await establishSecureConnection();

  // 2. 모든 리소스가 AES로 암호화/복호화
  await encryptAndFetch("GET /"); // HTML (AES 암호화)
  await encryptAndFetch("GET /styles.css"); // CSS (AES 암호화)
  await encryptAndFetch("GET /script.js"); // JS (AES 암호화)
  await encryptAndFetch("GET /logo.png"); // 이미지 (AES 암호화)
  await encryptAndFetch("POST /api/login"); // API (AES 암호화)

  // 사용자는 모르지만 모든 데이터가 암호화/복호화됨!
}
```

### 네트워크에서 보이는 것 vs 브라우저에서 보이는 것

```
🌐 네트워크 상에서 (Wireshark 등):
   - 모든 데이터가 의미없는 암호문
   - "4a7b2c8d9e1f..." 같은 바이트 스트림

🖥️ 브라우저에서:
   - 복호화된 HTML, CSS, JavaScript
   - 정상적인 웹 페이지 표시
   - 브라우저가 자동으로 AES 복호화 처리
```

---

## 💡 기억해야 할 핵심 포인트

### HTTPS의 완벽한 보안 시스템

```
1. 🔐 RSA로 안전한 키 교환
   - 공개키로 Pre-Master Secret 암호화 전송
   - 개인키로 복호화
   - 양쪽에서 동일한 AES 키 생성

2. 🚀 AES로 빠른 데이터 통신
   - 모든 HTTP 요청/응답이 AES 암호화
   - HTML, CSS, JS, 이미지, JSON 등 모든 데이터
   - 연결 중 지속적인 암호화/복호화

3. 🎯 하이브리드의 완벽함
   - RSA의 안전성 + AES의 성능
   - 키 교환 문제 해결 + 빠른 대량 데이터 처리
   - 현대 웹 보안의 표준
```

### 프록시 패턴의 현대적 활용

```
원격 객체를 로컬처럼 사용하는 패턴:
- RMI Stub (Java 분산 객체)
- Spring Feign Client (HTTP API 호출)
- Apollo Client (GraphQL 통신)
- RestTemplate (HTTP 클라이언트)

모두 "복잡한 네트워크 통신을 간단한 메서드 호출로 추상화"하는 프록시!
```

**결론: 현대 웹은 공개키와 대칭키의 완벽한 조합으로 안전하고 빠른 통신을 구현하며, 프록시 패턴은 복잡한 분산 통신을 단순한 메서드 호출로 만들어준다**
