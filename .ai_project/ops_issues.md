# AI Ops Issues

작성일: 2026-07-01
프로젝트: Steam Game Server Manager

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
| OPS-20260702-004 | 2026-07-02 | resolved | `.ai_project/workflow_overrides.md`가 `target_agent`를 산출물 책임 Agent로 재정의해 `.ai/task_queue.md`의 Target Agent Hard Stop과 충돌함 | PM/Development/QA 라우팅 기준이 흐려지고, 사용자 오지시 때 잘못된 Agent가 실행할 수 있음 | `.ai` 기준 커밋 `59e0533`으로 감사 후 PM Agent가 `workflow_overrides.md`를 `.ai/task_queue.md` 기준으로 보정 | `target_agent`는 실행 권한 필드로 복구하고 산출물 책임은 Task 본문/report로 분리 완료 | AI Ops Agent / PM Agent |
| OPS-20260702-005 | 2026-07-02 | resolved | `ready_for_qa` 상태였던 T-20260701-009의 `target_agent`가 Development Agent로 남아 있어 QA Agent 실행 가능 조건과 충돌함 | QA Agent가 `.ai/task_queue.md` 기준으로 해당 Task를 집어 진행할 수 없음 | PM Agent가 T-20260701-009 QA 단계 실행 담당을 QA Agent로 보정하고 QA/PM 완료 처리 | T-20260701-009는 `done`, `target_agent: QA Agent`, 산출물 책임은 Task 본문에 보존 | PM Agent |
| OPS-20260702-006 | 2026-07-02 | resolved | `.ai` 커밋 `59e0533`에 추가된 “다음 작업 안내 시 Task ID, 상태, 담당 Agent, 담당 근거, 열 세션, 사용자 요청 표시” 기준이 `.ai_project` 운영 문서에 아직 반영되지 않음 | Product Owner가 다음 작업을 어떤 Agent 세션에서 어떤 문장으로 요청해야 하는지 혼동할 수 있음 | `current_context.md`와 `task_board.md`에 최신 다음 작업 안내 형식 반영 | 현재 다음 작업 안내는 Task ID/status/담당 Agent/근거/열 세션/사용자 요청 문장을 포함 | PM Agent |

## 4. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | AI Ops Issues 문서 초기화 |
| 2026-07-02 | `.ai` 커밋 `a638dd4` 기준 `.ai_project` 동기화 감사 이슈 추가 |
| 2026-07-02 | `.ai` 커밋 `59e0533` 기준 다음 작업 담당 Agent 안내 보강 이슈 갱신 |
| 2026-07-02 | `.ai` 커밋 `59e0533` 충돌 반영 완료 상태로 OPS-20260702-004~006 해결 처리 |
