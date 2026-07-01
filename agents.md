# Core Keeper Dedicated Server Automation agents.md

이 문서는 저장소 최상위 인수인계 문서입니다.

## 프로젝트 개요

- 프로젝트 이름: Core Keeper Dedicated Server Automation Template
- 한 줄 설명: 기존 Core Keeper Steam 호스트 월드를 Windows 노트북의 Dedicated Server로 이전하고 상시 운영하기 위한 자동화 템플릿
- 우선 개발 영역: `automation`
- 현재 세션 역할: 루트 관리 에이전트
- AI Agent Ops 적용 상태: `.ai/` 설치 완료, `.ai_project/` 운영 구조 초기화 완료
- 원격 저장소: `https://github.com/cschoi724/CoreKeeperDedicatedServer.git`
- 문서 언어: 한글

## 역할

### AI Ops Agent

- `.ai/agents/ai_ops_agent.md`를 기준으로 Agent 운영 구조, 역할 경계, Task Queue, source of truth를 점검합니다.
- 제품 Task 실행 라인에 참여하지 않고, 운영 이슈는 `.ai_project/ops_issues.md`에 기록합니다.
- 기존 문서 삭제나 병합은 `.ai_project/ops_migration_plan.md`의 후보와 롤백 기준을 확인한 뒤 사용자 승인 범위에서 진행합니다.

### 루트 관리 에이전트

- 제품 방향, 문서 구조, 저장소 구조, 작업 분리를 관리합니다.
- 실제 서버 실행 스크립트, 설치 스크립트, 백업 스크립트 구현 코드는 기본적으로 작성하지 않습니다.
- 하위 개발 에이전트가 추가 컨텍스트 없이 진행할 수 있도록 문서를 유지합니다.
- 사용자 변경사항을 임의로 되돌리지 않습니다.

### 작업 영역 개발 에이전트

- `automation/` 폴더 안에서 실제 Windows 자동화 템플릿 구현을 담당합니다.
- `automation/agents.md`를 우선 따릅니다.
- 작업 종료 전 상태, 계획, 테스트, 변경 기록을 갱신합니다.

## 주요 기준 문서

- 리서치 기준: `docs/research/deep-research-report.md`
- AI Agent 운영 템플릿: `.ai/`
- AI Agent 프로젝트 운영 상태: `.ai_project/`
- Source of truth 매핑: `.ai_project/source_of_truth.md`
- 운영 마이그레이션 계획: `.ai_project/ops_migration_plan.md`
- 프로젝트 상태: `docs/PROJECT_STATUS.md`
- 결정사항: `docs/PROJECT_DECISIONS.md`
- Git 전략: `docs/GIT_WORKFLOW.md`
- 작업 영역 계획: `automation/docs/DEVELOPMENT_PLAN.md`

## 문서 작성 원칙

- 문서는 한글로 작성합니다.
- 파일명은 영문 사용을 허용합니다.
- 다음 작업자가 바로 실행할 수 있게 구체적으로 작성합니다.
- 확정되지 않은 내용은 추측하지 말고 열린 질문으로 남깁니다.
- 리서치 문서의 내용도 구현 전 재검증이 필요한 항목은 결정사항이 아니라 열린 질문으로 둡니다.

## 개발 에이전트 지시 원칙

- 실제 개발 지시는 긴 요구사항 반복 대신 기준 문서와 작업 단위를 참조합니다.
- 지시에는 최소한의 필수 정보만 포함합니다.
- 상세 요구사항, 완료 조건, 검증 명령, 권장 커밋 메시지는 `automation/docs/DEVELOPMENT_PLAN.md`를 기준으로 합니다.
- 현재 상태와 미검증 항목은 `automation/docs/STATUS.md`, `automation/docs/TESTING.md`를 기준으로 합니다.
- 작업 범위나 결정이 바뀌면 먼저 문서에 반영한 뒤 다음 지시부터 그 문서를 참조합니다.

## Git 기준

- 작업 전 `git status -sb`를 확인합니다.
- 기본 브랜치는 `main`입니다.
- 원격 저장소는 `origin`으로 관리합니다.
- 사용자 변경사항은 임의로 되돌리지 않습니다.
- 의미 있는 단위로 커밋합니다.
- 커밋 메시지는 `type: 설명` 형식을 사용합니다.
- 자세한 전략은 `docs/GIT_WORKFLOW.md`를 따릅니다.
- `.ai/`는 별도 템플릿 저장소이므로 현재 프로젝트 Git에 포함하지 않습니다.
- `.ai_project/`는 프로젝트별 Agent 운영 문서이므로 기본적으로 현재 프로젝트 Git에 포함합니다.

## 세션 시작 체크리스트

- [ ] `git status -sb` 확인, 저장소가 아니면 그 사실을 상태 문서에 반영
- [ ] `.ai_project/current_context.md` 확인
- [ ] `.ai_project/source_of_truth.md` 확인
- [ ] 루트 `agents.md` 확인
- [ ] 관련 작업 영역 `agents.md` 확인
- [ ] `docs/PROJECT_STATUS.md` 확인
- [ ] 관련 개발 계획 문서 확인

## 세션 종료 체크리스트

- [ ] 완료한 작업 기록
- [ ] 다음 작업 기록
- [ ] 결정사항 기록
- [ ] 테스트/검증 결과 기록
- [ ] 변경사항 커밋 여부 확인
