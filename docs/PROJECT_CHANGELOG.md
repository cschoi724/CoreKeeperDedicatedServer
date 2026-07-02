# 프로젝트 변경 기록

## 2026-06-24

- 루트 `agents.md` 추가
- `docs/` 루트 운영 문서 추가
- `automation/` 작업 영역 문서 구조 추가
- 구현 범위를 문서화하고 미확정 항목을 열린 질문으로 분리
- 로컬 Git 저장소 초기화
- 원격 저장소 정보를 문서에 반영
- `.gitignore`와 세션 인수인계 문서 추가
- Steam 전용 SDR(Game ID) 운영 결정을 문서화
- 운영 옵션 설명 문서 추가
- 기본 빈 월드/기존 월드 import 설계 문서 추가
- 루트의 리서치/템플릿 문서를 `docs/research/`, `docs/templates/`로 이동
- Windows 운영 기본값과 기본 빈 월드/import 설계를 문서화
- 자동화 개발 계획을 작업 단위별 실행 계획으로 구체화
- Windows Codex 실기 검증 Runbook 추가
- Dedicated Server 플레이어 0명 sleep/대기 동작과 운영 확장 후보 문서화
- T10을 Windows 실기 검증과 2차 운영 확장용 로그/증거 수집 단계로 명확히 분리

## 2026-07-01

- `.ai/` AI Agent Ops 템플릿 저장소 도입
- `.ai_project/` 프로젝트별 Agent 운영 구조 초기화
- 루트 `agents.md`에 AI Ops Agent와 `.ai_project/` 확인 기준 추가
- `docs/README.md`에 AI Agent 운영 문서 인덱스 추가
- `docs/SESSION_HANDOFF.md` 내용을 `.ai_project/current_context.md`와 기존 상태 문서로 병합하고 삭제
- `docs/templates/CODEX_PROJECT_RULES_TEMPLATE.md` 역할을 `.ai/` 운영 템플릿으로 대체하고 삭제
- 제품 방향을 Steam Game Server Manager로 전환
- `automation/docs/DEVELOPMENT_PLAN.md`를 Core/Adapter 구조 기준으로 전면 개정
- `automation/docs/REFACTORING_PLAN.md`, `automation/docs/MIGRATION_STRATEGY.md` 추가
- 범용 플랫폼 전환 실행 Task Queue를 `proposed` 상태로 등록

## 2026-07-02

- GSM-R1~GSM-R7 Core/Adapter 전환 작업과 QA 재검증 결과를 운영 문서에 반영
- 루트/자동화 Agent 지침과 상태 문서의 프로젝트 표기를 Steam Game Server Manager 기준으로 정리
