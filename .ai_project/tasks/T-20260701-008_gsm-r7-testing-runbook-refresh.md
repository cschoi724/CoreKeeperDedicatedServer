---
id: T-20260701-008
title: GSM-R7 테스트와 Windows Runbook 재정렬
status: done
type: docs
priority: P2
priority_reason: 리팩터링 후 Windows 실기 검증 기준을 공통 Core와 Core Keeper Adapter로 분리해야 함
target_agent: Development Agent
required_capabilities:
  - documentation
  - developer_verification
depends_on:
  - T-20260701-007
allowed_paths:
  - automation/README.md
  - automation/docs/TESTING.md
  - automation/docs/WINDOWS_CODEX_RUNBOOK.md
  - automation/docs/STATUS.md
  - automation/docs/CHANGELOG.md
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/MIGRATION_STRATEGY.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-008_dev-report.md
qa_to: .ai_project/qa/T-20260701-008_qa-report.md
---

## 작업 범위

- `automation/docs/TESTING.md`를 공통 Core 검증과 Core Keeper Adapter 검증으로 분리
- `automation/docs/WINDOWS_CODEX_RUNBOOK.md`를 `-Game corekeeper` 기준으로 갱신
- `automation/README.md`를 Steam Game Server Manager 기준으로 갱신
- `STATUS.md`, `CHANGELOG.md`에 리팩터링 진행 상태 기록

## 제외 범위

- 기능 구현
- Windows 실기 검증 직접 수행
- 두 번째 게임 Adapter 추가

## 완료 조건

- Windows 검증자가 새 구조 기준으로 명령을 실행할 수 있다.
- Core Keeper Adapter 회귀 검증 항목이 명확하다.
- macOS에서 검증하지 않는 항목이 명확히 표시되어 있다.

## 검증 기준

```bash
rg -n "Core Keeper 전용|T10|Steam Game Server Manager|Adapter" automation/README.md automation/docs/TESTING.md automation/docs/WINDOWS_CODEX_RUNBOOK.md
git diff --check
```

## QA 확인 항목

- Windows 실행 명령이 기존 기능을 빠뜨리지 않는지
- 미검증 항목과 열린 질문이 숨겨지지 않았는지

## 재작업 지시

- `automation/docs/TESTING.md`와 `automation/docs/WINDOWS_CODEX_RUNBOOK.md`에 남아 있는 아래 문서 명령을 실제 함수 계약에 맞게 수정한다.

```powershell
New-GameServerSteamCmdAppUpdateArguments -Game corekeeper
```

- 권장 수정 형태:

```powershell
$settings = Get-GameServerSettings -Game corekeeper
New-GameServerSteamCmdAppUpdateArguments -Settings $settings
```

- 이번 Task 범위는 문서/Runbook 정렬이므로 `New-GameServerSteamCmdAppUpdateArguments` 함수에 `-Game` wrapper를 추가하지 않는다.
- 문서에 포함된 다른 PowerShell 함수 예제도 실제 함수 시그니처와 대조한다.
- 재작업 후 아래 검증을 수행한다.

```bash
rg -n "New-GameServerSteamCmdAppUpdateArguments -Game" automation/docs
rg -n "New-GameServerSteamCmdAppUpdateArguments" automation/docs/TESTING.md automation/docs/WINDOWS_CODEX_RUNBOOK.md automation/src
git diff --check
```

## 완료 기록

- 2026-07-02: Development Agent가 README, TESTING, WINDOWS_CODEX_RUNBOOK을 Steam Game Server Manager와 `corekeeper` Adapter 기준으로 재정렬함.
- 2026-07-02: Windows 검증 항목을 공통 Core 검증과 Core Keeper Adapter 회귀 검증으로 분리함.
- 2026-07-02: macOS 환경에서 문서 검색과 `git diff --check`로 정적 검증을 수행함.
- 2026-07-02: QA Agent가 문서 명령과 실제 함수 계약을 대조한 결과 `New-GameServerSteamCmdAppUpdateArguments -Game corekeeper` 불일치를 확인해 `rework_requested` 처리함.
- 2026-07-02: Product Owner / PM Agent가 QA 지적사항 기준으로 재작업 범위를 명시하고 T-20260701-008 재진행을 승인함.
- 2026-07-02: Development Agent가 `New-GameServerSteamCmdAppUpdateArguments` 문서 명령을 실제 `-Settings` 계약에 맞게 수정하고 정적 재검증 후 `ready_for_qa`로 변경함.
- 2026-07-02: QA Agent가 재검증에서 문서 명령 계약 불일치 해소를 확인하고 `PASS_WITH_RISK`로 `qa_passed` 처리함.
- 2026-07-02: Product Owner / PM Agent가 QA 결과를 확인하고 T-20260701-008을 완료 처리함. Windows 실기 검증은 후속 검증 리스크로 유지함.
