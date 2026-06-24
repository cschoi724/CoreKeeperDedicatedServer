# 프로젝트 상태

## 현재 상태

- 프로젝트 단계: M0 문서 기반 준비
- 우선 개발 영역: `automation`
- 최신 기준 문서: `deep-research-report.md`, `CODEX_PROJECT_RULES_TEMPLATE.md`
- 현재 주요 이슈:
  - 실제 구현은 아직 시작하지 않음
  - macOS에서 문서 구조만 세팅하고, 실제 실행 환경은 Windows 노트북으로 전제
  - 로컬 Git 저장소는 초기화됨
  - 원격 저장소 push 진행 예정

## 목표

Steam에서 직접 호스트하던 기존 Core Keeper 월드를 Dedicated Server로 이전하여, 사용자가 게임에 접속하지 않아도 친구들이 접속할 수 있는 Windows용 자동화 템플릿을 만든다.

## 권장 구현 방향 초안

- Windows 노트북에서 clone 후 실행 가능한 PowerShell 중심 템플릿
- SteamCMD 기반 Core Keeper Dedicated Server 설치/업데이트
- 기본 접속 방식은 SDR(Game ID) 우선
- Direct Connect는 선택 기능으로 분리
- 기존 월드 이전, 백업, 업데이트, 자동 시작을 별도 명령으로 분리
- macOS에서는 실행하지 않고 문서/템플릿 작성만 수행

## 다음 작업

1. 원격 저장소 push 완료 여부를 확인한다.
2. Windows 서버 운영 방식 세부값을 확정한다.
3. `automation/` 작업 영역 개발 세션에서 구현 파일 구조를 설계한다.
4. 구현 전 Core Keeper Dedicated Server의 최신 실행 인자와 설정 파일 구조를 Windows 환경에서 확인한다.

## 최근 작업

- 2026-06-24: 루트 관리 세션에서 Codex 운영 문서 구조를 생성함.
- 2026-06-24: 로컬 Git 저장소를 초기화하고 원격 저장소 정보를 문서에 반영함.

## 열린 질문

- Windows 노트북에서 SteamCMD만 사용할지, Steam GUI Tools 설치 경로도 지원할지?
- 친구 접속 방식은 SDR(Game ID)만 필요한지, Direct Connect도 반드시 필요한지?
- Direct Connect가 필요하다면 사용할 UDP 포트와 공유기/Windows 방화벽 정책은 무엇인지?
- 기존 월드 파일은 어느 Steam 계정/월드 인덱스에서 가져올지?
- 백업 보관 위치는 Windows 노트북 로컬 디스크, 외장 디스크, 클라우드 동기화 폴더 중 어디인지?
- 서버 자동 시작은 Windows Task Scheduler로 확정할지?
- 서버 실행 계정은 일반 사용자 계정인지, 별도 로컬 계정을 만들지?
