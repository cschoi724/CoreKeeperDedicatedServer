---
id: T-20260702-002
title: Steam Game Server Manager 네이밍 정리
status: done
type: docs
priority: P1
priority_reason: 제품 방향이 Core Keeper 전용에서 범용 Steam Game Server Manager로 바뀌었으므로 상위 문서와 Agent 지침 네이밍 정리 필요
target_agent: PM Agent
required_capabilities:
  - documentation
depends_on:
  - T-20260701-003
allowed_paths:
  - agents.md
  - automation/agents.md
  - docs/
  - automation/docs/
  - .ai_project/
source_of_truth:
  - docs/PROJECT_DECISIONS.md
  - docs/PROJECT_STATUS.md
  - automation/docs/ARCHITECTURE.md
  - automation/docs/MIGRATION_STRATEGY.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-02
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260702-002_pm-report.md
qa_to: .ai_project/qa/T-20260702-002_qa-report.md
---

## 작업 범위

- 루트 `agents.md`, `automation/agents.md`, `docs/README.md`의 프로젝트명과 목표 표현을 Steam Game Server Manager 기준으로 정리한다.
- Core Keeper는 "첫 Adapter / 회귀 검증 기준"으로 표현하고, 범용 Core 영역의 제품명으로 사용하지 않는다.
- 기존 Core Keeper 리서치/제품 요구사항 문서는 이력 문서로 보존하되 현재 방향과 충돌하는 안내 문구를 갱신한다.

## 제외 범위

- `automation/src/CoreKeeper.*.psm1` 파일명 변경
- `automation/scripts/*.ps1` 파일명 변경
- GitHub 원격 저장소 rename
- Core Keeper Adapter 디렉토리명 변경

## 완료 조건

- 공통 프로젝트 설명은 Steam Game Server Manager를 기준으로 한다.
- Core Keeper 전용 명칭은 Adapter, 호환 wrapper, 리서치/이력 문맥에만 남는다.
- 기존 개발 Task와 충돌하지 않도록 구현 파일 네이밍은 변경하지 않는다.

## 검증 기준

```bash
rg -n "Core Keeper Dedicated Server Automation Template|Core Keeper 전용 자동화 템플릿|CoreKeeper Dedicated" agents.md automation/agents.md docs automation/docs
git diff --check
```

## 진행 지시

- T-20260701-008 완료 이후 상위 문서와 Agent 지침의 제품명/목표 표현을 먼저 정리한다.
- Core Keeper는 제품명으로 쓰지 않고 "첫 번째 Adapter / 회귀 검증 기준 / 호환 wrapper" 문맥에서만 유지한다.
- 구현 파일명과 기존 wrapper 파일명은 이번 Task에서 변경하지 않는다.
- 변경 후 현재 방향과 과거 리서치/이력 문서가 충돌하지 않도록 문맥을 명확히 표시한다.

## 완료 기록

- 2026-07-02: Product Owner / PM Agent가 T-20260701-008 완료 후 다음 즉시 진행 가능한 P1 작업으로 승인함.
- 2026-07-02: PM Agent가 작업에 착수하고 문서 네이밍 정리 lock을 획득함.
- 2026-07-02: PM Agent가 루트/자동화 Agent 지침, 상태 문서, AI 운영 문서의 프로젝트 표기를 Steam Game Server Manager 기준으로 정리하고 `ready_for_qa`로 전환함.
- 2026-07-02: QA Agent가 네이밍 정리 범위를 검증하고 `PASS_WITH_RISK`로 `qa_passed` 처리함.
- 2026-07-02: Product Owner / PM Agent가 QA 결과를 확인하고 완료 처리함. 원문 리서치와 저장소 URL의 Core Keeper 명칭은 보존 범위로 유지함.
