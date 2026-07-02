---
id: T-20260702-001
title: GSM-R2 AdapterManager PowerShell import 검증
status: done
type: docs
priority: P1
priority_reason: T-20260701-003 QA가 pwsh 미설치로 원 검증 명령을 실행하지 못했으므로 R3 착수 전 또는 병행 검증 필요
target_agent: Development Agent
required_capabilities:
  - developer_verification
depends_on:
  - T-20260701-003
allowed_paths:
  - .ai_project/reports/
  - automation/docs/
source_of_truth:
  - .ai_project/qa/T-20260701-003_qa-report.md
  - automation/docs/ADAPTER_GUIDE.md
  - automation/docs/DEVELOPMENT_PLAN.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-02
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260702-001_dev-report.md
qa_to: .ai_project/qa/T-20260702-001_qa-report.md
---

## 작업 범위

- PowerShell 또는 Windows 환경에서 `AdapterManager.psm1` import를 검증한다.
- `Get-GameServerAdapter -Game corekeeper` 결과가 manifest를 정상 반환하는지 확인한다.
- 실패 시 오류 메시지와 원인을 보고한다.

## 제외 범위

- AdapterManager 구현 변경
- Config/Path Core 분리
- SteamCMD 실행

## 검증 기준

```powershell
Import-Module .\src\Core\AdapterManager.psm1 -Force
Get-GameServerAdapter -Game corekeeper
Get-GameServerAdapterList
```

## 완료 조건

- 검증 결과가 `.ai_project/reports/T-20260702-001_dev-report.md`에 기록되어 있다.
- macOS에서 계속 `pwsh`가 없으면 Windows 검증 필요 상태로 명확히 남긴다.

## 진행 지시

- T-20260702-003 완료 후 남은 PowerShell import 미검증 리스크를 먼저 확인한다.
- 현재 환경에서 `pwsh` 또는 `powershell`이 있으면 원 검증 명령을 실행하고 결과를 보고한다.
- 현재 환경에 PowerShell이 없으면 임의 설치하지 말고, `command -v pwsh`, `command -v powershell` 결과와 Windows 검증 필요 상태를 보고한다.
- 구현 변경은 하지 않는다.

## 완료 기록

- 2026-07-02: T-20260702-003 완료 후 다음 검증 리스크 정리 Task로 승인함.
- 2026-07-02: Development Agent가 현재 macOS 환경에서 `pwsh`/`powershell` 부재를 확인하고, AdapterManager 정적 검증 결과와 Windows 검증 필요 상태를 보고서에 기록함.
- 2026-07-02: QA Agent가 PowerShell 부재 보고와 정적 대체 검증 결과를 확인하고 `PASS_WITH_RISK`로 `qa_passed` 처리함.
- 2026-07-02: Product Owner / PM Agent가 QA 결과를 확인하고 완료 처리함. Windows/PowerShell 원 검증은 잔여 리스크로 유지함.
