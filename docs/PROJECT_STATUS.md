# 프로젝트 상태

## 현재 상태

- 프로젝트 단계: M1 Core/Adapter 아키텍처 전환 진행
- 우선 개발 영역: `automation`
- 최신 기준 문서: `docs/research/deep-research-report.md`, `.ai_project/source_of_truth.md`, `.ai/`
- 현재 주요 이슈:
  - 기존 Core Keeper 기반 T1-T9 구현은 첫 Adapter/호환 wrapper로 유지하지만 Windows 실기 검증 전 상태
  - 제품 방향은 Steam Game Server Manager로 전환됨
  - Big Bang Rewrite 없이 Core Keeper를 첫 Adapter로 유지하며 점진적으로 Core/Adapter 구조로 분리 예정
  - macOS에서 문서 구조만 세팅하고, 실제 실행 환경은 Windows 노트북으로 전제
  - 로컬 Git 저장소는 초기화됨
  - 원격 저장소 push 완료됨
  - Steam 전용 접속으로 방향 확정됨
  - 기본 서버 월드는 빈 월드로 시작하고, 기존 월드는 선택적으로 가져오는 방향으로 확정됨
  - AI Agent Ops 운영 구조가 `.ai_project/`로 초기화됨
  - 범용 플랫폼 전환 Task Queue가 등록되었고, GSM-R8까지 완료됨
  - 현재는 후속 Windows 실기 검증 및 다음 개발 Task 선정 대기 상태

## 목표

SteamCMD 기반 Steam 게임 데디케이티드 서버를 Windows 노트북에서 설치, 업데이트, 실행, 백업, 스케줄링할 수 있는 범용 관리 플랫폼을 만든다.

Core Keeper는 첫 번째 지원 게임 Adapter이자 Windows 회귀 검증 기준으로 유지한다.

## 권장 구현 방향

- Windows 노트북에서 clone 후 실행 가능한 PowerShell 중심 플랫폼
- SteamCMD 기반 서버 설치/업데이트는 공통 Core 기능으로 분리
- 게임별 AppID, 실행 파일, 데이터 경로, 백업 대상, 로그 패턴은 Adapter로 분리
- 기존 Core Keeper 스크립트는 호환 wrapper로 유지
- 기본 실행은 수동 실행
- 자동 실행과 특정 시간 재시작은 온/오프 가능한 선택 기능으로 유지
- macOS에서는 실행하지 않고 문서/정적 검증만 수행

## 확정된 운영 기본값

- 서버 설치 경로: 신규 구조 기본값은 `C:\GameServers\<GameId>`, 기존 Core Keeper 설정은 호환 유지
- 백업 경로: 신규 구조 기본값은 `D:\Backups\GameServers\<GameId>`, 기존 Core Keeper 설정은 호환 유지
- SteamCMD 설치 방식: 템플릿에서 자동 다운로드/설치
- 서버 실행 계정: 현재 Windows 로그인 사용자
- Core Keeper Adapter 기본 월드: 새 빈 월드
- Core Keeper 기존 월드: 사용자가 별도 파일로 가져오는 선택 기능
- 절전모드 설정: 자동 변경하지 않고 문서로 안내

## 다음 작업

1. Windows 노트북 또는 `pwsh` 환경에서 AdapterManager PowerShell import 원 검증을 수행한다.
2. Windows 노트북에서 새 구조 기준으로 Core Keeper Adapter 회귀 검증을 진행한다.
3. Valheim Dedicated Server AppID, 기본 포트, 실행 파일, 데이터 경로 후보를 Windows/SteamCMD 환경에서 재검증한다.
4. GSM-R0~GSM-R8 완료 결과를 기준으로 다음 개발 Task를 선정한다.

## 최근 작업

- 2026-06-24: 루트 관리 세션에서 Codex 운영 문서 구조를 생성함.
- 2026-06-24: 로컬 Git 저장소를 초기화하고 원격 저장소 정보를 문서에 반영함.
- 2026-06-24: Steam 전용 SDR(Game ID) 운영과 기본 빈 월드/기존 월드 import 방향을 확정함.
- 2026-06-24: 설치/백업 경로, SteamCMD 자동 설치, 기본 수동 실행, 선택 자동 실행/재시작, 기본 빈 월드 방향을 확정함.
- 2026-06-24: 자동화 개발 계획을 T1-T10 실행 단위로 구체화함.
- 2026-07-01: `.ai/` 템플릿을 도입하고 `.ai_project/` 운영 구조를 초기화함.
- 2026-07-01: 기존 인수인계/범용 Codex 템플릿 문서를 AI Ops 구조로 병합하고 삭제함.
- 2026-07-01: 제품 방향을 Steam Game Server Manager로 전환하고 Core Keeper를 첫 Adapter로 유지하는 점진적 리팩터링 계획을 수립함.
- 2026-07-02: GSM-R1~GSM-R7 Core/Adapter 전환 문서 및 공통 Core 분리 작업을 완료하고 QA에서 `PASS_WITH_RISK`로 확인함.
- 2026-07-02: 상위 문서와 Agent 지침을 Steam Game Server Manager 기준으로 정리하는 T-20260702-002에 착수함.
- 2026-07-02: GSM-R8 Valheim skeleton Adapter를 추가하고 QA에서 `PASS_WITH_RISK`로 확인 후 완료 처리함.

## 열린 질문

- 플랫폼 공식 제품명을 `Steam Game Server Manager`와 `Game Server Manager` 중 무엇으로 확정할지
- Adapter manifest schema의 최소 필수 필드 범위
- Windows 실기 검증에서 Core Keeper Dedicated Server의 최신 실행 파일명과 안전 종료 방식을 확인해야 함
- Valheim Dedicated Server AppID, 포트, 실행 파일, 데이터 경로 후보가 실제 Windows/SteamCMD 환경에서 유효한지
