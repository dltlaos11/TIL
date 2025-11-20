# Class Component → Functional Component 변환 가이드

> React 16.8+ Hooks를 사용한 Class Component의 Functional Component 변환 작업 정리

## 목차

- [변환 범위](#변환-범위)
- [주요 변환 내용](#주요-변환-내용)
- [핵심 인사이트](#핵심-인사이트)
- [라이프사이클 변환 패턴](#라이프사이클-변환-패턴)
- [테스트 전략](#테스트-전략)
- [검증 결과](#검증-결과)

---

## 변환 범위

### MVVM 아키텍처 레이어별 변환 여부

| 파일                               | 역할                 | 경로                                                                     | 변환 여부     |
| ---------------------------------- | -------------------- | ------------------------------------------------------------------------ | ------------- |
| `index.js`                         | Entry (Next.js page) | `packages/piip-webapp-intranet/pages/cases/file-wrappers/`               | ✅ 변환 완료  |
| `FileWrapperListAdminPage.js`      | Mediator (Page)      | `packages/piip-cases-modules/src/modules/admin/pages/fileWrappers/`      | ✅ 변환 완료  |
| `FileWrapperListAdminView.js`      | View                 | `packages/piip-cases-modules/src/modules/admin/views/fileWrappers/`      | ✅ 변환 완료  |
| `FileWrapperListAdminViewModel.js` | ViewModel            | `packages/piip-cases-modules/src/modules/admin/viewModels/fileWrappers/` | ❌ Class 유지 |

---

## 주요 변환 내용

### 1. Entry Layer (index.js)

#### Before (Class)

```javascript
class FileWrapperList extends Component {
  constructor(props) {
    super(props);
    this.casesStore = CasesAdminStore.createInstance({
      [CasesAdminStore.type.FILE_WRAPPER_MODEL]: {
        service: FileWrapperApolloService.createInstance(apolloClient),
      },
      // ...
    });
    this.state = {
      query: props?.query,
      fileWrappers: props?.fileWrappers,
      pagination: props?.pagination,
    };
  }

  componentDidUpdate(prevProps) {
    const currentQuery = this.props.routerContext?.router?.query;

    if (!isQueryEqual(prevProps.query, currentQuery)) {
      const service = FileWrapperApolloService.createInstance(
        this.props.apolloClient
      );
      // fetch data and setState
    }
  }

  render() {
    return (
      <IntranetAppLayout auth={this.props.auth}>
        <Provider {...this.casesStore.getStores()}>
          <FileWrapperListAdminPage {...this.props} {...this.state} />
        </Provider>
      </IntranetAppLayout>
    );
  }
}
```

#### After (Functional)

```javascript
const FileWrapperList = (props) => {
  const { apolloClient, auth } = props;
  const routerContext = useContext(RouterContext);

  // Store는 컴포넌트 생명주기 동안 한 번만 생성
  const [casesStore] = useState(() =>
    CasesAdminStore.createInstance({
      [CasesAdminStore.type.FILE_WRAPPER_MODEL]: {
        service: FileWrapperApolloService.createInstance(apolloClient),
      },
      // ...
    })
  );

  // State 초기화
  const [state, setState] = useState({
    query: props?.query,
    fileWrappers: props?.fileWrappers,
    pagination: props?.pagination,
  });

  // Query 변경 감지 및 데이터 페칭 (componentDidUpdate 로직)
  useEffect(() => {
    const currentQuery = routerContext?.router?.query;

    if (!isQueryEqual(state.query, currentQuery)) {
      const service = FileWrapperApolloService.createInstance(apolloClient);

      const fetchData = async () => {
        try {
          const { fileWrappers, pagination } = await fetchFileWrappers(
            service,
            currentQuery
          );
          setState((prev) => ({
            ...prev,
            query: currentQuery,
            fileWrappers,
            pagination,
          }));
        } catch (errors) {
          console.log(errors);
        }
      };

      fetchData();
    }
  }, [routerContext?.router?.query, apolloClient]);

  return (
    <IntranetAppLayout auth={auth} siderConfig={"INTELLECTUAL_PROPERTY"}>
      <Provider {...casesStore.getStores()}>
        <FileWrapperListAdminPage {...props} {...state} />
      </Provider>
    </IntranetAppLayout>
  );
};
```

**핵심 포인트:**

- `useState(() => ...)` lazy initializer로 Store 한 번만 생성
- `useEffect`로 query 변경 감지 및 데이터 fetch
- 의존성 배열: `[routerContext?.router?.query, apolloClient]`

---

### 2. Mediator Layer (Page)

#### Before (Class)

```javascript
class FileWrapperListAdminPage extends Component {
  constructor(props) {
    super(props);

    const { fileWrapperModel, customerModel, personInChargeModel } = props;

    // 초기 데이터 설정
    fileWrapperModel.setFileWrappers(props.fileWrappers);
    fileWrapperModel.setPagination(props.pagination);

    // ViewModel 생성
    this.viewModel = new FileWrapperListAdminViewModel(
      fileWrapperModel,
      customerModel,
      personInChargeModel,
      {
        cdnEnabled: !!props.cdnEndPoint,
        cdnEndPoint: props.cdnEndPoint,
      }
    );
  }

  shouldComponentUpdate(nextProps) {
    return !isQueryEqual(this.props?.query, nextProps?.query);
  }

  componentDidUpdate(prevProps) {
    const { fileWrapperModel } = this.props;

    if (!isQueryEqual(prevProps?.query, this.props?.query)) {
      fileWrapperModel.setFileWrappers(this.props.fileWrappers);
      fileWrapperModel.setPagination(this.props.pagination);
    }
  }

  render() {
    return (
      <FileWrapperListAdminView viewModel={this.viewModel} {...this.props} />
    );
  }
}
```

#### After (Functional)

```javascript
const FileWrapperListAdminMediator = (props) => {
  const fileWrapperModel = props[CasesAdminStore.type.FILE_WRAPPER_MODEL];
  const customerModel = props[CasesAdminStore.type.CUSTOMER_MODEL];
  const personInChargeModel =
    props[CasesAdminStore.type.PERSON_IN_CHARGE_MODEL];

  // ViewModel은 컴포넌트 생명주기 동안 한 번만 생성
  const [viewModel] = useState(() => {
    // 초기 데이터 설정 (constructor에서 했던 것)
    fileWrapperModel.setFileWrappers(props.fileWrappers);
    fileWrapperModel.setPagination(props.pagination);

    return new FileWrapperListAdminViewModel(
      fileWrapperModel,
      customerModel,
      personInChargeModel,
      {
        cdnEnabled: !!props.cdnEndPoint,
        cdnEndPoint: props.cdnEndPoint,
      }
    );
  });

  // shouldComponentUpdate 로직을 useEffect로 대체
  useEffect(() => {
    // query가 변경되었을 때만 Model 업데이트
    fileWrapperModel.setFileWrappers(props.fileWrappers);
    fileWrapperModel.setPagination(props.pagination);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [props.query]);

  return <FileWrapperListAdminView viewModel={viewModel} {...props} />;
};

// React.memo로 불필요한 리렌더링 방지 (shouldComponentUpdate 대체)
const MemoizedMediator = React.memo(
  FileWrapperListAdminMediator,
  (prevProps, nextProps) => {
    // true를 반환하면 리렌더링 스킵 (shouldComponentUpdate와 반대!)
    return isQueryEqual(prevProps?.query, nextProps?.query);
  }
);

export const FileWrapperListAdminPage = inject(
  CasesAdminStore.type.FILE_WRAPPER_MODEL,
  CasesAdminStore.type.CUSTOMER_MODEL,
  CasesAdminStore.type.PERSON_IN_CHARGE_MODEL
)(withRouterContext(MemoizedMediator));
```

**핵심 포인트:**

- `useState(() => new ViewModel(...))` - ViewModel 한 번만 생성 (MobX observable 유지)
- `useEffect(..., [props.query])` - query 변경 시에만 Model 업데이트
- `React.memo`로 shouldComponentUpdate 대체 (주의: 반환값 의미가 반대)

---

### 3. View Layer

#### Before (Class)

```javascript
@observer
class FileWrapperListAdminView extends Component {
  state = {
    searchInitValues: {},
    isLoading: false,
    createFormVisible: false,
    downloadFormVisible: false,
  };

  componentDidMount() {
    this.parseSearchInitValues();
  }

  componentDidUpdate(prevProps) {
    this.parseSearchInitValues();
  }

  parseSearchInitValues = () => {
    const { router, viewModel } = this.props;
    const basicOptions = viewModel.getFileWrapperBasicSearchOptions();
    const query = router?.router?.query || {};

    // ... 복잡한 로직

    const currentSearchInitValues = {
      rightType,
      nationalApproach,
      wrapperType,
      isClosing,
      basicSearch,
    };

    if (!isQueryEqual(currentSearchInitValues, this.state.searchInitValues)) {
      this.setState({ searchInitValues: currentSearchInitValues });
    }
  };

  createFileWrapper = async (values) => {
    // ... implementation
  };

  render() {
    const { searchInitValues, isLoading, createFormVisible } = this.state;
    // ... render logic
  }
}
```

#### After (Functional)

```javascript
const FileWrapperListAdminView = observer(
  ({ viewModel, router, currentAuthName }) => {
    // State를 개별 useState로 분리
    const [searchInitValues, setSearchInitValues] = useState({});
    const [isLoading, setIsLoading] = useState(false);
    const [createFormVisible, setCreateFormVisible] = useState(false);
    const [downloadFormVisible, setDownloadFormVisible] = useState(false);

    // componentDidMount + componentDidUpdate 통합
    useEffect(() => {
      const basicOptions = viewModel.getFileWrapperBasicSearchOptions();
      const query = router?.router?.query || {};

      // parseSearchInitValues 로직을 인라인으로 이동
      const {
        offset,
        limit,
        rightType = "ALL",
        nationalApproach = "ALL",
        wrapperType = "ALL",
        isClosing = "ALL",
        ...other
      } = query;

      const basicSearch = Object.keys(other)?.reduce(
        (result, key) => {
          if (basicOptions?.map((option) => option.value)?.includes(key)) {
            return {
              option: key,
              keyword: other[key],
            };
          }
        },
        { option: "keyword", keyword: "" }
      );

      const currentSearchInitValues = {
        rightType,
        nationalApproach,
        wrapperType,
        isClosing,
        basicSearch,
      };

      if (!isQueryEqual(currentSearchInitValues, searchInitValues)) {
        setSearchInitValues(currentSearchInitValues);
      }
    }, [router?.router?.query]);

    // 일반 함수로 정의 (useCallback 불필요)
    const createFileWrapper = async (values) => {
      setIsLoading(true);
      try {
        const result = await viewModel.createFileWrapper(values);
        // ... handle result
      } catch (error) {
        // ... handle error
      } finally {
        setIsLoading(false);
      }
    };

    const handleSearchRoute = (values) => {
      // ... implementation
    };

    return (
      <DefaultAdminPageHeaderLayout>
        {/* ... JSX */}
      </DefaultAdminPageHeaderLayout>
    );
  }
);

export { FileWrapperListAdminView };
```

**핵심 포인트:**

- `@observer` decorator → `observer()` HOC
- class state를 여러 개의 `useState`로 분리
- `componentDidMount` + `componentDidUpdate` → 하나의 `useEffect`로 통합
- 이벤트 핸들러는 일반 함수로 정의 (useCallback 불필요)

---

## 핵심 인사이트

### 1. useState vs useRef vs useMemo (ViewModel 생성)

| Hook                          | 사용 여부   | 이유                                            |
| ----------------------------- | ----------- | ----------------------------------------------- |
| `useState(() => new VM())`    | ✅ **정답** | 한 번만 생성, 재생성 없음, MobX observable 유지 |
| `useRef(new VM())`            | ❌ 안티패턴 | 매 렌더마다 `new VM()` 실행 후 버림             |
| `useRef() + if(!ref.current)` | ❌ 안티패턴 | 조건문으로 생성 제어하는 것은 비권장            |
| `useMemo(() => new VM(), [])` | ⚠️ 비권장   | React는 메모이제이션 보장 안함                  |

```javascript
// ✅ 올바른 방법
const [viewModel] = useState(() => new FileWrapperListAdminViewModel(...))

// ❌ 잘못된 방법
const viewModel = useRef(new FileWrapperListAdminViewModel(...))  // 매번 new 실행!
```

### 2. useEffect 의존성 배열 - 무한루프 방지

```javascript
// ❌ 잘못된 예 - 무한루프 발생
useEffect(() => {
  fileWrapperModel.setFileWrappers(props.fileWrappers);
  fileWrapperModel.setPagination(props.pagination);
}, [props.fileWrappers, props.pagination]); // fileWrappers/pagination이 변경될 때마다 실행

// ✅ 올바른 예
useEffect(() => {
  fileWrapperModel.setFileWrappers(props.fileWrappers);
  fileWrapperModel.setPagination(props.pagination);
}, [props.query]); // query가 변경될 때만 실행
```

**원리:**

- `props.query` 변경 → 부모가 새로운 데이터 fetch → `fileWrappers`, `pagination` props로 전달
- `fileWrappers`를 의존성에 넣으면 불필요한 재실행 발생
- **"무엇이 변경되었나"가 아니라 "왜 실행해야 하나"를 의존성으로**

### 3. useCallback 남용 금지

```javascript
// ❌ 불필요한 useCallback
const handleClick = useCallback(() => {
  doSomething();
}, []);

return <button onClick={handleClick}>Click</button>;

// ✅ 일반 함수로 충분
const handleClick = () => {
  doSomething();
};

return <button onClick={handleClick}>Click</button>;
```

**useCallback이 필요한 경우:**

1. 메모이제이션된 자식 컴포넌트에 props로 전달
2. 다른 hook의 dependency array에 포함

```javascript
const MemoizedChild = React.memo(Child);

const handleClick = useCallback(() => {
  doSomething();
}, []);

return <MemoizedChild onClick={handleClick} />; // ← 이럴 때만 필요
```

### 4. React.memo vs shouldComponentUpdate

**주의: 반환값의 의미가 반대!**

```javascript
// Class: shouldComponentUpdate
shouldComponentUpdate(nextProps) {
  return !isEqual(this.props, nextProps)  // true면 렌더링 O
}

// Functional: React.memo
React.memo(Component, (prevProps, nextProps) => {
  return isEqual(prevProps, nextProps)  // true면 렌더링 X (스킵)
})
```

### 5. MobX Observable과 React Hooks

```javascript
// Before: @observer decorator
@observer
class MyView extends Component { ... }

// After: observer() HOC
const MyView = observer((props) => { ... })
```

**주의:** ViewModel은 `useState`로 한 번만 생성해야 MobX observable 유지

### 6. Jest 환경 설정

#### jest.config.js

```javascript
module.exports = {
  testEnvironment: "jsdom", // DOM API 제공 (document, window 등)
  moduleNameMapper: {
    // CSS import를 mock으로 대체
    "\\.(css|less|scss|sass)$":
      "<rootDir>/src/modules/admin/pages/fileWrappers/__test__/styleMock.js",
  },
};
```

#### styleMock.js

```javascript
module.exports = {}; // 빈 객체 export
```

**필요한 이유:**

- Jest는 CSS를 파싱할 수 없음
- CSS import 시 `SyntaxError: Unexpected token '.'` 발생
- 단위 테스트는 로직 검증이 목적이므로 CSS는 모킹해도 무방

---

## 라이프사이클 변환 패턴

| Class Lifecycle           | Functional Hook                               | 비고                    |
| ------------------------- | --------------------------------------------- | ----------------------- |
| `constructor()`           | `useState(() => ...)`                         | lazy initializer 사용   |
| `componentDidMount()`     | `useEffect(() => {...}, [])`                  | 빈 배열 = 마운트 시 1회 |
| `componentDidUpdate()`    | `useEffect(() => {...}, [deps])`              | deps 변경 시 실행       |
| `componentWillUnmount()`  | `useEffect(() => { return () => {...} }, [])` | cleanup 함수 return     |
| `shouldComponentUpdate()` | `React.memo(Component, compareFn)`            | 주의: 반환값 의미 반대  |
| `this.state`              | `useState()`                                  | 여러 개로 분리 권장     |
| `this.method = () => {}`  | `const method = () => {}`                     | 일반 함수로 정의        |

---

## 테스트 전략

### 테스트 레이어 선택

| 레이어              | 테스트 작성      | 이유                           |
| ------------------- | ---------------- | ------------------------------ |
| ViewModel           | ❌ 안함          | Class 그대로 유지, 변환 안함   |
| **Page (Mediator)** | ✅ **중점 작성** | hooks 변환 로직의 핵심         |
| View                | △ 선택적         | 복잡한 의존성, DOM 기반 테스트 |

### Page 테스트가 중요한 이유

1. ViewModel 생명주기 관리 검증 (한 번만 생성되는지)
2. Model 업데이트 타이밍 검증 (query 변경 시)
3. 최적화 동작 검증 (React.memo로 불필요한 렌더 방지)

### 테스트 예시

```javascript
describe("FileWrapperListAdminPage - Functional Component", () => {
  it("컴포넌트가 정상적으로 렌더링되는가?", () => {
    const { getByTestId } = render(
      <FileWrapperListAdminPage {...defaultProps} />
    );
    expect(getByTestId("file-wrapper-list-view")).toBeInTheDocument();
  });

  it("초기 렌더링 시 fileWrapperModel.setFileWrappers가 호출되는가?", () => {
    render(<FileWrapperListAdminPage {...defaultProps} />);
    expect(mockFileWrapperModel.setFileWrappers).toHaveBeenCalledWith(
      defaultProps.fileWrappers
    );
  });

  it("query가 변경되면 Model이 업데이트되는가?", () => {
    const { rerender } = render(<FileWrapperListAdminPage {...defaultProps} />);
    jest.clearAllMocks();

    const newProps = {
      ...defaultProps,
      query: { offset: "10", limit: "10" },
      fileWrappers: [{ id: 2, ourRefNumber: "TEST-002" }],
    };

    rerender(<FileWrapperListAdminPage {...newProps} />);

    expect(mockFileWrapperModel.setFileWrappers).toHaveBeenCalledWith(
      newProps.fileWrappers
    );
  });

  it("query가 변경되지 않으면 Model이 업데이트되지 않는가? (React.memo)", () => {
    const { rerender } = render(<FileWrapperListAdminPage {...defaultProps} />);
    jest.clearAllMocks();

    const newProps = {
      ...defaultProps,
      someOtherProp: "changed", // query는 동일
    };

    rerender(<FileWrapperListAdminPage {...newProps} />);

    // React.memo가 리렌더링을 막아야 함
    expect(mockFileWrapperModel.setFileWrappers).not.toHaveBeenCalled();
  });
});
```

---

## 검증 결과

### 1. 테스트 결과

```
PASS  src/modules/admin/pages/fileWrappers/__test__/FileWrapperListAdminPage.test.js
  FileWrapperListAdminPage - Functional Component
    ✓ 컴포넌트가 정상적으로 렌더링되는가?
    ✓ 초기 렌더링 시 fileWrapperModel.setFileWrappers가 호출되는가?
    ✓ 초기 렌더링 시 fileWrapperModel.setPagination이 호출되는가?
    ✓ query가 변경되면 Model이 업데이트되는가?
    ✓ query가 변경되지 않으면 Model이 업데이트되지 않는가? (React.memo)

Test Suites: 1 passed, 1 total
Tests:       5 passed, 5 total
```

### 2. 기능 검증

- ✅ 페이지네이션 정상 동작
- ✅ 검색 기능 정상 동작
- ✅ 모달 열기/닫기 정상 동작
- ✅ 데이터 생성/수정 정상 동작

### 3. 성능 검증

- ✅ React.memo로 불필요한 리렌더링 방지
- ✅ MobX observable 정상 동작
- ✅ ViewModel 재생성 없음 (useState lazy initializer)

---

## 핵심 교훈

### ✅ DO

1. **useState lazy initializer는 인스턴스 생성의 정답**

   ```javascript
   const [viewModel] = useState(() => new ViewModel(...))
   ```

2. **의존성 배열은 "왜 실행해야 하나"를 담아야 함**

   ```javascript
   useEffect(() => {
     updateModel(props.data);
   }, [props.query]); // data가 아니라 query!
   ```

3. **useCallback은 필요한 곳에만**

   - 메모이제이션된 자식에게 props로 전달
   - 다른 hook의 dependency array에 포함

4. **React.memo의 반환값은 shouldComponentUpdate와 반대**

   ```javascript
   React.memo(Component, (prev, next) => {
     return isEqual(prev, next); // true면 스킵!
   });
   ```

5. **테스트는 변환 로직이 집중된 Mediator 레이어에 작성**

### ❌ DON'T

1. **useRef로 인스턴스 생성 금지**

   ```javascript
   // ❌ 매번 new 실행됨
   const viewModelRef = useRef(new ViewModel(...))
   ```

2. **useEffect 의존성에 업데이트되는 값 넣지 않기**

   ```javascript
   // ❌ 무한루프
   useEffect(() => {
     updateData(data);
   }, [data]);
   ```

3. **모든 함수에 useCallback 쓰지 않기**

   ```javascript
   // ❌ 불필요
   const handleClick = useCallback(() => {...}, [])
   ```

4. **class state를 하나의 useState로 관리하지 않기**

   ```javascript
   // ❌ 복잡함
   const [state, setState] = useState({ a: 1, b: 2, c: 3 });

   // ✅ 분리
   const [a, setA] = useState(1);
   const [b, setB] = useState(2);
   const [c, setC] = useState(3);
   ```

---

## 변경된 파일 목록

### 소스 코드

- `packages/piip-webapp-intranet/pages/cases/file-wrappers/index.js`
- `packages/piip-cases-modules/src/modules/admin/pages/fileWrappers/FileWrapperListAdminPage.js`
- `packages/piip-cases-modules/src/modules/admin/views/fileWrappers/FileWrapperListAdminView.js`

### 테스트 및 설정

- `packages/piip-cases-modules/jest.config.js` (생성)
- `packages/piip-cases-modules/src/modules/admin/pages/fileWrappers/__test__/styleMock.js` (생성)
- `packages/piip-cases-modules/src/modules/admin/pages/fileWrappers/__test__/FileWrapperListAdminPage.test.js` (생성)

---

## 참고 자료

- [React Hooks 공식 문서](https://ko.legacy.reactjs.org/docs/hooks-intro.html)
- [React.memo 공식 문서](https://ko.legacy.reactjs.org/docs/react-api.html#reactmemo)
- [MobX와 React Hooks 함께 사용하기](https://ko.mobx.js.org/react-integration.html)
- [Testing Library 공식 문서](https://testing-library.com/docs/react-testing-library/intro/)
