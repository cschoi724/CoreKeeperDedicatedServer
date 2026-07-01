# Source Of Truth

작성일: 2026-07-01
프로젝트: Core Keeper Dedicated Server Automation Template
상태: Draft

## 1. 목적

이 문서는 현재 프로젝트에서 어떤 문서와 코드가 최종 기준인지 정의한다.

`.ai/`는 Agent 운영 가이드북이고, `.ai_project/`는 Agent 협업 상태다. 실제 제품, 기술스택, 구현 계획, 아키텍처, QA 기준은 기존 프로젝트 문서 영역을 기준으로 관리한다.

## 2. 프로젝트 프로필

| 항목 | 값 |
|---|---|
| 제품/서비스명 | Core Keeper Dedicated Server Automation Template |
| 개발 대상 | Windows 노트북용 Core Keeper Dedicated Server 자동화 템플릿 |
| 주 기술스택 | PowerShell, SteamCMD, Windows Task Scheduler |
| 저장소 | `https://github.com/cschoi724/CoreKeeperDedicatedServer.git` |
| 기본 브랜치 | `main` |
| 배포 대상 | GitHub 저장소 clone 후 Windows 로컬 실행 |

## 3. Source Of Truth 매트릭스

| 영역 | 최종 기준 | 보조 기준 | 충돌 시 처리 |
|---|---|---|---|
| Agent 운영 원칙 | `.ai/` | `.ai_project/` | 운영 원칙은 `.ai/` 우선 |
| Agent 구성 | `.ai_project/agent_registry.md` | `.ai/agent_registry.md` | 프로젝트 활성 구성은 `.ai_project/` 우선 |
| Agent 실행 Task | `.ai_project/tasks/` | `.ai_project/task_board.md`, report/QA 문서 | Task 파일 우선 |
| Agent 작업 상태 요약 | `.ai_project/task_board.md` | `.ai_project/tasks/` | 충돌 시 Task 파일 기준으로 보드 갱신 |
| 루트 프로젝트 상태 | `docs/PROJECT_STATUS.md` | `.ai_project/current_context.md` | 제품/기술 상태는 `docs/PROJECT_STATUS.md`, Agent 운영 상태는 `.ai_project/current_context.md` |
| 루트 프로젝트 결정 | `docs/PROJECT_DECISIONS.md` | `.ai_project/ops_decisions.md` | 제품/기술 결정은 `docs/PROJECT_DECISIONS.md`, Agent 운영 결정은 `.ai_project/ops_decisions.md` |
| Git 운영 | `docs/GIT_WORKFLOW.md` | `.ai/commit_policy.md` | 프로젝트 Git 정책은 `docs/GIT_WORKFLOW.md`, Agent 커밋 절차는 `.ai/commit_policy.md` |
| 우선 개발 영역 지시 | `agents.md` | `.ai_project/current_context.md` | 프로젝트 기존 역할은 `agents.md`, AI Ops 활성 상태는 `.ai_project/agent_registry.md` |
| 자동화 개발 계획 | `automation/docs/DEVELOPMENT_PLAN.md` | `.ai_project/tasks/`, `.ai_project/task_board.md` | 계획 내용은 기존 문서, 실행 Task는 `.ai_project/tasks/` |
| 자동화 현재 상태 | `automation/docs/STATUS.md` | `docs/PROJECT_STATUS.md`, `.ai_project/current_context.md` | 구현 상태는 `automation/docs/STATUS.md` 우선 |
| 자동화 결정 | `automation/docs/DECISIONS.md` | `docs/PROJECT_DECISIONS.md` | 영역별 상세 결정은 `automation/docs/DECISIONS.md`, 프로젝트 전체 결정은 `docs/PROJECT_DECISIONS.md` |
| 자동화 검증 기준 | `automation/docs/TESTING.md` | `.ai_project/qa/` | 검증 절차는 `automation/docs/TESTING.md`, 실행 결과는 `.ai_project/qa/` |
| 자동화 운영 설계 | `automation/docs/OPERATIONS_DESIGN.md` | `docs/product/DEDICATED_SERVER_OPERATION_KNOWLEDGE.md` | 구현 설계는 `automation/docs/OPERATIONS_DESIGN.md`, 운영 지식은 product 문서 |
| 월드 이전 설계 | `automation/docs/WORLD_MIGRATION_DESIGN.md` | `docs/product/REQUIREMENTS.md` | 구현 설계는 `automation/docs/WORLD_MIGRATION_DESIGN.md` |
| 제품 요구사항 | `docs/product/REQUIREMENTS.md` | `docs/product/*.md` | 최신 사용자 승인 요구사항 우선 |
| 리서치 기준 | `docs/research/deep-research-report.md` | `docs/research/*.pdf` | 구현 전 최신 정보 재검증 필요 항목은 열린 질문으로 유지 |
| 변경 이력 | `docs/PROJECT_CHANGELOG.md`, `automation/docs/CHANGELOG.md` | Git commit | 루트/자동화 영역별 changelog를 분리 유지 |
| 인수인계 | `.ai_project/current_context.md` | `docs/PROJECT_STATUS.md`, `automation/docs/STATUS.md` | AI Agent Ops 도입 후 Agent 운영 시작점은 `.ai_project/current_context.md` |

## 4. 프로젝트 문서 위치

현재 프로젝트 기준 위치:

```text
docs/
automation/docs/
.ai_project/
```

역할:

- `docs/`: 프로젝트 전체 상태, 결정, 제품/리서치 문서
- `automation/docs/`: Windows 자동화 구현 계획, 상태, 검증, 설계 문서
- `.ai_project/`: Agent 운영 상태, Task Queue, report, QA 보고, 운영 이슈

## 5. 빌드/검증 기준

| 목적 | 명령 또는 절차 | 실행 주체 |
|---|---|---|
| 작업 전 Git 상태 확인 | `git status -sb` | 모든 Agent |
| macOS 문서/정적 확인 | `rg`, `git diff --check` | Development Agent / QA Agent |
| PowerShell 모듈 import | `automation/docs/TESTING.md` 2번 절차 | Development Agent / QA Agent |
| SteamCMD 설치 검증 | `automation/docs/TESTING.md` 3번 절차 | Development Agent / QA Agent |
| Dedicated Server 설치/실행 검증 | `automation/docs/TESTING.md` 4-6번 절차 | Development Agent / QA Agent |
| 백업/월드 import/Task Scheduler 검증 | `automation/docs/TESTING.md` 7-10번 절차 | Development Agent / QA Agent |
| 수동 QA | `.ai_project/qa/` 보고서와 `automation/docs/TESTING.md` 기준 | QA Agent |

## 6. 기존 문서 병합/삭제 후보

아래 표는 삭제 실행 목록이 아니라 검토 후보 목록이다. 기존 문서 삭제는 사용자 승인 후 진행한다.

| 문서 | 현재 판단 | 이유 | 권장 처리 |
|---|---|---|---|
| `docs/SESSION_HANDOFF.md` | 삭제 완료 | `.ai_project/current_context.md`와 `automation/docs/STATUS.md`가 역할을 대체하며, 삭제 전 내용은 T1-T8/T9 기준으로 일부 오래됨 | 2026-07-01 삭제. 롤백은 Git 이력 사용 |
| `docs/templates/CODEX_PROJECT_RULES_TEMPLATE.md` | 삭제 완료 | `.ai/` 운영 템플릿 도입 후 역할이 중복되는 범용 템플릿 | 2026-07-01 삭제. 롤백은 Git 이력 사용 |
| `docs/README.md` | 보관 후보 | 기존 docs 안내 인덱스로 유용할 수 있음 | `.ai_project/` 링크를 추가하는 방식 권장 |
| `automation/docs/STATUS.md` | 유지 | 구현 상태 source of truth | 삭제 금지 |
| `automation/docs/DEVELOPMENT_PLAN.md` | 유지 | 기존 T1-T10 계획 source of truth | PM Agent가 Task Queue로 분해할 때 참조 |
| `automation/docs/TESTING.md` | 유지 | Windows 실기 검증 절차 source of truth | QA 보고는 `.ai_project/qa/`에 누적 |
| `automation/docs/DECISIONS.md` | 유지 | 자동화 영역 상세 결정 source of truth | 삭제 금지 |
| `docs/PROJECT_STATUS.md` | 유지 | 루트 프로젝트 상태 source of truth | 삭제 금지 |
| `docs/PROJECT_DECISIONS.md` | 유지 | 루트 프로젝트 결정 source of truth | 삭제 금지 |

## 7. 충돌 해결 원칙

1. 사용자 승인 결정이 최우선이다.
2. 실제 코드 동작과 문서가 다르면 코드와 검증 결과를 먼저 확인한다.
3. Agent 운영 문서와 프로젝트 기술 문서가 충돌하면 영역을 분리해 해석한다.
4. 제품/기술 결정은 기존 프로젝트 문서에 남기고, Agent 운영 결정은 `.ai_project/ops_decisions.md`에 남긴다.
5. 충돌 해결 후 관련 Task 파일과 `.ai_project/task_board.md`를 갱신한다.

## 8. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | Source Of Truth 문서 초기화 |
