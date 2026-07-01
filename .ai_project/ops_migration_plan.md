# AI Ops Migration Plan

작성일: 2026-07-01
프로젝트: Core Keeper Dedicated Server Automation Template
상태: Draft

## 1. 목적

이 문서는 현재 프로젝트에 AI Agent 운영 체계를 도입하기 위한 프로젝트별 마이그레이션 계획이다.

운영 체계 도입은 AI Ops Agent가 주도한다. 제품 우선순위와 개발 Task 승인은 PM Agent와 Product Owner가 담당한다.

## 2. 현재 프로젝트 구조 요약

```text
CoreKeeper/
  agents.md
  README.md
  docs/
    PROJECT_STATUS.md
    PROJECT_DECISIONS.md
    PROJECT_CHANGELOG.md
    GIT_WORKFLOW.md
    SESSION_HANDOFF.md
    product/
    research/
    templates/
  automation/
    agents.md
    README.md
    config/
    docs/
    scripts/
    src/
  .ai/
  .ai_project/
```

## 3. 적용한 운영 구조

```text
CoreKeeper/
  .ai/                     # 별도 ai-agent-ops 템플릿 저장소, 프로젝트 Git 제외
  .ai_project/             # 프로젝트별 Agent 운영 상태, 프로젝트 Git 포함 후보
    README.md
    agent_registry.md
    current_context.md
    source_of_truth.md
    task_board.md
    ops_decisions.md
    ops_issues.md
    ops_migration_plan.md
    workflow_overrides.md
    tasks/
    reports/
    qa/
    release/
```

## 4. Source Of Truth 매핑

| 영역 | 기준 문서 | 보조 문서 | 비고 |
|---|---|---|---|
| Agent 운영 원칙 | `.ai/` | `.ai_project/` | `.ai/`는 수정 보호 대상 |
| Agent 활성 구성 | `.ai_project/agent_registry.md` | `.ai/agent_registry.md` | 현재 AI Ops Agent 활성화 |
| Task Queue | `.ai_project/tasks/` | `.ai_project/task_board.md` | 아직 첫 Task 없음 |
| 현재 운영 컨텍스트 | `.ai_project/current_context.md` | `docs/SESSION_HANDOFF.md` | Agent 세션 시작 기준 |
| 프로젝트 상태 | `docs/PROJECT_STATUS.md` | `automation/docs/STATUS.md` | 제품/기술 상태 |
| 자동화 구현 상태 | `automation/docs/STATUS.md` | `automation/docs/DEVELOPMENT_PLAN.md` | T1-T9 완료, T10 필요 |
| 구현 계획 | `automation/docs/DEVELOPMENT_PLAN.md` | `.ai_project/tasks/` | PM Agent가 Task로 분해 |
| 결정사항 | `docs/PROJECT_DECISIONS.md`, `automation/docs/DECISIONS.md` | `.ai_project/ops_decisions.md` | 운영 결정과 제품 결정 분리 |
| 검증 기준 | `automation/docs/TESTING.md` | `.ai_project/qa/` | 검증 결과는 QA 보고로 누적 |
| Git 전략 | `docs/GIT_WORKFLOW.md` | `.ai/commit_policy.md` | 프로젝트 정책 우선 |

## 5. 기존 문서 처리 기준

- 기존 문서는 기본적으로 삭제하지 않는다.
- 기존 문서가 유효하면 그대로 source of truth로 연결한다.
- 정리가 필요한 문서는 삭제 전에 병합 대상과 롤백 기준을 기록한다.
- 제품/기술 문서 삭제는 PM Agent가 사용자 승인을 받은 뒤 처리한다.
- 코드/빌드/폴더 경로 영향이 있는 변경은 Development Agent Task로 분리한다.

## 6. 병합/삭제 후보

| 대상 | 분류 | 병합 대상 | 삭제 가능 조건 | 롤백 기준 |
|---|---|---|---|---|
| `docs/SESSION_HANDOFF.md` | 삭제 완료 | `.ai_project/current_context.md`, `automation/docs/STATUS.md` | 현재 파일의 고유 정보가 없고 일부 상태가 오래되었음을 확인해 2026-07-01 삭제 | Git에서 파일 복구 |
| `docs/templates/CODEX_PROJECT_RULES_TEMPLATE.md` | 삭제 완료 | `.ai/`, `agents.md`, `.ai_project/source_of_truth.md` | 범용 템플릿 역할이 `.ai/`로 대체되었음을 확인해 2026-07-01 삭제 | Git에서 파일 복구 |
| `docs/README.md` | 유지/갱신 완료 | 없음 | 문서 인덱스 역할이 사라진 경우에만 삭제 | Git에서 파일 복구 |
| 루트 `agents.md` | 병합 완료 | `.ai_project/current_context.md`, `.ai_project/agent_registry.md` | 삭제 대상 아님 | 변경 전 Git diff 확인 후 복구 |
| `automation/agents.md` | 유지 | 없음 | 삭제 대상 아님 | 변경 전 Git diff 확인 후 복구 |

## 7. AGENTS.md 병합 계획

| 위치 | 현재 상태 | 처리 방향 | 비고 |
|---|---|---|---|
| 루트 `agents.md` | 현재 세션 역할과 AI Ops 적용 상태를 함께 기록 | `.ai_project/current_context.md`와 `.ai_project/agent_registry.md`도 확인하도록 문구 추가 완료 | 2026-07-01 반영 |
| `automation/agents.md` | 자동화 개발 Agent 기준으로 사용 중 | 유지 | Development Agent가 `automation/` 작업 전 우선 확인 |

## 8. 백업/롤백 전략

| 대상 | 백업 위치 | 롤백 조건 | 담당 |
|---|---|---|---|
| 기존 문서 삭제 | Git 이력 | 삭제 후 링크 깨짐, 고유 정보 누락, 사용자 요청 | PM Agent / Development Agent |
| `agents.md` 병합 수정 | Git diff와 Git 이력 | 새 세션 역할 지시가 모호해짐 | AI Ops Agent / PM Agent |
| `.ai_project/` 초기 문서 | Git 이력 | 운영 구조를 도입하지 않기로 결정 | PM Agent |
| `.gitignore`의 `.ai/` 추가 | Git diff와 Git 이력 | `.ai/`를 프로젝트 저장소에 포함하기로 별도 결정 | Product Owner |

## 9. 적용 단계

1. 현재 구조와 기존 문서 분석
2. `.ai/` 적용과 Git 제외 정책 확인
3. `.ai_project/` 초기 구조 생성
4. source of truth 매핑 작성
5. 병합/삭제 후보 작성
6. PM/Development/QA/AI Ops 세션 시작 기준 정리
7. PM Agent가 첫 `proposed` Task 등록
8. Development/QA Agent로 파일럿 검증
9. 사용자 승인 후 병합/삭제 후보 처리

## 10. 사용자 결정 필요 항목

| 항목 | 선택지 | 권장안 | 결정 |
|---|---|---|---|
| `.ai_project/` Git 포함 여부 | 포함 / 로컬 전용 | 포함 | 미확정 |
| 첫 파일럿 Task | T10 Windows 실기 검증 / 문서 QA / AGENTS 병합 | T10 Windows 실기 검증 | 미확정 |
| 루트 `agents.md` 병합 | 현 상태 유지 / `.ai_project` 참조 추가 | `.ai_project` 참조 추가 | 반영 완료 |
| 삭제 후보 처리 | 유지 / 병합 후 삭제 | `SESSION_HANDOFF`, `CODEX_PROJECT_RULES_TEMPLATE` 삭제 | 반영 완료 |

## 11. 리스크

| 리스크 | 영향 | 대응 |
|---|---|---|
| 기존 `agents.md`와 AI Ops 활성 상태 충돌 | 새 세션에서 역할 해석이 갈릴 수 있음 | `current_context.md`와 `ops_issues.md`에 기록, 병합안 작성 |
| source of truth 미정 | Task 실행 기준 불명확 | `source_of_truth.md`에 기존 문서별 기준 지정 |
| 삭제 후보 문서에 고유 정보 존재 | 문서 손실 | 삭제 전 파일 내용 재확인과 Git diff 검토 |
| 첫 Task 미등록 | Dev/QA Agent가 큐 기반으로 실행할 작업 없음 | PM Agent가 `proposed` Task 생성 |

## 12. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | AI Ops Migration Plan 초기화 |
