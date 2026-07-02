---
id: T-20260701-005
title: GSM-R4 SteamCMD Core 분리
status: done
type: feature
priority: P1
priority_reason: Steam Dedicated Server 플랫폼의 핵심 공통 기능을 게임 무관 계층으로 분리
target_agent: Development Agent
required_capabilities:
  - implementation
  - developer_verification
depends_on:
  - T-20260701-004
allowed_paths:
  - automation/src/Core/
  - automation/src/CoreKeeper.SteamCmd.psm1
  - automation/scripts/install-steamcmd.ps1
  - automation/scripts/install-server.ps1
  - automation/scripts/update-server.ps1
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
report_to: .ai_project/reports/T-20260701-005_dev-report.md
qa_to: .ai_project/qa/T-20260701-005_qa-report.md
---

## 작업 범위

- `automation/src/Core/SteamCmdManager.psm1` 작성
- SteamCMD 다운로드/설치 공통화
- `app_update` 인자를 Adapter `appId`와 `login`에서 생성
- `install-server.ps1`, `update-server.ps1`에 `-Game corekeeper` 기본값 추가
- 기존 `CoreKeeper.SteamCmd.psm1` wrapper 유지

## 제외 범위

- 실제 SteamCMD 네트워크 실행 검증
- 서버 실행/백업 로직 변경
- Core Keeper AppID 변경

## 완료 조건

- Core Keeper 설치/업데이트 명령이 새 Core SteamCMD Manager를 통해 구성된다.
- 기존 명령 인자와 동등한 SteamCMD 명령이 생성된다.
- 네트워크 실행은 Windows 검증 문서에 미검증으로 남긴다.

## 검증 기준

```powershell
Import-Module .\src\Core\SteamCmdManager.psm1 -Force
.\scripts\install-server.ps1 -Game corekeeper -WhatIf
.\scripts\update-server.ps1 -Game corekeeper -WhatIf
```

## QA 확인 항목

- AppID가 하드코딩되지 않았는지
- anonymous login 정책이 Adapter에서 오는지
- 기존 Core Keeper install/update wrapper가 유지되는지

## 완료 기록

- 2026-07-02: Development Agent가 `SteamCmdManager.psm1`를 추가하고 기존 `CoreKeeper.SteamCmd.psm1`를 wrapper로 전환함.
- 2026-07-02: `install-steamcmd.ps1`, `install-server.ps1`, `update-server.ps1`에 `-Game corekeeper` 기본값과 `-WhatIf` 지원을 추가함.
- 2026-07-02: macOS 환경에 PowerShell이 없어 원 검증 명령은 수행하지 못했고, 정적 구조/하드코딩/공백 검증으로 대체함.
- 2026-07-02: QA Agent가 정적 검증 후 `PASS_WITH_RISK`로 판정하고 `qa_passed`로 전환함. PowerShell import와 `-WhatIf` 실행은 현재 환경에 `pwsh`/`powershell`이 없어 미검증.
- 2026-07-02: PM Agent가 PowerShell/SteamCMD 실검증 리스크를 후속 검증 흐름에서 추적하고 완료 확정함.
