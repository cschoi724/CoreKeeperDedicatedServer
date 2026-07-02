---
id: T-20260702-003
title: Task QA 라우팅 메타데이터 정리
status: done
type: ops
priority: P2
priority_reason: T-20260701-002와 T-20260701-003 QA에서 target_agent와 QA 상태 전이 규칙 불일치가 반복 지적됨
target_agent: PM Agent
required_capabilities:
  - task_queue_management
  - documentation
depends_on:
  - T-20260701-003
allowed_paths:
  - .ai_project/tasks/
  - .ai_project/task_board.md
  - .ai_project/workflow_overrides.md
source_of_truth:
  - .ai/task_queue.md
  - .ai_project/qa/T-20260701-002_qa-report.md
  - .ai_project/qa/T-20260701-003_qa-report.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-02
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260702-003_pm-report.md
qa_to: .ai_project/qa/T-20260702-003_qa-report.md
---

## 작업 범위

- 현재 Task Queue에서 QA 상태 전이 시 `target_agent`를 어떻게 기록할지 프로젝트 운영 기준을 정리한다.
- `.ai/` 템플릿은 수정하지 않고, 프로젝트별 override 또는 Task 작성 규칙에 반영한다.
- 후속 Task에서 QA Agent가 규칙 위반 없이 검증할 수 있도록 메타데이터 처리 기준을 남긴다.

## 제외 범위

- `.ai/` 운영 템플릿 수정
- 제품 코드 또는 자동화 스크립트 수정

## 완료 조건

- QA 전환 시 `target_agent` 처리 기준이 `.ai_project/`에 문서화되어 있다.
- 새 Task 작성 시 PM Agent가 따를 규칙이 명확하다.

## 진행 지시

- T-20260701-002~006 QA에서 반복 지적된 `target_agent`와 QA 상태 전이 불일치 문제를 정리한다.
- `.ai/` 템플릿은 수정하지 않고, 프로젝트별 기준 문서를 `.ai_project/workflow_overrides.md` 또는 Task 작성 규칙 형태로 남긴다.
- 기존 완료 Task의 이력은 임의로 대량 수정하지 말고, 후속 Task 작성/전환 기준을 명확히 하는 데 집중한다.
- Task 상태가 `ready_for_qa` 또는 `qa_in_progress`가 될 때 `target_agent`, 담당 Agent 표기, 보드 표기를 어떻게 처리할지 규칙화한다.

## 완료 기록

- 2026-07-02: T-20260702-002 완료 후 다음 즉시 진행 가능한 PM 작업으로 승인함.
- 2026-07-02: PM Agent가 `.ai_project/workflow_overrides.md`에 `target_agent`와 QA 상태 전이/Task Board 표기 기준을 문서화하고 `ready_for_qa`로 전환함.
- 2026-07-02: QA Agent가 QA 라우팅 메타데이터 기준을 검증하고 `PASS`로 `qa_passed` 처리함.
- 2026-07-02: Product Owner / PM Agent가 QA 결과를 확인하고 완료 처리함.
