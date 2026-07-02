# Agent Ops Decisions

작성일: 2026-07-01
프로젝트: Steam Game Server Manager
상태: Draft

## 1. 목적

이 문서는 현재 프로젝트의 AI Agent 운영 결정만 기록한다.

제품 요구사항, 기술 아키텍처, 구현 정책, 배포 정책 같은 프로젝트 본문 결정은 기존 프로젝트 문서 영역에 기록한다.

## 2. 기록 대상

- 활성 Agent 추가/삭제/비활성화
- Agent별 역할과 권한 조정
- Capability 소유권 변경
- workflow override 적용
- Task Queue/report/QA 운영 방식 변경
- `.ai_project/` Git 포함 여부 또는 로컬 전용 예외
- `ai-agent-ops` 템플릿 적용 또는 migration 결정

## 3. 결정 기록

| 날짜 | 결정 | 배경 | 영향 | 승인 |
|---|---|---|---|---|
| 2026-07-01 | `.ai/`를 프로젝트 루트에 설치하되 프로젝트 Git에서는 제외 | `.ai/`는 별도 ai-agent-ops 템플릿 저장소 | `.gitignore`에 `.ai/` 추가 | Product Owner 요청 기반 |
| 2026-07-01 | `.ai_project/`를 프로젝트별 운영 문서 영역으로 초기화 | Agent 협업 상태와 Task Queue를 기존 제품 문서와 분리 관리 | `.ai_project/`가 프로젝트 저장소 포함 후보가 됨 | Product Owner 요청 기반 |
| 2026-07-01 | AI Ops Agent를 현재 세션 역할로 활성화 | 사용자가 AI Ops Agent 역할 확인과 운영 구조 초기화를 요청 | 제품 Task 실행 권한 없이 운영 마이그레이션 주도 | Product Owner 요청 기반 |
| 2026-07-01 | 기존 프로젝트 문서는 삭제하지 않고 source of truth로 우선 연결 | 운영 마이그레이션 workflow가 기존 문서 무단 삭제를 금지 | 삭제/병합 후보는 `ops_migration_plan.md`에서 검토 | `.ai/` 정책 준수 |
| 2026-07-02 | `.ai` 커밋 `59e0533` 기준 `.ai_project` 동기화 반영 | `ops_migration_plan.md` 12번 감사에서 `target_agent` 재정의 override와 T-20260701-009 QA 라우팅 충돌 확인 | `workflow_overrides.md`의 `target_agent` 재정의 override 폐기, T-20260701-009 `ready_for_qa` 실행 담당을 QA Agent로 보정, 다음 작업 안내 형식에 Task ID/status/담당 Agent/근거/세션/요청 문장 포함 | Product Owner 요청 기반 |
| 2026-07-02 | T-20260701-009 완료 확정 후 GSM-R0~GSM-R8 Queue를 닫음 | Valheim skeleton Adapter QA가 `PASS_WITH_RISK`로 통과했고 Product Owner가 완료 처리와 커밋을 요청 | 현재 진행/QA 대기 Task 없음, 다음 PM 작업은 후속 개발 Task 선정 | Product Owner 요청 기반 |

## 4. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | Agent 운영 결정 문서 초기화 |
| 2026-07-02 | `.ai` 커밋 `59e0533` 기준 `.ai_project` 동기화 반영 결정 기록 |
| 2026-07-02 | T-20260701-009 완료 확정과 GSM-R0~GSM-R8 Queue 종료 기록 |
