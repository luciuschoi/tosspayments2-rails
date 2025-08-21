# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 저장소에서 작업할 때 필요한 가이드를 제공합니다.

## 개발 명령어

### 테스트
```bash
bundle exec rspec                    # 모든 테스트 실행
bundle exec rspec spec/client_spec.rb  # 특정 테스트 파일 실행
```

### 코드 품질
```bash
bundle exec rubocop                  # RuboCop 린터 실행
bundle exec rubocop --auto-correct   # RuboCop 이슈 자동 수정
rake quality                        # RuboCop과 테스트 모두 실행
```

### 문서화
```bash
bundle exec yard doc                 # YARD 문서 생성
open doc/index.html                  # 생성된 문서 보기
```

### 콘솔 및 개발
```bash
bin/console                          # 젬이 로드된 인터랙티브 콘솔
bin/setup                           # 개발을 위한 초기 설정
```

### 젬 관리
```bash
rake build                          # 젬을 로컬에서 빌드
rake install                        # 젬을 로컬에 설치
rake release                        # 젬 배포 (사전 검사 포함)
rake release:check                   # 배포 전 검증 실행
```

## 아키텍처 개요

### 핵심 구성 요소

Rails 7 & 8 애플리케이션을 위한 TossPayments v2 Payment Widget 통합을 제공하는 Rails 엔진입니다.

**메인 진입점**: `lib/tosspayments2/rails.rb`
- 모든 구성 요소를 로드하고 모듈 레벨 `configure` 메서드 제공
- Rails가 있을 때만 Rails 엔진을 조건부로 로드

**Rails 엔진**: `lib/tosspayments2/rails/engine.rb`
- Rails 앱 설정이나 환경 변수에서 자동 설정
- 뷰 헬퍼와 컨트롤러 관심사를 자동 로드
- 격리된 네임스페이스 패턴 사용

**설정**: `lib/tosspayments2/rails/configuration.rb`
- 전역 설정을 위한 싱글톤 패턴
- 이니셜라이저와 Rails 앱 설정 패턴 모두 지원
- 기본값: widget_version='v2', api_base='https://api.tosspayments.com', timeout=10

### 주요 구성 요소

**Client** (`client.rb`): TossPayments API용 HTTP 클라이언트
- 결제 승인과 취소 처리
- 일시적 실패를 위한 내장 재시도 로직 (500+ 상태 코드)
- 비밀 키를 사용한 Base64 Basic Auth
- 심볼화된 키로 파싱된 JSON 반환

**Controller Concern** (`controller_concern.rb`): Rails 컨트롤러 믹스인
- `toss_client` 헬퍼 메서드 제공
- 요청당 클라이언트 인스턴스 메모이제이션

**Script Tag Helper** (`script_tag_helper.rb`): 뷰 헬퍼
- TossPayments SDK용 `<script>` 태그 생성
- 버전과 HTML 속성 커스터마이징 지원
- 메서드명: `tosspayments_script_tag`

**Verifiers**: 보안 검증 유틸리티
- `CallbackVerifier`: 콜백 파라미터 검증 (order_id, amount)
- `WebhookVerifier`: HMAC-SHA256 웹훅 서명 검증

**Generator** (`generators/tosspayments2/install/`): Rails 제너레이터
- 환경 변수 설정으로 이니셜라이저 생성
- Payment 모델, 마이그레이션, 컨트롤러, 뷰 선택적 생성
- 명령어: `rails generate tosspayments2:install`

### 에러 처리

**커스텀 예외** (`errors.rb`):
- `ConfigurationError`: 필수 설정 누락
- `APIError`: status, body, request_id를 포함한 TossPayments API 에러
- `VerificationError`: 콜백/웹훅 검증 실패

### 개발 패턴

**젬 구조**: 표준 Ruby 젬 레이아웃
- `lib/`에 네임스페이스별로 구성된 메인 코드 포함
- `spec/`에 HTTP 모킹을 위한 WebMock을 사용한 RSpec 테스트 포함
- `sig/`에 RBS 타입 시그니처 포함
- `bin/`에 개발 유틸리티 포함

**Rails 통합**: 엔진 패턴
- 깔끔한 분리를 위해 `isolate_namespace` 사용
- Rails 훅을 통한 헬퍼 자동 로드
- 이니셜라이저와 앱 설정 모두 지원

**설정 우선순위**:
1. 클래스에 대한 명시적 파라미터
2. `Tosspayments2::Rails.configure`를 통한 전역 설정
3. Rails 앱 설정 (`config.tosspayments2.*`)
4. 환경 변수 (`TOSSPAYMENTS_CLIENT_KEY`, `TOSSPAYMENTS_SECRET_KEY`)

**테스트**: 광범위한 모킹을 사용한 RSpec
- HTTP 요청을 위한 WebMock
- 커버리지 보고를 위한 SimpleCov
- 설명적인 이름으로 구성 요소별로 구성된 테스트

### 배포 프로세스

젬에는 자동화된 배포 검증이 포함됩니다:
- Git 작업 디렉토리가 깨끗해야 함
- RuboCop이 통과해야 함
- 모든 테스트가 통과해야 함
- CHANGELOG.md에 현재 버전 항목이 있어야 함
- 배포 전 `rake release:check` 사용