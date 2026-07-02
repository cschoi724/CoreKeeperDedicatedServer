---
id: T-20260701-003
title: GSM-R2 Core Keeper Adapter manifest 도입
status: done
type: feature
priority: P1
priority_reason: 게임별 값을 설정/Adapter로 분리하는 첫 구현 단계
target_agent: Development Agent
required_capabilities:
  - implementation
  - documentation
depends_on:
  - T-20260701-002
allowed_paths:
  - automation/config/
  - automation/src/Core/
  - automation/src/Games/
  - automation/docs/
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/ARCHITECTURE.md
  - automation/docs/ADAPTER_GUIDE.md
  - automation/docs/MIGRATION_STRATEGY.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-003_dev-report.md
qa_to: .ai_project/qa/T-20260701-003_qa-report.md
---

## 작업 범위

- `automation/config/manager.example.json` 추가
- `automation/config/games/corekeeper.example.json` 추가
- `automation/src/Core/AdapterManager.psm1` 추가
- `automation/src/Games/CoreKeeper/game.json` 추가
- `-Game corekeeper` 기준 Adapter 로딩 함수 구현
- 기존 `settings.example.json` fallback 정책 문서화

## 제외 범위

- 기존 `CoreKeeper.*.psm1` 삭제
- SteamCMD 실행 로직 변경
- 서버 설치/실행 동작 변경

## 완료 조건

- Core Keeper Adapter manifest를 로드할 수 있다.
- 기존 설정 파일은 삭제되지 않는다.
- Adapter 로딩 실패 시 명확한 오류를 출력한다.

## 검증 기준

```powershell
Import-Module .\src\Core\AdapterManager.psm1 -Force
Get-GameServerAdapter -Game corekeeper
```

macOS에서는 PowerShell 미설치 가능성을 기록하고 정적 검증으로 대체한다.

## QA 확인 항목

- manifest JSON이 유효한지
- 기존 설정 호환 정책이 유지되는지
- 새 경로가 `.gitignore` 정책과 충돌하지 않는지

## 완료 기록

- 2026-07-02: Development Agent가 Core Keeper Adapter manifest, manager/game example 설정, `AdapterManager.psm1`를 추가하고 정적 검증 후 QA 대기 상태로 전환함.
- 2026-07-02: QA Agent가 정적 검증 후 `PASS_WITH_RISK`로 판정하고 `qa_passed`로 전환함. PowerShell import는 현재 환경에 `pwsh`가 없어 미검증.
- 2026-07-02: PM Agent가 QA 잔여 리스크를 후속 Task로 분리하고 완료 확정함.
