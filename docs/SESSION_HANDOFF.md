# 세션 인수인계

## 완료한 작업

- Codex 운영 문서 구조 생성
- `automation/` 작업 영역 문서 생성
- 제품 요구사항 초안 작성
- 로컬 Git 저장소 초기화
- 원격 저장소 후보 반영: `https://github.com/cschoi724/CoreKeeperDedicatedServer.git`
- 서버 런타임 데이터와 비밀 설정을 제외하기 위한 `.gitignore` 추가
- Steam 전용 SDR(Game ID) 운영으로 방향 확정
- 기존 Steam 계정 월드를 Dedicated Server로 이전하는 설계 문서 추가
- 루트의 리서치/템플릿 문서를 `docs/` 하위로 정리

## 커밋

- 완료 커밋: `ac5e94c docs: 프로젝트 운영 문서 추가`
- 다음 문서 커밋 후보: `docs: 문서 자료를 docs 디렉토리로 정리`

## 검증

- 문서 파일 목록 확인 완료
- 실제 Core Keeper Dedicated Server 실행 검증은 수행하지 않음
- macOS 환경에서는 서버 실행을 하지 않는다는 원칙 유지

## 문서 업데이트

- `README.md`
- `agents.md`
- `docs/`
- `docs/product/REQUIREMENTS.md`
- `automation/`

## 남은 작업

1. 현재 문서 변경사항 커밋/push
2. Windows 노트북에서 clone 후 개발 세션 시작
3. 설치 경로와 백업 경로 확정
4. PowerShell 자동화 템플릿 구현

## 다음 개발 에이전트 지시

작업 위치:

- `automation/`

현재 기준:

- 루트 `agents.md`
- `automation/agents.md`
- `docs/research/deep-research-report.md`
- `docs/PROJECT_DECISIONS.md`
- `automation/docs/DEVELOPMENT_PLAN.md`

이번 작업 목표:

- Windows 노트북에서 실행 가능한 Core Keeper Dedicated Server 자동화 템플릿 구현

구현 대상:

- SteamCMD 설치/확인
- Core Keeper Dedicated Server 설치/업데이트
- 서버 시작
- 기존 월드 이전
- 백업
- Task Scheduler 등록
- Direct Connect는 현재 제외, 추후 선택 기능 후보로만 유지

핵심 요구:

- SDR(Game ID)를 기본 방식으로 둔다.
- Steam 접속만 지원하는 현재 범위에서는 Direct Connect를 구현하지 않는다.
- 월드 파일을 덮어쓰기 전 백업을 강제한다.
- Windows에서만 실행 검증한다.

테스트:

- PowerShell 문법 검사
- Windows 실기 검증
- 문서 절차 재현성 검증

검증:

- 설치 성공 여부
- 서버 첫 실행 여부
- Game ID 확인 여부
- 기존 월드 이전 여부
- 재부팅 후 자동 시작 여부

문서 업데이트:

- `automation/docs/STATUS.md`
- `automation/docs/TESTING.md`
- `automation/docs/CHANGELOG.md`
- `automation/docs/DECISIONS.md`

권장 커밋 메시지:

- `feat: Windows 서버 자동화 템플릿 추가`
