# Project Agent Registry

작성일: 2026-07-01
프로젝트: Core Keeper Dedicated Server Automation Template

## 1. 목적

이 문서는 현재 프로젝트에서 실제로 활성화된 Agent 구성을 기록한다.

사용 가능한 Agent와 기본 역할 정의는 `.ai/agent_registry.md`와 `.ai/agents/`를 따른다.

## 2. Active Agents

| Agent | 상태 | 역할 문서 | 비고 |
|---|---|---|---|
| PM Agent | `enabled` | `.ai/agents/pm_agent.md` | 제품/일정 영향, Task Queue 생성과 승인 게이트 담당 |
| Development Agent | `enabled` | `.ai/agents/development_agent.md` | 승인된 `automation/` 구현 Task 담당 |
| QA Agent | `enabled` | `.ai/agents/qa_agent.md` | 검증, 리스크 정리, 재작업 요청 담당 |
| AI Ops Agent | `enabled` | `.ai/agents/ai_ops_agent.md` | 독립 운영 프로세스 점검과 운영 마이그레이션 담당, 제품 Task 실행 라인 제외 |

## 3. Delegated Capabilities

| Capability | 현재 담당 | 비고 |
|---|---|---|
| `planning` | PM Agent | 프로젝트 상태와 다음 작업 후보 정리 |
| `task_routing` | PM Agent | Task 유형과 담당 Agent 분류 |
| `task_queue_management` | PM Agent | `.ai_project/tasks/` 생성, 상태 관리, 보드 갱신 |
| `approval_management` | PM Agent | 사용자 승인 게이트 관리 |
| `documentation` | PM Agent | 프로젝트 운영 문서 작성과 갱신 |
| `release_planning` | PM Agent | 릴리즈 범위와 배포 승인 항목 정리 |
| `technical_review` | PM Agent | 구조 영향과 조사 항목 정리 |
| `implementation` | Development Agent | 승인된 범위의 코드/문서 구현 |
| `developer_verification` | Development Agent | 개발자 검증 |
| `dev_reporting` | Development Agent | 개발 완료 보고 |
| `qa_review` | QA Agent | 변경 결과 검증 |
| `risk_review` | QA Agent | 회귀 위험과 잔여 리스크 정리 |
| `security_check` | QA Agent | 민감정보, 권한, 로그 노출 검토 |
| `release_check` | QA Agent | 릴리즈 전 검증 |
| `rework_request` | QA Agent | 재작업 요청 작성 |
| `ops_audit` | AI Ops Agent | Agent 운영 문서와 실제 운영 상태 충돌 점검 |
| `process_governance` | AI Ops Agent | Task Queue, 승인, lock, report/QA 흐름 점검 |
| `agent_boundary_review` | AI Ops Agent | Agent 역할/권한 경계와 확장 영향 검토 |
| `ops_migration` | AI Ops Agent | 현재 프로젝트에 AI Agent 운영 체계 도입 |

## 4. Agent 변경 기록

| 날짜 | 변경 내용 | 승인 |
|---|---|---|
| 2026-07-01 | PM/Development/QA 초기 활성 구성 | Product Owner 요청 기반 |
| 2026-07-01 | AI Ops Agent를 독립 운영 점검 및 마이그레이션 Agent로 활성화 | Product Owner 요청 기반 |
