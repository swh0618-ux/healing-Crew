# 🍎 Healing Crew - macOS 환경 구축 및 iOS 실기기 HealthKit 테스트 가이드

이 문서는 Windows 환경에서 설계 및 구현된 **`Healing Crew`** 프로젝트를 **Mac 환경으로 옮겨 실제 iPhone 및 Apple Watch의 HealthKit(실제 러닝 데이터)과 연동하여 빌드/테스트**할 때 필요한 모든 단계를 정리한 완벽 가이드입니다.

---

## 📌 1. 현재 구현 및 준비 상태 요약

- **아키텍처**: Flutter 3.x + `flutter_riverpod` (v2) 기반 Clean Architecture
- **건강 데이터 연동**: `health: ^11.0.0` 플러그인을 통한 Apple HealthKit 연동
- **권한 설정 파일 준비 완료**:
  - `ios/Runner/Info.plist`: `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription` 기재 완료
  - `ios/Runner/Runner.entitlements`: `com.apple.developer.healthkit` 자격 증명 파일 구성 완료
- **실제 데이터 모드(Real Data Only) 적용 완료**:
  - 가상 Mock 데이터 자동 대체 로직이 비활성화되어 있으며, **오직 Apple 건강 앱에 기록된 100% 실제 러닝 세션만 읽어옵니다.**

---

## 🚀 2. Mac에서 프로젝트 시작하기 (터미널)

### Step 1. 프로젝트 가져오기 및 이동
Mac 터미널을 열고 프로젝트 디렉토리로 이동합니다:
```bash
# Git을 사용할 경우
git clone <저장소 URL>
cd "Healing Crew"

# 또는 폴더를 직접 Mac으로 복사한 경우
cd "경로/Healing Crew"
```

### Step 2. Flutter 및 iOS 의존성(CocoaPods) 설치
```bash
# 1. 플러터 패키지 설치
flutter pub get

# 2. iOS CocoaPods 의존성 설치 (매우 중요)
cd ios
pod install
cd ..
```

---

## ⚙️ 3. Xcode 필수 설정 체크리스트 (1회 필수)

HealthKit은 Apple의 민감 건강 데이터 권한이므로 **반드시 Xcode에서 본인 계정으로 서명(Code Signing)**해야 합니다.

### Step 1. Xcode로 프로젝트 열기
터미널에서 아래 명령어로 Xcode를 엽니다:
```bash
open ios/Runner.xcworkspace
```
> ⚠️ **주의**: `.xcodeproj`가 아닌 **`.xcworkspace`** 파일로 열어야 CocoaPods 라이브러리가 정상 인식됩니다.

### Step 2. 무료 Apple ID 서명 (Signing) 설정
1. Xcode 좌측 네비게이터 맨 위의 **`Runner`** 파란색 아이콘 클릭
2. 중앙 탭에서 **`Signing & Capabilities`** 선택
3. **`Team`** 드롭다운 메뉴 클릭 > **`Add Account...`**를 눌러 본인의 Apple ID로 로그인 (무료 개인 계정 가능)
4. 본인 계정(Personal Team)을 선택합니다.
5. **`Bundle Identifier`** 수정:
   - 기본값이 중복될 수 있으므로 고유한 ID로 변경합니다.
   - 예: `com.healingcrew.running` ➡️ `com.yourname.healingcrew`

### Step 3. HealthKit Capability 확인
- `Signing & Capabilities` 화면 아래에 **`HealthKit`** 항목이 있는지 확인합니다.
- 만약 보이지 않는다면 좌측 상단의 **`+ Capability`** 버튼을 누르고 **`HealthKit`**을 더블 클릭하여 추가합니다.
- 프로젝트에 이미 생성된 [`Runner.entitlements`](file:///f:/antiprojects/Healing%20Crew/ios/Runner/Runner.entitlements) 파일이 자동으로 링크됩니다.

---

## 📱 4. iPhone 실기기 준비 (최초 1회)

### Step 1. iPhone 개발자 모드 활성화 (iOS 16 이상 필수)
1. iPhone의 **설정** > **개인정보 보호 및 보안**으로 이동합니다.
2. 맨 아래로 스크롤하여 **‘개발자 모드’**를 켭니다.
3. 기기 재부팅 후 화면에 뜨는 팝업에서 **[켜기]**를 누르고 iPhone 잠금 암호를 입력합니다.

### Step 2. Mac과 iPhone 케이블 연결
1. USB/C타입 케이블로 iPhone을 Mac에 연결합니다.
2. iPhone 화면에 *"이 컴퓨터를 신뢰하겠습니까?"* 팝업이 뜨면 **[신뢰]**를 선택합니다.
3. Mac 터미널에서 연결을 확인합니다:
   ```bash
   flutter devices
   ```
   > 목록에 본인의 iPhone 이름(예: `홍길동의 iPhone`)과 디바이스 ID가 보이면 준비 완료입니다.

---

## 🏃‍♂️ 5. 앱 실행 및 건강 데이터 승인

### Step 1. iPhone으로 앱 빌드 & 실행
```bash
flutter run -d <아이폰 기기ID 또는 디바이스명>
```
> 최초 빌드 시 몇 분 정도 소요될 수 있습니다.

### Step 2. iPhone에서 "신뢰하지 않는 개발자" 알림이 뜰 경우
무료 개인 계정으로 처음 빌드할 때 발생하는 정상 보안 절차입니다:
1. iPhone의 **설정** > **일반** > **VPN 및 기기 관리**로 이동합니다.
2. **개발자 앱** 항목에서 본인의 Apple ID 이메일을 누르고 **‘[본인 계정] 신뢰’**를 선택합니다.

### Step 3. Apple 건강(HealthKit) 권한 승인
앱이 실행되면 Apple 공식 시스템 팝업이 나타납니다:
1. **[모두 켜기]**를 누릅니다:
   - ✅ 운동 (Workouts)
   - ✅ 활동 에너지 (Active Energy / Calories)
   - ✅ 심박수 (Heart Rate)
   - ✅ 걷기 + 달리기 거리 (Distance Walking / Running)
   - ✅ 보행 수 (Steps)
2. 우측 상단 **[허용]**을 누릅니다.

---

## 🧪 6. 실제 러닝 데이터(Real Data) 검증 절차

본 프로젝트는 가상 데이터 폴백이 차단되어 있어 오직 **실제 Apple 건강 데이터베이스**만 읽어옵니다.

### 🎯 방법 A. Apple Watch로 달린 실제 기록 연동 확인
1. Apple Watch의 **‘운동’** 앱을 켜고 실내/야외 달리기를 진행합니다.
2. 운동 종료 후 iPhone과 Apple Watch가 블루투스로 동기화되면, iPhone의 Apple 건강 앱에 기록이 저장됩니다.
3. `Healing Crew` 앱을 열고 화면을 아래로 당겨 **새로고침(Pull-to-Refresh)**을 실행합니다.
4. **결과 확인**:
   - 총 달린 거리 및 평균 페이스
   - **1km 구간별 랩 스플릿(Lap Splits)** 바 차트
   - **심박수 시계열 곡선 차트** (`fl_chart`)
   - **Zone 1~5 심박 구간별 체류 시간 및 비율**

### 🎯 방법 B. 밖으로 나가지 않고 지금 즉시 실제 데이터로 검증하는 법
달리기를 하러 나가지 않고도 iPhone 내장 **Apple 건강** 앱에 실제 운동 데이터를 1건 수동 등록하여 HealthKit 연동을 100% 검증할 수 있습니다:

1. iPhone의 기본 **‘건강’ (하얀 바탕에 분홍 하트)** 앱 실행
2. 우측 하단 **‘검색’** 탭 > **‘활동’** > **‘운동’** 터치
3. 우측 상단 **[데이터 추가]** 터치
4. 데이터 입력:
   - **운동 종목**: `달리기`
   - **거리**: `5.20 km`
   - **칼로리**: `340 kcal`
   - **시작/종료 시간**: 오늘 30분 전 ~ 현재 (약 25~30분 소요)
5. 우측 상단 **[추가]**를 눌러 건강 앱에 저장합니다.
6. `Healing Crew` 앱으로 돌아와 화면을 아래로 당기거나 우측 상단 **동기화 아이콘** > **‘최근 14일 러닝 기록 가져오기’**를 누릅니다.
7. 방금 등록한 실제 5.2km 러닝 세션이 즉시 감지되어 대시보드와 상세 분석 화면에 나타납니다!

---

## 🔧 7. 트러블슈팅 & FAQ

| 증상 | 원인 및 해결 방법 |
| :--- | :--- |
| **`pod install` 에러 발생** | Mac 터미널에서 `arch -arm64 pod install` 실행 또는 CocoaPods 최신화 (`sudo gem install cocoapods` / `brew install cocoapods`). |
| **`Bundle identifier is already in use`** | 다른 개발자가 사용 중인 번들 ID입니다. Xcode `Signing & Capabilities`에서 `com.내아이디.healingcrew`처럼 유니크한 이름으로 변경하세요. |
| **`HealthKit Capability` 누락 경고** | Xcode에서 `Signing & Capabilities` > `+ Capability` > `HealthKit`을 반드시 추가해야 앱이 크래시되지 않습니다. |
| **데이터가 0건으로 나오는 경우** | iPhone **설정** > **건강** > **데이터 접근 및 기기** > **Healing Crew**에 들어가서 읽기 권한이 모두 켜져 있는지 확인하세요. |

---

> 💡 **참고**: 언제든 시뮬레이터나 가상 데이터로 화면 레이아웃을 확인하고 싶다면 우측 상단 동기화 메뉴 > **‘시뮬레이터 / 모의 데이터 모드’** 스위치를 켜면 테스트용 샘플 세션 5종을 언제든 불러올 수 있습니다.
