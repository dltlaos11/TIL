# Graphql

- [Graphql](#graphql)
  - [일반적인 구조](#일반적인-구조)
    - [DTO (Data Transfer Object):](#dto-data-transfer-object)
    - [Service:](#service)
    - [Repository:](#repository)
    - [Controller:](#controller)
    - [요약](#요약)
  - [Grqphql에선 Controller 보단 Reosolver](#grqphql에선-controller-보단-reosolver)
    - [Resolver:](#resolver)

## 일반적인 구조

### DTO (Data Transfer Object):

> - 클라이언트와 서버 간 데이터 교환을 위한 객체입니다
> - 도메인의 특정 속성들을 정의하며, 데이터 검증 규칙도 포함할 수 있습니다
> - 주로 요청(Request)과 응답(Response)을 위한 객체로 분리되기도 합니다
> - 비즈니스 로직은 포함하지 않고, 순수하게 데이터 구조만 정의합니다

### Service:

> - 비즈니스 로직을 구현하는 계층입니다
> - Repository를 DI(의존성 주입)를 통해 주입받아 사용합니다
> - 트랜잭션 관리, 도메인 로직 처리 등 핵심 기능을 담당합니다
> - Controller와 Repository 사이의 중간 계층으로서 역할을 합니다

### Repository:

> - 데이터 액세스 계층으로, 데이터베이스와의 직접적인 통신을 담당합니다
> - CRUD 연산을 제공하며 데이터 영속성 관련 로직을 캡슐화합니다
> - 엔티티 객체를 관리하고 쿼리를 실행합니다

### Controller:

> - HTTP 요청을 받아 처리하고 응답을 반환하는 엔드포인트 역할을 합니다
> - 클라이언트의 요청을 적절한 Service로 전달합니다
> - 주로 API의 라우팅을 담당하며, URL 경로와 HTTP 메서드를 매핑합니다
> - 요청 데이터의 기본적인 유효성 검사를 수행하기도 합니다
> - DTO를 통해 데이터를 주고받으며, Service 계층을 DI로 주입받아 사용합니다

### 요약

> - Controller: 클라이언트 요청 수신 및 라우팅
> - DTO: 데이터 전송 객체로 요청/응답 데이터 구조 정의
> - Service: 비즈니스 로직 처리
> - Repository: 데이터베이스 접근 및 관리
>
> 계층 구조는 관심사의 분리(Separation of Concerns)를 통해 코드의 유지보수성과 테스트 용이성을 높이는 장점이 있습니다. Service 계층이 Repository를 DI로 주입받는 구조는 의존성을 낮추고 테스트를 쉽게 만듦

## Grqphql에선 Controller 보단 Reosolver

### Resolver:

> - GraphQL API에서 Controller와 유사한 역할을 합니다
> - GraphQL 쿼리, 뮤테이션, 서브스크립션을 처리하는 함수들의 집합입니다
> - 각 필드마다 해당 데이터를 어떻게 가져올지(resolve) 정의합니다
> - REST API의 Controller처럼 요청을 받아 Service 계층으로 전달합니다
> - DTO를 통해 데이터를 전달받고 반환합니다
>
> GraphQL 기반 애플리케이션에서의 일반적인 계층 구조는:
>
> - Resolver: GraphQL 쿼리/뮤테이션 처리 (REST의 Controller 역할)
> - DTO/Input Types: 데이터 전송 객체 (GraphQL에서는 Input Type이라고도 함)
> - Service: 비즈니스 로직 처리
> - Repository: 데이터베이스 액세스
>
> Resolver는 GraphQL 스키마의 각 필드가 어떻게 데이터를 가져올지를 정의하며, 필드별로 세분화된 권한 관리나 데이터 로딩 최적화(Dataloader 패턴 등)를 구현할 수 있게 해줍니다.
