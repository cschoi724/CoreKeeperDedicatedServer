# AI Ops Issues

작성일: 2026-07-01
프로젝트: Core Keeper Dedicated Server Automation Template

## 1. 목적

이 문서는 AI Agent 운영 중 발견된 프로세스 문제, 모호한 규칙, 반복 실수 가능성, 개선 제안을 기록한다.

제품 기능 결함, 앱 코드 결함, QA 결과는 이 문서에 확정하지 않는다. 그런 항목은 관련 Task, report, QA 문서에 기록하고, 이 문서에는 운영 프로세스 관점의 문제만 남긴다.

## 2. 운영 원칙

- AI Ops Agent가 기본 작성자다.
- PM/Development/QA Agent의 Task 실행 상태를 직접 변경하지 않는다.
- `.ai/` 템플릿 수정이 필요하면 개선 제안으로만 기록하고 사용자 승인 후 별도 수정한다.
- 해결된 이슈도 삭제하지 않고 상태를 `resolved`로 남긴다.

## 3. Issue Log

| ID | 날짜 | 상태 | 문제 | 영향 | 임시 대응 | 개선 후보 | 담당 |
|---|---|---|---|---|---|---|---|
| OPS-20260701-001 | 2026-07-01 | open | 루트 `agents.md`의 현재 세션 역할은 `루트 관리 에이전트`인데 현재 사용자는 AI Ops Agent 역할 전환을 요청함 | 새 세션에서 역할 해석이 갈릴 수 있음 | `.ai_project/agent_registry.md`와 `current_context.md`에 AI Ops 활성 상태 기록 | 루트 `agents.md`에 `.ai_project/` 우선 확인 문구를 병합하는 패치 작성 | AI Ops Agent / PM Agent |
| OPS-20260701-002 | 2026-07-01 | open | 기존 상태/계획 문서와 `.ai_project` 운영 문서가 일부 역할을 중복함 | Agent가 기존 문서를 대체 문서로 오해할 수 있음 | `source_of_truth.md`에서 기존 문서를 제품/기술 기준으로 지정 | 중복 문서 삭제 대신 역할 분리와 링크 유지 | AI Ops Agent |
| OPS-20260701-003 | 2026-07-01 | open | `.ai_project/tasks/`가 초기화되었지만 첫 파일럿 Task가 없음 | Dev/QA Agent가 큐 기반으로 시작할 실행 항목이 없음 | `task_board.md`에 첫 Task 미등록 상태 기록 | PM Agent가 T10 Windows 실기 검증 또는 문서 QA를 `proposed` Task로 등록 | PM Agent |

## 4. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | AI Ops Issues 문서 초기화 |
