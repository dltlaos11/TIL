# N+1 문제 완벽 정리

## N+1 문제란?

N+1 문제는 **애플리케이션 레벨에서 발생하는 쿼리 최적화 문제**입니다.

### 문제 발생 패턴

```javascript
// 1번 쿼리: 게시글 목록 조회
const posts = await db.posts.findAll(); // 10개 결과

// N번 쿼리: 각 게시글마다 작성자 조회
for (const post of posts) {
  const author = await db.authors.findOne({ id: post.authorId });
  console.log(author.name);
}

// 총 11번의 쿼리 발생! (1 + 10 = N+1)
```

### 실제 SQL

```sql
-- 1번: 상위 데이터 조회
SELECT * FROM posts;  -- 10개 row

-- N번: 각 row마다 관계 데이터 조회
SELECT * FROM authors WHERE id = 1;
SELECT * FROM authors WHERE id = 2;
SELECT * FROM authors WHERE id = 3;
...
SELECT * FROM authors WHERE id = 10;
```

## N+1 문제의 본질

> **반복문 안에서 쿼리를 실행**하는 안티패턴

- 문제의 원인: 애플리케이션 로직
- 결과: 불필요한 다중 DB 왕복
- 영향: 성능 저하, DB 부하 증가

## 해결 방법

### 1. DB 레벨 해결 (JOIN)

데이터베이스에서 한 번에 조인해서 가져오기

#### Spring Data JPA - JOIN FETCH

```java
// 문제 상황
@Query("SELECT p FROM Post p")
List<Post> findAll();  // N+1 발생

// 해결
@Query("SELECT p FROM Post p JOIN FETCH p.author")
List<Post> findAllWithAuthor();
```

**실행 SQL**

```sql
SELECT p.*, a.*
FROM posts p
INNER JOIN authors a ON p.author_id = a.id;
-- 단 1번의 쿼리로 해결!
```

#### Spring Data JPA - @EntityGraph

```java
@EntityGraph(attributePaths = {"author", "comments"})
List<Post> findAll();
```

**실행 SQL**

```sql
SELECT p.*, a.*, c.*
FROM posts p
LEFT OUTER JOIN authors a ON p.author_id = a.id
LEFT OUTER JOIN comments c ON c.post_id = p.id;
```

#### Spring Data JPA - @BatchSize

```java
@Entity
public class Post {
    @ManyToOne(fetch = FetchType.LAZY)
    @BatchSize(size = 10)
    private Author author;
}
```

**실행 SQL**

```sql
-- 1번: 게시글 조회
SELECT * FROM posts;

-- 2번: IN 쿼리로 배치 조회
SELECT * FROM authors WHERE id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
-- 총 2번의 쿼리!
```

#### 전역 배치 설정

```yaml
# application.yml
spring:
  jpa:
    properties:
      hibernate:
        default_batch_fetch_size: 100
```

모든 LAZY 로딩을 자동으로 배치 처리

### 2. 애플리케이션 레벨 해결 (DataLoader)

런타임에 동적으로 요청을 배칭

#### GraphQL DataLoader

```javascript
const DataLoader = require("dataloader");

// 배치 함수 정의
const batchAuthors = async (authorIds) => {
  const authors = await db.authors.findAll({
    where: { id: authorIds },
  });

  // authorIds 순서대로 결과 반환
  return authorIds.map((id) => authors.find((author) => author.id === id));
};

// DataLoader 생성
const authorLoader = new DataLoader(batchAuthors);

// 리졸버에서 사용
const resolvers = {
  Post: {
    author: (post, args, context) => {
      return context.authorLoader.load(post.authorId);
    },
  },
};
```

**동작 방식**

```javascript
// 여러 개의 load() 호출
authorLoader.load(1);
authorLoader.load(2);
authorLoader.load(3);

// DataLoader가 자동으로 배칭
// 실제 실행: SELECT * FROM authors WHERE id IN (1, 2, 3)
```

#### DataLoader의 핵심 기능

1. **배칭(Batching)**: 같은 이벤트 루프 틱 내의 모든 요청을 하나로 묶음
2. **캐싱(Caching)**: 요청 컨텍스트 내에서 동일 데이터 재사용
3. **요청별 인스턴스**: 각 GraphQL 요청마다 새로운 DataLoader 생성

```javascript
// 캐싱 예시
const user1 = await userLoader.load(1); // DB 쿼리
const user2 = await userLoader.load(1); // 캐시에서 반환
```

## Spring JPA vs GraphQL DataLoader

|                 | Spring JPA                      | GraphQL DataLoader        |
| --------------- | ------------------------------- | ------------------------- |
| **해결 위치**   | DB 쿼리 레벨                    | 애플리케이션 레벨         |
| **방식**        | JOIN 또는 IN 쿼리               | 자동 배칭 + 캐싱          |
| **명시성**      | 쿼리마다 명시적 선언            | 자동 처리                 |
| **시점**        | 쿼리 작성 시점                  | 런타임                    |
| **적용 케이스** | 필요한 관계 데이터를 미리 알 때 | 동적으로 필드를 선택할 때 |

### 왜 GraphQL은 DataLoader가 필수인가?

GraphQL은 클라이언트가 **런타임에 필드를 동적으로 선택**하기 때문에, 어떤 관계 데이터가 필요한지 미리 알 수 없습니다.

```graphql
# 클라이언트 A
query {
  posts {
    title
  }
}
# author 필요 없음 → JOIN 불필요

# 클라이언트 B
query {
  posts {
    title
    author {
      name
    }
  }
}
# author 필요 → 이때만 조회해야 함
```

JPA처럼 미리 `JOIN FETCH`를 정의할 수 없어서, 런타임에 동적으로 배칭하는 DataLoader가 필수적입니다.

## 실전 예시: GraphQL N+1 문제

### 문제 상황

```graphql
query {
  clientEffectiveScheduleOfFees(clientId: $id) {
    content {
      id
      title
      # 각 content마다 개별 조회 발생!
      clientScheduleOfFees(filter: { clientId: $id }) {
        content {
          id
          discount
        }
      }
    }
  }
}
```

**발생하는 쿼리**

```sql
-- 1번: 상위 데이터
SELECT * FROM schedule_of_fees WHERE ...;  -- 10개

-- N번: 각각에 대해 반복
SELECT * FROM client_schedule_of_fees WHERE schedule_of_fee_id = 1 AND client_id = 123;
SELECT * FROM client_schedule_of_fees WHERE schedule_of_fee_id = 2 AND client_id = 123;
...
SELECT * FROM client_schedule_of_fees WHERE schedule_of_fee_id = 10 AND client_id = 123;

-- 총 11번!
```

### 해결 방법 1: DataLoader 사용

```javascript
// 복합 키로 DataLoader 생성
const clientScheduleOfFeesLoader = new DataLoader(async (keys) => {
  // keys: [
  //   { scheduleOfFeeId: 1, clientId: 123 },
  //   { scheduleOfFeeId: 2, clientId: 123 },
  //   ...
  // ]

  const scheduleIds = keys.map((k) => k.scheduleOfFeeId);
  const clientId = keys[0].clientId;

  // 한 번의 쿼리로 모두 조회
  const results = await db.clientScheduleOfFees.findAll({
    where: {
      scheduleOfFeeId: scheduleIds,
      clientId: clientId,
    },
  });

  // 각 key에 맞게 결과 매핑
  return keys.map((key) =>
    results.filter(
      (r) =>
        r.scheduleOfFeeId === key.scheduleOfFeeId && r.clientId === key.clientId
    )
  );
});

// 리졸버
const resolvers = {
  ScheduleOfFee: {
    clientScheduleOfFees: (parent, args, context) => {
      return context.loaders.clientScheduleOfFeesLoader.load({
        scheduleOfFeeId: parent.id,
        clientId: args.filter.clientId,
      });
    },
  },
};
```

**최적화된 쿼리**

```sql
-- 1번: 상위 데이터
SELECT * FROM schedule_of_fees WHERE ...;

-- 1번: 배치 쿼리
SELECT * FROM client_schedule_of_fees
WHERE schedule_of_fee_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  AND client_id = 123;

-- 총 2번!
```

### 해결 방법 2: DB 레벨 JOIN

```javascript
const resolvers = {
  Query: {
    clientEffectiveScheduleOfFees: async (parent, args) => {
      // 처음부터 JOIN으로 가져오기
      const result = await db.scheduleOfFees.findAll({
        include: [
          {
            model: db.clientScheduleOfFees,
            where: { clientId: args.clientId },
          },
        ],
      });

      return {
        content: result.map((row) => ({
          ...row,
          clientScheduleOfFees: {
            content: row.clientScheduleOfFees || [],
            total: row.clientScheduleOfFees?.length || 0,
          },
        })),
      };
    },
  },
};
```

**최적화된 쿼리**

```sql
-- 단 1번의 JOIN 쿼리로 해결!
SELECT s.*, c.*
FROM schedule_of_fees s
LEFT JOIN client_schedule_of_fees c
  ON s.id = c.schedule_of_fee_id
  AND c.client_id = 123;
```

### 실용적인 해결: 필터링

데이터 양이 많지 않다면 **모든 관계 데이터를 가져와서 필터링**하는 것도 실용적입니다.

```javascript
// 백엔드에서 모든 관계 데이터 반환
const allSchedules = await loader.load(scheduleOfFeeId);

// 리졸버 또는 프론트엔드에서 필터링
const filtered = allSchedules.filter((s) => s.clientId === clientId);

return {
  content: filtered,
  total: filtered.length,
};
```

✅ 구현 간단, 캐싱 효과  
⚠️ 불필요한 데이터 전송 (데이터 양이 적으면 문제 없음)

## DataLoader의 제약사항

DataLoader는 **key 기반 배칭**만 지원하므로, 복잡한 필터 조건을 각 요청마다 다르게 적용하기 어렵습니다.

```javascript
// ❌ 이런 식으로는 안 됨
loader.load(id, { filter: { status: "active" } });

// ✅ 복합 키로 해결
loader.load({ id: id, status: "active" });
```

이 경우:

- 복합 키 사용
- 모든 데이터 가져와서 필터링
- 쿼리 구조 변경 (상위에서 JOIN)

중 하나를 선택해야 합니다.

## 핵심 정리

### N+1 문제의 본질

- **원인**: 반복문 안에서 쿼리 실행
- **위치**: 애플리케이션 레벨
- **해결**: 한 번에 가져오기

### 해결 전략

1. **DB 레벨**: JOIN 또는 IN 쿼리로 한 번에 조회
2. **애플리케이션 레벨**: 런타임에 요청 배칭

### 기술별 해결법

- **Spring JPA**: `JOIN FETCH`, `@EntityGraph`, `@BatchSize`
- **GraphQL**: DataLoader (배칭 + 캐싱)

### 선택 기준

- 필요한 데이터를 미리 알 수 있다면 → **JOIN**
- 동적으로 결정된다면 → **DataLoader**
- 둘 다 가능하다면 → **상황에 맞게** (데이터 양, 복잡도 고려)

## 마무리

N+1 문제는 ORM이나 GraphQL을 사용할 때 자주 마주치는 성능 문제입니다. 하지만 본질을 이해하고 적절한 도구를 사용하면 효과적으로 해결할 수 있습니다.

- **Spring**: 쿼리 시점에 명시적으로 최적화
- **GraphQL**: 런타임에 자동으로 최적화

각 기술 스택의 특성을 이해하고, 상황에 맞는 해결 방법을 선택하는 것이 중요합니다.
