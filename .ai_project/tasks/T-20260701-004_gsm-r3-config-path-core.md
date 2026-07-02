---
id: T-20260701-004
title: GSM-R3 Config/Path Core 분리
status: done
type: feature
priority: P1
priority_reason: 이후 SteamCMD/Server/Backup 분리의 기반이 되는 공통 설정과 경로 계층 필요
target_agent: Development Agent
required_capabilities:
  - implementation
  - developer_verification
depends_on:
  - T-20260701-003
allowed_paths:
  - automation/src/Core/
  - automation/src/Compatibility/
  - automation/src/CoreKeeper.Config.psm1
  - automation/src/CoreKeeper.Paths.psm1
  - automation/docs/
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/MIGRATION_STRATEGY.md
  - automation/docs/ARCHITECTURE.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-004_dev-report.md
qa_to: .ai_project/qa/T-20260701-004_qa-report.md
---

## 작업 범위

- `automation/src/Core/ConfigManager.psm1` 작성
- `automation/src/Core/PathManager.psm1` 작성
- 기존 `Get-CKSettings`, `Get-CKPathSet` 호환 유지
- 기존 `settings.local.json` fallback 유지
- 문서에 설정 우선순위 기록

## 제외 범위

- SteamCMD 실행 로직 변경
- 서버 실행/백업 로직 변경
- 기존 설정 파일 삭제

## 완료 조건

- 새 Core 설정/경로 함수가 Core Keeper Adapter 값을 읽는다.
- 기존 Core Keeper 모듈 import가 깨지지 않는다.
- Core Keeper 전용 경로 상수는 Adapter 또는 compatibility 계층으로 이동한다.

## 검증 기준

```powershell
Import-Module .\src\Core\ConfigManager.psm1 -Force
Import-Module .\src\Core\PathManager.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
```

## QA 확인 항목

- 설정 병합 순서가 명확한지
- 기존 사용자 설정이 무시되지 않는지
- 경로 생성이 사용자 데이터 이동을 시도하지 않는지

## 완료 기록

- 2026-07-02: Development Agent가 `ConfigManager.psm1`, `PathManager.psm1`를 추가하고 기존 `CoreKeeper.Config.psm1`, `CoreKeeper.Paths.psm1`를 wrapper로 전환함.
- 2026-07-02: macOS 환경에 PowerShell이 없어 import 실행 검증은 수행하지 못했고, JSON/정적 구조/공백 검증으로 대체함.
- 2026-07-02: QA Agent가 Core `PathManager.psm1`의 Core Keeper 전용 경로 상수 잔존으로 `FAIL` 판정하고 재작업 요청함. 상세 내용은 `.ai_project/qa/T-20260701-004_qa-report.md` 참조.
- 2026-07-02: Product Owner가 재작업 진행을 승인하여 PM Agent가 상태를 `approved`로 되돌림.
- 2026-07-02: Development Agent가 Core `PathManager.psm1`의 Core Keeper 전용 경로 계산을 `CoreKeeper.Paths.psm1` wrapper로 이동하고 재검증 후 QA 대기 상태로 전환함.
- 2026-07-02: QA Agent가 재검증 후 `PASS_WITH_RISK`로 판정하고 `qa_passed`로 전환함. PowerShell import는 현재 환경에 `pwsh`/`powershell`이 없어 미검증.
- 2026-07-02: PM Agent가 PowerShell import 미검증 리스크를 후속 검증 Task로 추적하고 완료 확정함.

## 재작업 범위

- `automation/src/Core/PathManager.psm1`에서 Core Keeper 전용 경로 계산을 제거한다.
- Core `PathManager`는 공통 경로만 반환한다.
  - `AutomationRoot`
  - `GameId`
  - `ServerInstallPath`
  - `SteamCmdPath`
  - `SteamCmdExe`
  - `BackupRoot`
  - `DedicatedServerDataRoot`
- `WorldsPath`, `WorldInfosPath`, `ServerConfigPath`는 `automation/src/CoreKeeper.Paths.psm1` compatibility wrapper 또는 후속 Core Keeper Adapter 계층에서 계산한다.
- 이번 재작업에서는 기존 `CoreKeeper.Paths.psm1` wrapper로 옮기는 방식을 우선한다.
- 수정 후 QA 보고서의 정적 검증 기준을 다시 실행한다.
