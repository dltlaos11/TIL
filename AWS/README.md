## AWS

### 1. AWS 활용을 위한 사전세팅

#### 1.1 Route53 도메인 설정과 AWS Certificate Manager

> `Route53`에서 도메인 구입 후 `ACM` 에서 인증서 설정

> `Route 53` - AWS 에서 지원하는 DNS 웹 서비스
>
> > - 주요기능
> >   > - 도메인 이름 구입/등록
> >   >
> >   >   > - 끝에 `link`로 끝나면 제일 저렴하다고 한다.
> >   >   > - AWS에서 도메인 구입시, CloudFront, API Gateway, Elastic Load Balancer 처럼 AWS에서 구입한 도메인과 인증서를 사용할 때 연동이 굉장히 편리해짐.
> >   >   >   > - CNAME 레코드 생성:
> >   >   >   >   > - ACM은 도메인 소유권을 확인하기 위해 추가해야 하는 CNAME 레코드 정보를 제공
> >   >   >   >   > - 해당 CNAME 레코드를 AWS Route 53에서 관리하는 도메인의 호스팅 영역에 추가
> >   >   >   > - 각기 다른 서브도메인에 대해 여러 개의 `CNAME` 레코드를 추가하는 것은 가능하며, 이를 통해 다양한 서비스나 인증 설정을 관리할 수 있다. `Route 53`에서 이러한 설정을 관리할 때는 각 레코드의 이름과 값을 정확히 입력하는 것이 중요(<mark>이 부분에서 편하다는</mark>)
> >   >   >   > - 하나의 도메인 아래에서 여러 서비스나 웹사이트 섹션을 관리할 수 있다. `서브도메인`을 사용하면 각기 다른 서버나 애플리케이션으로 트래픽을 분산시킬 수 있어 유연한 웹사이트 운영이 가능
> >   >   > - 가비아, GoDaddy 같은 데서 도메인을 구매한 경우, AWS의 Transfer domain에서 변환해줘야함. 근데 도메인을 구입한 곳에서 다른데로(AWS) 도메인을 전환할 수 있도록 `도메인 잠금`, `도메인 정보 보호` 등을 풀어놔야 함
> >   >
> >   > - 트래픽 라우팅

> `AWS Certificate Manager(ACM)` - `AWS` 서비스에서 사용할 수 있는 `SSL/TLS` 인증서
>
> > - `ACM`에서 발급하는 인증서 자체에는 별도의 비용이 발생하지 않음
>
> > - `Route53`에서 도메인을 연결해야 사용 가능
> >   > - `Elastic Load Balancer`에서도 `DNS`를 제공하지만, `Route53`에서 `routing`해야 `ACM` 인증서를 사용할 수 있음
> > - `Route53`의 도메인을 활용해야 `ACM`의 인증서를 사용할 수 있음
>
> - ACM 사용사례
>   > - `CloudFront`는 `CDN`(콘텐츠 전송 네트워크)서비스로, 전 세계에 분산된 엣지 로케이션을 통해 콘텐츠를 빠르게 전달한다. 주로 S3와 많이 사용됨. S3는 스토리지라서 사진, 영상같은 것을 저장하거나 아니면 fe에선 빌드된 파일을 저장해놓고 S3 스토리지 자체는 프라이빗을 둔 다음에 `CloudFront`와 S3를 연결해서 `CloudFront`통해서 접근하게 한다. 그럴 경우 도메인을 연결하는게 필요하기 때문에 `CloudFront`가 존재
>   >   > 1. 프론트엔드 빌드 파일을 S3에 저장
>   >   >    > - 정적 파일
>   >   > 2. S3 버킷을 프라이빗으로 설정
>   >   >    > - URL을 통해 직접 접근 X
>   >   > 3. CloudFront와 S3 연결
>   >   >    > - CloudFront는 AWS의 CDN 서비스로, S3 버킷을 오리진으로 설정하여 콘텐츠를 전 세계 엣지 로케이션을 통해 빠르게 제공할 수 있다. CloudFront를 사용하면 S3의 정적 파일에 대한 요청이 엣지 서버를 통해 전달
>   >   > 4. ACM을 통한 SSL/TLS 인증서 사용
>   >   >    > - CloudFront 배포에 ACM을 통해 발급받은 SSL/TLS 인증서를 적용하면, 사용자와 CloudFront 간의 통신이 HTTPS로 암호화
>   > - ELB의 메인역할은 로드벨런싱(`트래픽을 여러 EC2 인스턴스에 분산시키는 역할을 하며, 고가용성과 확장성을 제공`). 근데 배포할 때 쓰는 ECS라든가 EC2에 도메인을 바로 붙일수가 없어서(물론 EC2에 Nginx를 써서 Certbot해서 LetsEncrypt로 인증서를 붙일 수 있는데(도메인과) AWS를 쓰니깐 앞에 ELB를 붙여서 ELB에 도메인을 붙인 다음에 EC2랑 연계하는게 조금 더 일반적) ELB에 도메인을 붙일 때 사용.
>   >   > - `ELB`에 도메인을 연결할 때, `HTTPS`를 통해 안전한 연결을 제공하기 위해 `SSL/TLS` 인증서를 사용. `ACM`을 통해 `ELB`에 인증서를 손쉽게 적용할 수 있다. 이렇게 하면 외부 트래픽이 `ELB`를 통해 `EC2` 인스턴스로 전달될 때 보안이 강화
>   >   > - 고가용성: 시스템이나 서비스가 가능한 한 오랜 시간 동안 지속적으로 운영될 수 있는 능력
>   >   >   > - `중복성(Redundancy)`: 여러 서버나 데이터 센터를 사용하여 한 시스템이 고장 나더라도 다른 시스템이 이를 대체할 수 있도록 한다.
>   >   >   > - `로드 밸런싱(Load Balancing)`: 트래픽을 여러 서버에 분산시켜 과부하를 방지하고, 시스템의 성능을 최적화. AWS의 ELB(Elastic Load Balancer)가 이러한 역할을 수행.
>   >   >   > - `장애 조치(Failover)`: 시스템의 일부가 실패할 경우 자동으로 다른 시스템으로 전환하여 서비스 중단을 방지.
>   >   >   > - `모니터링 및 알림`: 시스템 상태를 지속적으로 모니터링하여, 문제가 발생하면 신속하게 대응할 수 있도록 한다.
>   > - `API Gateway`는 API를 생성, 배포 및 관리할 수 있는 서비스로, `AWS Lambda`와 자주 사용. Lambda는 서버리스 컴퓨팅 서비스로, 코드를 실행하는 데 서버를 관리할 필요가 없다.
>   >   > - `API Gateway`를 통해 제공되는 API에 `HTTPS`를 적용하려면 `SSL/TLS` 인증서가 필요하다. `ACM`을 사용하여 `API Gateway`에 인증서를 쉽게 연결하여, API 호출 시 보안을 강화할 수 있다.
>   >   > - TLS/SSL
>   >   >   > - `SSL(Secure Sockets Layer)`와 `TLS(Transport Layer Security)`는 인터넷 상에서 안전한 통신을 제공하기 위한 암호화 프로토콜이다. TLS는 SSL의 후속 버전으로, SSL의 여러 취약점을 개선한 더 안전한 프로토콜. 현재는 TLS가 SSL을 대체하고 있으며, 대부분의 현대적인 시스템에서는 TLS를 사용
> - ACM 자체에서는 과금 X

#### 1.2 AWS Certificate Manager에서 인증서 생성 시 주의사항

> 구입한 도메인 이름 앞에 \* 을 붙여줘야 다양한 도메인에서 활용 가능
>
> - [www.juyongjun.link](http://www.juyongjun.link) 와 같은 도메인으로 발급하면 test.juyongjun.link 라는 도메인에서는 사용할 수 없음
>
> - 도메인 별로 인증서를 관리하고 싶다면, `subdomain`마다 따로 발급 받아도 됨
>
> - ACM에서 인증서를 관리한다면 추가 인증서는 비용이 발생하지 않음

#### 1.3 VPC 설정과 Subnet ↔️ Routing Table ↔️ Internet Gateway

> VPC - Virtual Private Cloud

> - 단어 뜻을 그대로 보자면 가상의 개인 클라우드
>
> > - AWS개념으로 보자면 하나의 `Region`에 여러 `Availability Zone(AZ)`이 있고, 각각의 `Availability Zone(AZ)`에 데이터센터가 존재함
> >   > - AWS에서는 사용자가 요청하는 EC2 인스턴스가 물리적으로 어디에 위치할지에 대해 직접적인 제어가 없다. 즉, 여러 개의 EC2 인스턴스를 생성하더라도 그것들이 같은 물리적 서버랙에 위치할 것이라는 보장이 없다. 이는 클라우드의 특성상 리소스가 가상화되어 여러 데이터센터에 분산되어 있기 때문이다.
> > - 일반적으로 데이터센터는 여러개의 서버랙이 있고, 각각의 서버랙에 여러대의 서버가 있다
> >   > - 전통적인 데이터센터에서는 여러 개의 서버랙이 있으며, 각 랙에는 여러 대의 서버가 물리적으로 배치되어 있다. 이러한 서버들은 물리적으로 가까이 위치해 있기 때문에 네트워크 통신이 빠르고 효율적이다.
> > - 하지만 여러개의 EC2를 사용한다고 했을 때, 같은 서버랙에 있는 서버를 발급받는다는 보장이 없음
> > - 각각 다른 서버랙에서 서버를 배정 받았을 때, VPC로 묶어서 마치 하나의 서버랙에서 서버를 관리하는 것처럼 하는 것이 VPC의 역할
> >   > - VPC는 이러한 환경에서 `가상 네트워크`를 제공함으로써, `물리적으로 분산된 EC2 인스턴스들을 하나의 네트워크로 묶어준다.` 이는 마치 물리적으로 `같은 서버랙에 있는 것처럼 네트워크를 구성할 수 있게 해 준다`. `VPC` 내에서 `서브넷`을 설정하고, 보안 그룹을 통해 네트워크 트래픽을 관리함으로써, 사용자는 이러한 가상 네트워크 환경을 자신이 원하는 대로 커스터마이즈할 수 있다.
> >   > - VPC는 `물리적으로 분산된 클라우드 리소스들을 논리적으로 하나의 네트워크로 묶어주는 역할`을 하며, 사용자가 원하는 네트워크 환경을 가상으로 구현할 수 있게 해준다.

> Subnet
>
> > - AWS에서 EC2와 같은 리소스들은 subnet을 할당함
>
> > - Subnet에는 `Public Subnet`과 `Private Subnet`이 있음
> >   > - `Public Subnet`은 `Public IP`와 유사한 느낌으로 `외부와 통신이 가능`
> >   > - `Private Subnet`은 반대로 외부와 통신이 불가능함
> >   >   > - 따라서 `Public IP`를 assign한다고 해도 어차피 외부와 통신이 불가능하기 때문에 낭비
> >   > - backend server나 database와 같이 클라이언트가 직접 접근할 필요가 없는 리소스들을 private subnet에 두고, 클라이언트가 직접 접근하는 프론트엔드 리소스는 public subnet에 배정

> Routing Table
>
> - 요청이 들어오면 어떤 subnet으로 보낼 지 정해둔 규칙

> Internet Gateway
>
> > - Public subnet은 routing table을 통해 Internet Gateway와 연결됨
>
> > - Internet Gateway를 통해서 외부와 통신이 가능함
