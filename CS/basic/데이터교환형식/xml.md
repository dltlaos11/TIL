# XML 데이터 포맷의 이해

## XML이란?

XML(Extensible Markup Language)은 데이터를 저장하고 전송하기 위한 마크업 형태의 데이터 교환 형식입니다. 마크업이란 태그 등을 이용하여 문서나 데이터의 구조를 나타내는 방법으로, XML에서는 속성 부여도 가능합니다.

## XML의 기본 구성

1. **프롤로그**: XML 버전과 인코딩 정보를 명시
2. **루트 요소**: 문서당 단 하나만 존재 가능
3. **하위 요소들**: 루트 요소 내에 포함된 모든 요소

## 예시 코드

```xml
<?xml version="1.0" encoding="UTF-8"?>
<OSTList>
  <OST like="1">
    <name>마녀 배달부 키키</name>
    <song>따스함에 둘러쌓인다면</song>
  </OST>
  <OST like="2">
    <name>하울의 움직이는 성</name>
    <song>세계의 약속</song>
  </OST>
</OSTList>
```

## HTML과 XML 비교

1. **용도의 차이**:

   - HTML: 데이터 표시
   - XML: 데이터 저장 및 전송

2. **태그 정의**:

   - HTML: 미리 정의된 태그 사용
   - XML: 사용자가 고유한 태그를 생성 및 정의 가능

3. **대소문자 구분**:
   - HTML: 대소문자 구분하지 않음
   - XML: 대소문자 구분 (`<book>`과 `<Book>`은 다른 태그로 인식)

> **참고**: HTML은 자체적으로 고유 태그를 만들 수 없지만, 자바스크립트의 웹 컴포넌트(Web Components) API를 활용하면 커스텀 태그 생성이 가능합니다.

## JSON과 XML 비교

1. **구조적 차이**:

   - XML은 여는 태그와 닫는 태그 모두 필요하여 JSON보다 파일 크기가 더 큰 경향이 있음
   - JSON은 더 간결한 구문으로, 특히 JavaScript에서 처리가 용이함

2. **파싱 편의성**:
   - JSON: `JSON.parse()`로 간단히 JavaScript 객체로 변환 가능
   - XML: JavaScript 객체로 변환하기 위해 추가 파서가 필요 (예: `xml2json`)

### JSON vs XML 예시

**JSON 버전**:

```json
{
  "지브리OST리스트": [
    {
      "name": "마녀 배달부 키키",
      "song": "따스함에 둘러쌓인다면"
    },
    {
      "name": "하울의 움직이는 성",
      "song": "세계의 약속"
    }
  ]
}
```

**XML 버전**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<OSTList>
  <OST>
    <name>마녀 배달부 키키</name>
    <song>따스함에 둘러쌓인다면</song>
  </OST>
  <OST>
    <name>하울의 움직이는 성</name>
    <song>세계의 약속</song>
  </OST>
</OSTList>
```

## XML 파싱 (Node.js 예시)

```javascript
const fs = require("fs");
const path = require("path");
var parser = require("xml2json");
let a = fs.readFileSync(path.join(__dirname, "a.xml"));
a = parser.toJson(a);
console.log(a);
```

## 실제 활용 사례: sitemap.xml

XML의 대표적인 활용 사례는 `sitemap.xml`입니다. 이는 웹사이트의 모든 페이지를 리스트업한 데이터로, 검색 엔진 크롤러가 사이트의 모든 페이지를 찾을 수 있도록 도와줍니다. 특히 사이트가 큰 경우나 페이지 간 연결이 복잡한 경우에 유용합니다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://www.example.com/foo.html</loc>
    <lastmod>2018-06-04</lastmod>
  </url>
  <!-- 추가 URL 항목들 -->
</urlset>
```

> XML은 데이터 구조화와 교환에 유용하지만, 현대 웹 개발에서는 JSON보다 사용 빈도가 낮아졌습니다. 그러나 sitemap.xml과 같은 특정 영역에서는 여전히 XML이 표준으로 사용되고 있어 이해가 필요합니다.
