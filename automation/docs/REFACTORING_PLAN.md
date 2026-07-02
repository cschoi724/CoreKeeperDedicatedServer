# 리팩터링 계획

이 문서는 기존 Core Keeper 전용 구현을 Steam 게임 데디케이티드 서버 관리 플랫폼으로 전환하기 위한 단계별 리팩터링 계획이다.

## 1. 목표

- Core Keeper 전용 명칭과 규칙을 공통 Core에서 제거한다.
- SteamCMD, 서버 설치/업데이트, 실행/종료, 백업, 로그, 모니터링, 스케줄링을 공통 Core로 분리한다.
- Steam 게임별 차이는 Adapter로 분리한다.
- 기존 Core Keeper 기능은 첫 Adapter로 유지한다.
- 기존 스크립트 사용 흐름은 최대한 유지한다.

## 2. 비목표

- 한 번에 전체 코드를 새 구조로 갈아엎지 않는다.
- Core Keeper 지원을 제거하지 않는다.
- Windows 실기 검증 전 안전 종료, Watchdog, 자동 재시작을 임의로 확정하지 않는다.
- 두 번째 게임의 완전한 운영 지원을 첫 리팩터링 목표로 삼지 않는다.

## 3. 리팩터링 단위

### R0. 방향 전환 문서화

목적:

- 프로젝트 방향과 용어를 새 기준으로 맞춘다.
- Development/QA Agent가 이전 Core Keeper 전용 계획을 그대로 실행하지 않도록 Task Queue를 재정렬한다.

작업:

- 개발 계획 개정
- 마이그레이션 전략 작성
- Task Queue 등록
- 프로젝트 상태와 결정사항 갱신

### R1. Adapter 설계 문서화

목적:

- Core/Adapter 경계와 Adapter manifest schema를 확정한다.

작업:

- `ARCHITECTURE.md` 작성
- `ADAPTER_GUIDE.md` 작성
- Adapter 필수/선택 함수 계약 정의
- Core Keeper Adapter 예시 작성

### R2. Adapter Loader 도입

목적:

- `-Game corekeeper` 입력으로 Adapter manifest를 로드할 수 있게 한다.

작업:

- `Core/AdapterManager.psm1` 생성
- `Games/CoreKeeper/game.json` 생성
- 기존 `settings.example.json` fallback 유지

### R3. Config/Path 분리

목적:

- 설정 로딩과 경로 계산에서 Core Keeper 고정값을 제거한다.

작업:

- `Core/ConfigManager.psm1` 생성
- `Core/PathManager.psm1` 생성
- `CoreKeeper.Config.psm1`, `CoreKeeper.Paths.psm1`는 wrapper로 유지

### R4. SteamCMD 분리

목적:

- SteamCMD 설치와 app update를 게임 무관 기능으로 만든다.

작업:

- `Core/SteamCmdManager.psm1` 생성
- AppID와 login을 Adapter에서 읽도록 변경
- 기존 설치/업데이트 스크립트에 `-Game` 추가

### R5. Server/Backup/Scheduler 분리

목적:

- 서버 실행, 상태 조회, 백업, 스케줄링이 Adapter 값을 사용하도록 변경한다.

작업:

- `Core/ServerManager.psm1`
- `Core/BackupManager.psm1`
- `Core/SchedulerManager.psm1`
- Adapter 기반 launch candidates, backup targets, task name 생성

### R6. Core Keeper 전용 기능 격리

목적:

- `.world.gzip`, `ServerConfig.json`, Game ID hint 등 Core Keeper 전용 기능을 Adapter로 이동한다.

작업:

- `Games/CoreKeeper/CoreKeeper.Adapter.psm1` 작성
- `import-world.ps1`를 Adapter 위임 방식으로 변경
- Core에서 Core Keeper 문자열 제거

### R7. 테스트와 문서 재정렬

목적:

- 공통 플랫폼 검증과 Core Keeper Adapter 검증을 분리한다.

작업:

- `TESTING.md` 개정
- `WINDOWS_CODEX_RUNBOOK.md` 개정
- `README.md` 개정

### R8. 두 번째 게임 Skeleton Adapter

목적:

- 신규 게임 추가 시 Core 수정이 필요 없는지 검증한다.

작업:

- 후보 게임 하나의 `game.json` skeleton 추가
- 미구현 기능은 명확히 unsupported 처리

## 4. 리스크와 완화

| 리스크 | 영향 | 완화 |
|---|---|---|
| 기존 Core Keeper 기능 회귀 | Windows 검증 실패 | wrapper 유지, Task별 QA, Core Keeper 회귀 검증 |
| Adapter schema 과설계 | 구현 지연 | manifest 우선, 함수 계약은 선택 구현 |
| PowerShell 모듈 경로 변경으로 import 실패 | 전체 스크립트 실패 | 기존 모듈을 호환 wrapper로 유지 |
| 게임별 차이가 예상보다 큼 | Core 추상화 누수 | 첫 단계에서는 SteamCMD/백업/스케줄링처럼 명확한 공통 기능만 Core화 |
| Windows 미검증 상태에서 종료/재시작 자동화 확대 | 데이터 손상 가능성 | 안전 종료 방식 확인 전 자동 강제 재시작 금지 |

## 5. 완료 기준

- Core 모듈에서 `CoreKeeper`, `Core Keeper`, `1963720`, `Pugstorm` 문자열이 제거되어 있다.
- Core Keeper Adapter로 기존 설치/업데이트/시작/상태/백업/import 흐름을 실행할 수 있다.
- 기존 사용자 스크립트가 `-Game corekeeper` 기본값으로 동작한다.
- 신규 게임 skeleton Adapter가 Core 수정 없이 discovery된다.
- Windows 실기 검증 문서가 Core Keeper Adapter 기준으로 갱신되어 있다.
