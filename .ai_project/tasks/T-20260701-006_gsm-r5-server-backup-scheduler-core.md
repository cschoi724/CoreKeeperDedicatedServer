---
id: T-20260701-006
title: GSM-R5 Server/Backup/Scheduler Core 분리
status: done
type: feature
priority: P2
priority_reason: 사용자가 체감하는 운영 기능을 Adapter 기반으로 전환하는 중간 단계
target_agent: Development Agent
required_capabilities:
  - implementation
  - developer_verification
depends_on:
  - T-20260701-005
allowed_paths:
  - automation/src/Core/
  - automation/src/CoreKeeper.Server.psm1
  - automation/src/CoreKeeper.Backup.psm1
  - automation/src/CoreKeeper.Tasks.psm1
  - automation/scripts/start-server.ps1
  - automation/scripts/stop-server.ps1
  - automation/scripts/status-server.ps1
  - automation/scripts/backup-server.ps1
  - automation/scripts/register-task.ps1
  - automation/scripts/unregister-task.ps1
  - automation/scripts/enable-task.ps1
  - automation/scripts/disable-task.ps1
  - automation/scripts/register-restart-task.ps1
  - automation/scripts/unregister-restart-task.ps1
  - automation/docs/
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/REFACTORING_PLAN.md
  - automation/docs/MIGRATION_STRATEGY.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-006_dev-report.md
qa_to: .ai_project/qa/T-20260701-006_qa-report.md
---

## 작업 범위

- `Core/ServerManager.psm1` 작성
- `Core/BackupManager.psm1` 작성
- `Core/SchedulerManager.psm1` 작성
- 실행 후보와 프로세스 패턴을 Adapter에서 읽도록 변경
- 백업 대상을 Adapter에서 읽도록 변경
- Task Scheduler 이름과 설명을 게임 ID 기반으로 변경
- 기존 Core Keeper wrapper 유지

## 제외 범위

- Core Keeper 월드 import 리팩터링
- 안전 종료 자동화 확정
- Watchdog 구현

## 완료 조건

- `start/status/backup/task` 계열 스크립트가 `-Game corekeeper`를 받는다.
- 기존 인자 없는 명령은 기본 `corekeeper`로 동작한다.
- 백업 대상은 Adapter manifest에서 온다.

## 검증 기준

```powershell
.\scripts\status-server.ps1 -Game corekeeper
.\scripts\backup-server.ps1 -Game corekeeper -WhatIf
.\scripts\register-task.ps1 -Game corekeeper -WhatIf
```

## QA 확인 항목

- 안전 종료 미검증 경고가 유지되는지
- 백업이 사용자 데이터 이동/삭제를 하지 않는지
- Task Scheduler 등록이 관리자 권한 요구를 명확히 안내하는지

## 완료 기록

- 2026-07-02: Development Agent가 `ServerManager.psm1`, `BackupManager.psm1`, `SchedulerManager.psm1`를 추가하고 기존 Core Keeper 모듈을 wrapper로 전환함.
- 2026-07-02: `start/status/backup/task` 계열 스크립트에 `-Game corekeeper` 기본값을 추가하고 백업/스케줄러 계열에 `-WhatIf` 전달을 추가함.
- 2026-07-02: macOS 환경에 PowerShell이 없어 원 검증 명령은 수행하지 못했고, 정적 구조/하드코딩/공백 검증으로 대체함.
- 2026-07-02: QA Agent가 `CoreKeeper.Server.psm1` wrapper의 missing `CoreKeeper.Paths.psm1` import로 `FAIL` 판정하고 재작업 요청함. 상세 내용은 `.ai_project/qa/T-20260701-006_qa-report.md` 참조.
- 2026-07-02: Product Owner가 재작업 진행을 승인하여 PM Agent가 상태를 `approved`로 되돌림.
- 2026-07-02: Development Agent가 `CoreKeeper.Server.psm1`에 `CoreKeeper.Paths.psm1` import를 추가하고 정적 재검증 후 `ready_for_qa`로 변경함.
- 2026-07-02: QA Agent가 재검증 후 `PASS_WITH_RISK`로 판정하고 `qa_passed`로 전환함. PowerShell 실행 검증은 현재 환경에 `pwsh`/`powershell`이 없어 미검증.
- 2026-07-02: PM Agent가 Windows/PowerShell 실검증 리스크를 후속 검증 흐름에서 추적하고 완료 확정함.

## 재작업 범위

- `automation/src/CoreKeeper.Server.psm1` wrapper에서 `CoreKeeper.Paths.psm1`를 import한다.
- `Get-CKServerStatus`가 호출하는 `Get-CKPathSet` 의존성이 wrapper 단독 import 상황에서도 해소되도록 한다.
- Core `ServerManager.psm1`에는 Core Keeper 전용 경로 상수를 추가하지 않는다.
- 수정 후 QA 보고서의 정적 검증 기준을 다시 실행한다.
