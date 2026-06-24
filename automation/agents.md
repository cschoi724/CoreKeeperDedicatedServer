# automation agents.md

이 문서는 Windows Core Keeper Dedicated Server 자동화 템플릿 개발 에이전트가 추가 컨텍스트 없이 작업하기 위한 기준입니다.

## 역할

- `automation/` 폴더 안의 실제 자동화 템플릿 구현을 담당합니다.
- 루트 제품 문서와 루트 `agents.md`를 참고합니다.
- 구현 판단은 이 작업 영역 문서를 우선합니다.
- 작업 종료 전 문서를 갱신합니다.

## 작업 목표

Windows 노트북에서 이 저장소를 clone한 뒤, Core Keeper Dedicated Server 설치/업데이트/월드 이전/백업/자동 시작을 재현 가능하게 수행하는 템플릿을 만든다.

## 현재 범위

- 현재 세션에서는 구현하지 않음
- 다음 개발 세션에서 PowerShell/Batch 기반 실제 템플릿 작성 예정
- macOS에서 서버 실행 검증 금지

## 참고 문서

- 루트 기준: `../agents.md`
- 리서치 기준: `../docs/research/deep-research-report.md`
- 프로젝트 상태: `../docs/PROJECT_STATUS.md`
- 프로젝트 결정사항: `../docs/PROJECT_DECISIONS.md`
- 개발 계획: `docs/DEVELOPMENT_PLAN.md`
- 작업 영역 상태: `docs/STATUS.md`
- 테스트 기준: `docs/TESTING.md`

## 개발 원칙

- Windows PowerShell을 기본 자동화 언어 후보로 둔다.
- 서버 설치는 SteamCMD + App ID `1963720` 후보를 우선 검토한다.
- 기본 접속 방식은 SDR(Game ID)로 둔다.
- Direct Connect, 방화벽, 포트포워딩은 현재 구현 범위에서 제외하고 추후 선택 기능 후보로만 남긴다.
- 사용자 월드 파일을 덮어쓰기 전 반드시 백업과 확인 단계를 둔다.
- 실제 서버 실행은 Windows 환경에서만 검증한다.
- 작업 영역 외부 파일을 수정해야 하면 이유를 문서에 남긴다.

## 구현 전 필수 확인

- 최신 Core Keeper Dedicated Server Windows 실행 방식
- SteamCMD anonymous 설치 가능 여부
- `ServerConfig.json` 최신 구조
- 기존 월드 저장 경로와 Dedicated Server 저장 경로
- Game ID 확인 방식
- Task Scheduler 등록 권한 요구사항
