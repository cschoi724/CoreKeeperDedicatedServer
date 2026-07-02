# 문서 인덱스

이 폴더는 Steam Game Server Manager 프로젝트의 루트 운영 문서를 관리합니다.

AI Agent 운영 상태와 Task Queue는 루트 `docs/`가 아니라 `.ai_project/`에서 관리합니다.

## 루트 문서

- `PROJECT_STATUS.md`: 프로젝트 현재 상태와 다음 작업
- `PROJECT_DECISIONS.md`: 확정된 결정사항과 열린 질문
- `PROJECT_CHANGELOG.md`: 프로젝트 단위 변경 기록
- `GIT_WORKFLOW.md`: Git 운영 기준

## AI Agent 운영 문서

- `../.ai_project/current_context.md`: Agent 세션 시작 기준
- `../.ai_project/source_of_truth.md`: 문서별 최종 기준과 충돌 처리
- `../.ai_project/task_board.md`: Task Queue 요약
- `../.ai_project/ops_migration_plan.md`: 운영 구조 마이그레이션, 병합/삭제 후보
- `../.ai_project/ops_issues.md`: Agent 운영 이슈와 개선 후보

## 제품/리서치 문서

- `research/deep-research-report.md`: Core Keeper Dedicated Server 구축 리서치. 현재는 첫 Adapter 설계와 회귀 검증을 위한 이력/근거 문서로 사용
- `research/Core Keeper 전용 서버와 상시 호스팅 구축 가이드.pdf`: Core Keeper Adapter 이력 리서치 PDF
- `product/DEDICATED_SERVER_OPERATION_KNOWLEDGE.md`: Dedicated Server 운영 지식과 확장 후보
- `product/Additional Research & Design Review.txt`: 추가 리서치/설계 검토 원문
- `product/Dedicated Server 운영 기능 추가 요구사항.txt`: 운영 기능 추가 요구사항 원문

## 작업 영역 문서

- `../automation/docs/DEVELOPMENT_PLAN.md`: Steam Game Server Manager 자동화 개발 계획
- `../automation/docs/OPERATIONS_DESIGN.md`: Windows 운영 자동화 설계
- `../automation/docs/WINDOWS_CODEX_RUNBOOK.md`: Windows Codex 실기 검증 절차
- `../automation/docs/WORLD_MIGRATION_DESIGN.md`: 기존 월드 import 설계
- `product/`: 제품 요구사항과 운영 시나리오 문서를 추가할 위치
