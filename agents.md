# Core Keeper Dedicated Server Automation agents.md

이 문서는 저장소 최상위 인수인계 문서입니다.

## 프로젝트 개요

- 프로젝트 이름: Core Keeper Dedicated Server Automation Template
- 한 줄 설명: 기존 Core Keeper Steam 호스트 월드를 Windows 노트북의 Dedicated Server로 이전하고 상시 운영하기 위한 자동화 템플릿
- 우선 개발 영역: `automation`
- 현재 세션 역할: 루트 관리 에이전트
- 원격 저장소: `https://github.com/cschoi724/CoreKeeperDedicatedServer.git`
- 문서 언어: 한글

## 역할

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

- 리서치 기준: `deep-research-report.md`
- 운영 문서 기준: `CODEX_PROJECT_RULES_TEMPLATE.md`
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

## Git 기준

- 작업 전 `git status -sb`를 확인합니다.
- 기본 브랜치는 `main`입니다.
- 원격 저장소는 `origin`으로 관리합니다.
- 사용자 변경사항은 임의로 되돌리지 않습니다.
- 의미 있는 단위로 커밋합니다.
- 커밋 메시지는 `type: 설명` 형식을 사용합니다.
- 자세한 전략은 `docs/GIT_WORKFLOW.md`를 따릅니다.

## 세션 시작 체크리스트

- [ ] `git status -sb` 확인, 저장소가 아니면 그 사실을 상태 문서에 반영
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
