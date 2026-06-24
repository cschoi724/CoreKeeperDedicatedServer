# 프로젝트 상태

## 현재 상태

- 프로젝트 단계: M0 문서 기반 준비
- 우선 개발 영역: `automation`
- 최신 기준 문서: `docs/research/deep-research-report.md`, `docs/templates/CODEX_PROJECT_RULES_TEMPLATE.md`
- 현재 주요 이슈:
  - 실제 구현은 아직 시작하지 않음
  - macOS에서 문서 구조만 세팅하고, 실제 실행 환경은 Windows 노트북으로 전제
  - 로컬 Git 저장소는 초기화됨
  - 원격 저장소 push 완료됨
  - Steam 전용 접속으로 방향 확정됨
  - 기존 월드는 사용자 Steam 계정에 속한 월드를 이전하는 방향으로 확정됨

## 목표

Steam에서 직접 호스트하던 기존 Core Keeper 월드를 Dedicated Server로 이전하여, 사용자가 게임에 접속하지 않아도 친구들이 접속할 수 있는 Windows용 자동화 템플릿을 만든다.

## 권장 구현 방향 초안

- Windows 노트북에서 clone 후 실행 가능한 PowerShell 중심 템플릿
- SteamCMD 기반 Core Keeper Dedicated Server 설치/업데이트
- 기본 접속 방식은 SDR(Game ID)
- Direct Connect는 현재 구현 우선순위에서 제외
- 기존 월드 이전, 백업, 업데이트, 자동 시작을 별도 명령으로 분리
- macOS에서는 실행하지 않고 문서/템플릿 작성만 수행

## 다음 작업

1. Windows 서버 운영 세부값 중 설치 경로와 백업 경로를 확정한다.
2. `automation/` 작업 영역 개발 세션에서 구현 파일 구조를 설계한다.
3. 기존 Steam 월드 이전 스크립트의 사용자 선택 흐름을 구현한다.
4. 집 Windows 노트북의 새 Codex 세션에서 SteamCMD와 Dedicated Server 실행 방식을 검증한다.

## 최근 작업

- 2026-06-24: 루트 관리 세션에서 Codex 운영 문서 구조를 생성함.
- 2026-06-24: 로컬 Git 저장소를 초기화하고 원격 저장소 정보를 문서에 반영함.
- 2026-06-24: Steam 전용 SDR(Game ID) 운영과 기존 Steam 계정 월드 이전 방향을 확정함.

## 열린 질문

- 서버 설치 기본 경로는 `C:\CoreKeeperServer`로 둘지?
- SteamCMD는 템플릿이 자동으로 다운로드할지, 사용자가 직접 설치할지?
- 기존 월드 파일은 사용자 Steam 계정의 어느 월드 인덱스에서 가져올지?
- 백업 보관 위치는 Windows 노트북 로컬 디스크, 외장 디스크, 클라우드 동기화 폴더 중 어디인지?
- 서버 자동 시작은 Windows Task Scheduler로 확정할지?
- 서버 실행 계정은 일반 사용자 계정인지, 별도 로컬 계정을 만들지?
