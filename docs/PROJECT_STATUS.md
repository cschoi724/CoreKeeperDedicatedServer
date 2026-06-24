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
  - 기본 서버 월드는 빈 월드로 시작하고, 기존 월드는 선택적으로 가져오는 방향으로 확정됨

## 목표

Steam에서 직접 호스트하던 기존 Core Keeper 월드를 Dedicated Server로 이전하여, 사용자가 게임에 접속하지 않아도 친구들이 접속할 수 있는 Windows용 자동화 템플릿을 만든다.

## 권장 구현 방향 초안

- Windows 노트북에서 clone 후 실행 가능한 PowerShell 중심 템플릿
- SteamCMD 기반 Core Keeper Dedicated Server 설치/업데이트
- 기본 접속 방식은 SDR(Game ID)
- Direct Connect는 현재 구현 우선순위에서 제외
- 기본은 수동 실행
- 자동 실행과 특정 시간 재시작은 온/오프 가능한 선택 기능으로 분리
- 기존 월드 가져오기, 백업, 업데이트, 시작/중지 관리를 별도 명령으로 분리
- macOS에서는 실행하지 않고 문서/템플릿 작성만 수행

## 확정된 운영 기본값

- 서버 설치 경로: `C:\CoreKeeperServer`
- 백업 경로: `D:\Backups\CoreKeeper`
- SteamCMD 설치 방식: 템플릿에서 자동 다운로드/설치
- 서버 실행 계정: 현재 Windows 로그인 사용자
- Windows 노트북의 Core Keeper 실행 이력: 없음
- 서버 기본 월드: 새 빈 월드
- 기존 월드: 사용자가 별도 파일로 가져오는 선택 기능
- 절전모드 설정: 자동 변경하지 않고 문서로 안내

## 다음 작업

1. `automation/docs/DEVELOPMENT_PLAN.md`의 T1 자동화 골격 생성부터 진행한다.
2. T2 SteamCMD 자동 설치를 구현한다.
3. T3 Dedicated Server 설치/업데이트를 구현한다.
4. T4 수동 서버 시작과 상태 확인을 구현한다.
5. 집 Windows 노트북의 새 Codex 세션에서 T10 실기 검증을 진행한다.

## 최근 작업

- 2026-06-24: 루트 관리 세션에서 Codex 운영 문서 구조를 생성함.
- 2026-06-24: 로컬 Git 저장소를 초기화하고 원격 저장소 정보를 문서에 반영함.
- 2026-06-24: Steam 전용 SDR(Game ID) 운영과 기본 빈 월드/기존 월드 import 방향을 확정함.
- 2026-06-24: 설치/백업 경로, SteamCMD 자동 설치, 기본 수동 실행, 선택 자동 실행/재시작, 기본 빈 월드 방향을 확정함.
- 2026-06-24: 자동화 개발 계획을 T1-T10 실행 단위로 구체화함.

## 열린 질문

- Windows 실기 검증에서 Core Keeper Dedicated Server의 최신 실행 파일명과 안전 종료 방식을 확인해야 함
- 기존 월드 파일을 사용자가 어떤 형태로 가져올지: 단일 `.world.gzip` 파일 또는 `worlds/worldinfos` 폴더 묶음
- 자동 재시작 시간을 설정할 때 기본 추천 시간을 둘지, 항상 사용자 입력으로 받을지
