# automation 변경 기록

## 2026-06-24

- T1 자동화 골격 추가: `README.md`, `config/settings.example.json`, 공통/설정/경로 PowerShell 모듈 생성
- T1 검증 문서 추가: Windows PowerShell 모듈 import 확인 명령 기록
- T2 SteamCMD 자동 설치 추가: `scripts/install-steamcmd.ps1`, `src/CoreKeeper.SteamCmd.psm1` 생성
- T2 검증 문서 추가: SteamCMD 설치 확인 명령과 macOS 미검증 항목 기록
- T3 Dedicated Server 설치/업데이트 추가: `scripts/install-server.ps1`, `scripts/update-server.ps1` 생성
- T3 SteamCMD 공통 실행 함수 추가: `app_update 1963720 validate` 실행, output log, exit code 에러 처리 기록
- T4 수동 서버 운영 추가: `scripts/start-server.ps1`, `scripts/status-server.ps1`, `scripts/stop-server.ps1`, `src/CoreKeeper.Server.psm1` 생성
- T4 상태 확인 추가: Dedicated Server 데이터 폴더, 실행 후보, 실행 프로세스, Game ID 로그 힌트 확인
- T5 서버 데이터 백업 추가: `scripts/backup-server.ps1`, `src/CoreKeeper.Backup.psm1` 생성
- T5 백업 정책 추가: `worlds`, `worldinfos`, `ServerConfig.json` 백업, 누락 대상 skip 메시지, manifest 기록
- T6 기존 월드 import 추가: `scripts/import-world.ps1`, `src/CoreKeeper.World.psm1` 생성
- T6 import 안전 정책 추가: 단일 `.world.gzip` 검증, import 전 백업 강제, 기존 대상 덮어쓰기 명시 확인, 원본 파일 보존
- T7 자동 실행 작업 관리 추가: `scripts/register-task.ps1`, `scripts/unregister-task.ps1`, `scripts/enable-task.ps1`, `scripts/disable-task.ps1`, `src/CoreKeeper.Tasks.psm1` 생성
- T7 Task Scheduler 정책 추가: 현재 사용자 AtLogOn 작업, `start-server.ps1` 실행 대상, 관리자 권한 안내
- T8 재시작 예약 작업 추가: `scripts/register-restart-task.ps1`, `scripts/unregister-restart-task.ps1` 생성
- T8 안전 제한 추가: `HH:mm` 시간 검증, 강제 종료 없는 보수적 예약 작업, 안전 종료 미검증 문서화
- T9 사용자 문서 정리: `automation/README.md`를 현재 스크립트 이름과 Windows 사용 순서 기준으로 재작성
- T9 테스트 문서 정리: `docs/TESTING.md`를 Windows 실기 검증 명령 순서, 미검증 항목, 현재 범위 밖 항목 중심으로 재구성
- Windows Codex 실기 검증 Runbook 추가: Codex 세션 시작, 설치, 실행, 백업, import, Task Scheduler 검증, 결과 커밋 절차 정리
- Dedicated Server 플레이어 0명 sleep/대기 동작과 T10 이후 운영 확장 후보를 문서 기준으로 연결
- T10 로그/증거 수집 체크리스트 추가: 실행 파일명, Game ID, 데이터 경로, 로그, sleep/idle, 안전 종료, 실행 중 백업, Task Scheduler 동작 확인
- 자동 백업, Watchdog, Discord Webhook, 상태 조회 확장을 T10 이후 2차 범위로 분리
- 작업 영역 `agents.md` 추가
- 개발 계획, 상태, 테스트 문서 추가
- 실제 구현은 보류하고 열린 질문을 문서화
- Git 저장소 초기화 상태 반영
- Steam 전용 SDR(Game ID) 운영 결정 반영
- 기본 빈 월드/기존 월드 import 설계 문서 추가
- 설치/백업 경로, SteamCMD 자동 설치, 기본 수동 실행, 선택 자동 실행/재시작, 기본 빈 월드/import 방향 반영
- 개발 계획을 T1-T10 작업 단위, 산출 파일, 완료 조건, 검증 명령, 권장 커밋 단위로 구체화

## 2026-07-01

- 제품 방향을 기존 Core Keeper 중심 자동화 템플릿에서 Steam Game Server Manager로 전환
- `DEVELOPMENT_PLAN.md`를 Core/Adapter 아키텍처 기준으로 전면 개정
- `REFACTORING_PLAN.md` 추가: GSM-R0~GSM-R8 단계별 리팩터링 계획 수립
- `MIGRATION_STRATEGY.md` 추가: 기존 Core Keeper 기능 호환, 설정 fallback, 롤백 전략 수립
- `.ai_project/tasks/`에 방향 전환과 단계별 구현 Task를 `proposed` 상태로 등록

## 2026-07-02

- GSM-R1 Adapter 아키텍처 문서 추가: `ARCHITECTURE.md`에서 Core/Adapter 책임, 설정 계층, 호환 계층, 오류 처리 기준 정의
- GSM-R1 Adapter 작성 가이드 추가: `ADAPTER_GUIDE.md`에서 manifest schema 초안, 필수/선택 PowerShell 함수 계약, 신규 Adapter 추가 절차 정의
- GSM-R1 QA 재작업: `DEVELOPMENT_PLAN.md`의 manifest 로그/feature 필드를 `ADAPTER_GUIDE.md`의 `statusPatterns`, `gracefulStop`, `healthCheck` 계약과 일치시킴
- GSM-R2 Core Keeper Adapter manifest 도입: `config/manager.example.json`, `config/games/corekeeper.example.json`, `src/Games/CoreKeeper/game.json`, `src/Core/AdapterManager.psm1` 추가
- 로컬 manager/game 설정 파일이 커밋되지 않도록 `automation/.gitignore`에 `manager.local.json`, `games/*.local.json` 패턴 추가
- GSM-R3 Config/Path Core 분리: `src/Core/ConfigManager.psm1`, `src/Core/PathManager.psm1` 추가
- 기존 `CoreKeeper.Config.psm1`, `CoreKeeper.Paths.psm1`는 기존 함수명을 유지하는 compatibility wrapper로 전환
- 설정 우선순위를 `MIGRATION_STRATEGY.md`에 기록하고 `settings.local.json` fallback 유지
- GSM-R3 QA 재작업: Core `PathManager.psm1`에서 Core Keeper 전용 `worlds`, `worldinfos`, `ServerConfig.json` 경로 계산을 제거하고 `CoreKeeper.Paths.psm1` wrapper로 이동
- GSM-R4 SteamCMD Core 분리: `src/Core/SteamCmdManager.psm1` 추가, 기존 `CoreKeeper.SteamCmd.psm1`는 wrapper로 전환
- `install-steamcmd.ps1`, `install-server.ps1`, `update-server.ps1`에 `-Game corekeeper` 기본값과 `-WhatIf` 지원 추가
- SteamCMD `app_update` 명령의 AppID와 login 값을 Adapter 기반 설정에서 읽도록 변경
- GSM-R5 Server/Backup/Scheduler Core 분리: `src/Core/ServerManager.psm1`, `src/Core/BackupManager.psm1`, `src/Core/SchedulerManager.psm1` 추가
- 기존 `CoreKeeper.Server.psm1`, `CoreKeeper.Backup.psm1`, `CoreKeeper.Tasks.psm1`는 wrapper로 전환
- `start/status/backup/task` 계열 스크립트에 `-Game corekeeper` 기본값 추가, 백업/스케줄러 계열에 `-WhatIf` 전달 추가
- GSM-R5 QA 재작업: `CoreKeeper.Server.psm1` wrapper에서 `Get-CKPathSet` 의존성을 충족하도록 `CoreKeeper.Paths.psm1` import 추가
- GSM-R6 Core Keeper 월드 import Adapter 격리: `src/Games/CoreKeeper/CoreKeeper.Adapter.psm1` 추가, `.world.gzip` 검증과 `ServerConfig.json` world index 패치 로직 이동
- `import-world.ps1`에 `-Game corekeeper` 기본값과 `-WhatIf` 전달을 추가하고 `CoreKeeper.World.psm1`를 Adapter dispatcher/wrapper로 전환
- GSM-R7 테스트/Runbook 재정렬: `README.md`, `docs/TESTING.md`, `docs/WINDOWS_CODEX_RUNBOOK.md`를 Steam Game Server Manager 기준으로 갱신
- Windows 검증 기준을 공통 Core 검증과 Core Keeper Adapter 회귀 검증으로 분리하고 T10 증거 수집 항목을 새 구조에 맞게 정리
- GSM-R7 QA 재작업: `New-GameServerSteamCmdAppUpdateArguments` 문서 예제를 실제 `-Settings` 함수 계약에 맞게 수정
- T-20260702-002 네이밍 정리: 루트/자동화 Agent 지침, 상태 문서, AI 운영 문서의 프로젝트 표기를 Steam Game Server Manager 기준으로 갱신
- GSM-R8 두 번째 게임 skeleton Adapter 추가: `src/Games/Valheim/game.json`, `config/games/valheim.example.json` 추가
- Valheim skeleton은 manifest discovery 검증용으로 추가했으며 world import, config patch, graceful stop, health check는 unsupported로 명시
