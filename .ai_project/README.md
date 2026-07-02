# AI Project Workspace

작성일: 2026-07-01
프로젝트: Steam Game Server Manager
상태: Draft

## 1. 목적

이 디렉토리는 현재 프로젝트에 종속되는 AI Agent 협업 문서 영역이다.

`.ai/`는 AI Agent 운영 가이드북과 템플릿 저장소이고, `.ai_project/`는 이 프로젝트의 실제 Agent Task Queue, 운영 결정, 협업 상태, 검증 기록을 관리한다.

## 2. 문서 목록

| 문서/폴더 | 역할 |
|---|---|
| `.ai_project/agent_registry.md` | 현재 프로젝트 활성 Agent 구성 |
| `.ai_project/current_context.md` | 세션 시작 시 확인할 현재 운영 컨텍스트 |
| `.ai_project/tasks/` | Agent 실행 Task Queue |
| `.ai_project/task_board.md` | Task Queue 요약 보드 |
| `.ai_project/source_of_truth.md` | 프로젝트 기준 문서와 충돌 처리 기준 |
| `.ai_project/ops_decisions.md` | Agent 운영 결정 기록 |
| `.ai_project/ops_issues.md` | AI Agent 운영 프로세스 이슈와 개선 제안 |
| `.ai_project/ops_migration_plan.md` | AI Agent 운영 체계 도입 계획 |
| `.ai_project/workflow_overrides.md` | 프로젝트별 workflow 예외 |
| `.ai_project/reports/` | Development Agent 완료 보고 |
| `.ai_project/qa/` | QA Agent 검증 보고 |
| `.ai_project/release/` | 릴리즈 준비 기록 |

## 3. 운영 원칙

- `.ai_project/`는 프로젝트 저장소에 포함한다.
- `.ai/`는 별도 템플릿 저장소이므로 프로젝트 저장소에는 포함하지 않는다.
- Agent 실행 지시는 `.ai_project/tasks/`의 Task 파일을 우선한다.
- `.ai_project/task_board.md`는 요약판이며 Task 파일을 대체하지 않는다.
- 제품/기술 결정은 기존 프로젝트 문서인 `docs/PROJECT_DECISIONS.md`와 `automation/docs/DECISIONS.md`를 우선한다.
- 현재 상태와 검증 기준은 `docs/PROJECT_STATUS.md`, `automation/docs/STATUS.md`, `automation/docs/TESTING.md`를 우선한다.
- 기존 문서는 삭제하지 않고 먼저 `.ai_project/source_of_truth.md`와 `.ai_project/ops_migration_plan.md`에 병합/삭제 후보를 기록한다.

## 4. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | `.ai_project/` 초기화 |
| 2026-07-01 | 기존 프로젝트 문서 source of truth 연결 기준 추가 |
| 2026-07-02 | 프로젝트 표기를 Steam Game Server Manager 기준으로 갱신 |
