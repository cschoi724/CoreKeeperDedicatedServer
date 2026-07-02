---
id: T-20260701-002
title: GSM-R1 Adapter 아키텍처 문서 작성
status: done
type: docs
priority: P1
priority_reason: 구현 리팩터링 전에 Core/Adapter 경계와 Adapter 계약을 확정해야 함
target_agent: Development Agent
required_capabilities:
  - documentation
  - technical_review
depends_on:
  - T-20260701-001
allowed_paths:
  - automation/docs/
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/REFACTORING_PLAN.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-002_dev-report.md
qa_to: .ai_project/qa/T-20260701-002_qa-report.md
---

## 작업 범위

- `automation/docs/ARCHITECTURE.md` 작성
- `automation/docs/ADAPTER_GUIDE.md` 작성
- Core 책임과 Adapter 책임 구분
- Adapter manifest schema 초안 정의
- Adapter 필수/선택 PowerShell 함수 계약 정의
- Core Keeper Adapter 예시 포함

## 제외 범위

- PowerShell 코드 구현
- 기존 모듈명 변경
- 두 번째 게임 Adapter 추가

## 완료 조건

- 신규 게임 추가자가 Adapter에 무엇을 작성해야 하는지 이해할 수 있다.
- Core 모듈이 게임별 상수를 직접 알지 않는다는 원칙이 문서화되어 있다.
- Core Keeper 전용 내용은 Adapter 예시 섹션에만 등장한다.

## 검증 기준

```bash
test -f automation/docs/ARCHITECTURE.md
test -f automation/docs/ADAPTER_GUIDE.md
rg -n "CoreKeeper|Core Keeper|1963720|Pugstorm" automation/docs/ARCHITECTURE.md automation/docs/ADAPTER_GUIDE.md
git diff --check
```

## QA 확인 항목

- Adapter 계약이 과도하게 복잡하지 않은지
- 기존 Core Keeper 기능을 보존할 수 있는지
- 후속 구현 Task의 경계가 명확한지

## 완료 기록

- 2026-07-02: Development Agent가 `automation/docs/ARCHITECTURE.md`, `automation/docs/ADAPTER_GUIDE.md`를 작성하고 정적 검증 후 QA 대기 상태로 전환함.
- 2026-07-02: QA Agent가 manifest 계약 불일치로 `FAIL` 판정하고 재작업 요청함. 상세 내용은 `.ai_project/qa/T-20260701-002_qa-report.md` 참조.
- 2026-07-02: Product Owner가 재작업 진행을 승인하여 PM Agent가 상태를 `approved`로 되돌림.
- 2026-07-02: Development Agent가 `DEVELOPMENT_PLAN.md`의 manifest 초안을 `ADAPTER_GUIDE.md` 계약과 일치시켜 재검증 후 QA 대기 상태로 전환함.
- 2026-07-02: QA Agent가 재검증 후 `PASS_WITH_RISK`로 판정하고 `qa_passed`로 전환함. 남은 리스크는 Task routing metadata 정리 필요.
- 2026-07-02: Product Owner 지시에 따라 PM Agent가 완료 확정하고 `done` 처리함.

## 재작업 범위

- `automation/docs/ADAPTER_GUIDE.md`를 manifest 계약의 기준 문서로 둔다.
- `automation/docs/DEVELOPMENT_PLAN.md`의 Adapter Manifest 초안을 `ADAPTER_GUIDE.md`와 일치시킨다.
- 특히 아래 불일치를 해소한다.
  - `logs.joinCodePatterns`와 `logs.statusPatterns` 중 하나로 통일
  - `features.directConnect`, `features.gracefulStop`, `features.healthCheck` 필드 계약 통일
- 수정 후 QA 보고서의 검증 기준을 다시 실행한다.
