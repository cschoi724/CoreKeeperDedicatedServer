# 프로젝트 결정사항

## 확정된 결정

### 2026-06-24: 루트 관리 세션과 구현 세션을 분리

- 결정: 현재 세션은 루트 관리 에이전트로 문서 구조와 작업 분리만 수행한다.
- 근거: 사용자 요청에서 실제 구현은 하지 말고 운영 문서 구조를 세팅하라고 명시함.

### 2026-06-24: 우선 개발 영역은 `automation`

- 결정: Windows Dedicated Server 자동화 템플릿 구현 영역을 `automation/`으로 둔다.
- 근거: 프로젝트 핵심 산출물이 앱이나 서버 코드가 아니라 설치/운영 자동화 템플릿임.

### 2026-06-24: 실행 대상은 Windows, 현재 macOS에서는 실행하지 않음

- 결정: macOS에서는 문서와 템플릿 작성만 수행하고, 실제 설치/실행 검증은 Windows 노트북에서 진행한다.
- 근거: 사용자 상황에서 실제 서버 실행 환경이 집의 Windows 노트북이라고 명시됨.

### 2026-06-24: 기본 운영 방식은 SteamCMD + SDR(Game ID)

- 결정: 구현 기본값은 SteamCMD 기반 설치/업데이트와 SDR(Game ID) 접속 방식이다.
- 근거: `deep-research-report.md`가 Windows 운영에서 SteamCMD 기반 별도 서버 폴더를 실무적으로 편하다고 정리했고, Steam-only 비공개 서버에는 SDR이 가장 단순하고 안전하다고 정리함.
- 상태: 구현 전 최신 실행 인자와 실제 Windows 동작 확인 필요.

### 2026-06-24: Git 저장소와 원격 저장소 설정

- 결정: 로컬 Git 저장소를 `main` 브랜치로 초기화하고, 원격 저장소는 `https://github.com/cschoi724/CoreKeeperDedicatedServer.git`를 사용한다.
- 근거: 사용자가 로컬 저장소 추가와 해당 원격 저장소 push를 요청함.

### 2026-06-24: 접속 방식은 Steam 전용 SDR(Game ID)

- 결정: 친구 접속은 Steam에서만 하는 것으로 보고 SDR(Game ID)를 기본 방식으로 확정한다.
- 근거: 사용자가 Steam에서만 접속한다고 명시함.
- 영향: Direct Connect, 공유기 포트포워딩, Windows 방화벽 UDP 포트 개방은 현재 구현 우선순위에서 제외한다.

### 2026-06-24: 기존 월드는 사용자 Steam 계정 월드에서 이전

- 결정: 기존 플레이 월드는 사용자 Steam 계정의 Core Keeper 클라이언트 저장 경로에서 Dedicated Server 저장 경로로 이전하는 흐름을 설계한다.
- 근거: 사용자가 기존 월드가 본인 Steam 계정에 속해 있다고 설명함.
- 영향: 구현 시 Steam 계정 폴더와 월드 인덱스를 안전하게 선택하는 절차가 필요하다.

### 2026-06-24: Windows 실기 검증은 집 Windows 노트북의 새 Codex 세션에서 진행

- 결정: macOS 현재 세션에서는 서버 실행 검증을 하지 않고, 집 Windows 노트북에서 clone 후 새 Codex 세션으로 테스트한다.
- 근거: 실제 실행 환경이 Windows 노트북이며, 사용자가 해당 환경에서 테스트 진행이 필요하다고 판단함.

## 보류된 결정

- Windows Task Scheduler 등록을 자동화할지 수동 안내로 둘지.
- 기존 월드 이전을 자동 탐지할지, 명시 경로 입력 방식으로 둘지.
- 백업 압축/보관 정책을 기본값으로 제공할지.
- 서버 설정 파일을 템플릿에서 직접 생성할지, 첫 실행 후 생성된 파일을 수정할지.

## 열린 질문

- `Core Keeper Dedicated Server`의 최신 Windows 실행 파일명, 배치 파일명, CLI 인자는 무엇인가?
- 최신 `ServerConfig.json`의 필드명과 타입은 리서치 문서 기준과 동일한가?
- `app_update 1963720 validate`를 anonymous 로그인으로 Windows 노트북에서 문제 없이 수행할 수 있는가?
- Dedicated Server의 Game ID 출력 위치와 파일 저장 위치는 현재 버전에서도 동일한가?
- 월드 이전 시 `worlds/`, `worldinfos/`, `ServerConfig.json` 외에 반드시 옮겨야 하는 파일이 있는가?
