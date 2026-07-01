# Current Agent Context

작성일: 2026-07-01
프로젝트: Core Keeper Dedicated Server Automation Template
상태: Draft

## 1. 목적

이 문서는 Agent가 세션을 시작하거나 재개할 때 가장 먼저 확인할 현재 운영 컨텍스트를 요약한다.

실제 실행 기준은 `.ai_project/tasks/`의 Task 파일이다. 이 문서는 현재 초점과 주의사항을 빠르게 파악하기 위한 안내판이다.

## 2. 현재 운영 상태

| 항목 | 값 |
|---|---|
| 현재 운영 모드 | AI Agent Ops 마이그레이션 초기화 완료, Task Queue 도입 준비 |
| 활성 Agent | PM Agent, Development Agent, QA Agent, AI Ops Agent |
| 현재 우선 Task | 없음 |
| 다음 확인 위치 | `.ai_project/source_of_truth.md`, `.ai_project/task_board.md`, `automation/docs/STATUS.md` |
| Lock timeout | 240분 |

## 3. 현재 프로젝트 상태 요약

- 프로젝트는 Core Keeper Dedicated Server Windows 자동화 템플릿이다.
- 우선 개발 영역은 `automation/`이다.
- 기존 구현 계획은 `automation/docs/DEVELOPMENT_PLAN.md`를 기준으로 한다.
- 현재 구현 상태는 `automation/docs/STATUS.md` 기준으로 T1-T9 완료, T10 Windows 실기 검증 필요 상태다.
- 현재 macOS 환경에서는 Windows PowerShell, SteamCMD, Task Scheduler, Dedicated Server 실행 검증을 하지 않는다.

## 4. 현재 주의사항

- `.ai/`는 운영 템플릿 저장소이며 프로젝트 저장소에 커밋하지 않는다.
- `.ai_project/`는 프로젝트별 협업 상태 문서로 커밋 대상이다.
- AI Ops Agent는 제품 Task 실행 라인에 참여하지 않고, 운영 프로세스 문제를 `.ai_project/ops_issues.md`에 기록한다.
- 제품/기술 결정은 `.ai_project/`가 아니라 기존 프로젝트 문서의 source of truth를 우선한다.
- 기존 문서 삭제는 `.ai_project/ops_migration_plan.md`의 삭제 후보와 롤백 기준 확인 후 사용자 승인을 받아 진행한다.

## 5. 세션 시작 체크

1. `git status -sb`를 확인한다.
2. `.ai/workflow.md`와 `.ai/task_queue.md`를 확인한다.
3. 이 문서를 확인한다.
4. `.ai_project/tasks/`에서 자신의 역할 또는 capability와 맞는 Task를 확인한다.
5. Task의 `status`, `approved_by`, `depends_on`, `locked_by`, `allowed_paths`, `source_of_truth`를 확인한다.
6. Development/QA Agent는 실행 전 lock을 획득하고 하나의 Task만 진행한다.
7. AI Ops Agent는 Task 상태를 변경하지 않고 운영 이슈만 기록한다.

## 6. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | 현재 Agent 컨텍스트 문서 초기화 |
