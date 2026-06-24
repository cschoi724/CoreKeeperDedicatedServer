# Core Keeper Dedicated Server Automation Template

기존 Core Keeper Steam 호스트 월드를 Windows 노트북의 Dedicated Server로 이전해, 사용자가 게임에 접속하지 않아도 친구들이 접속할 수 있게 만드는 자동화 템플릿 프로젝트입니다.

## 현재 상태

- 현재 단계: 문서 기반 준비
- 현재 세션 역할: 루트 관리 에이전트
- 실제 구현: 아직 없음
- 실행 대상: Windows 노트북
- 현재 macOS에서는 서버 설치/실행을 하지 않음
- 원격 저장소: `https://github.com/cschoi724/CoreKeeperDedicatedServer.git`

## 문서

- 루트 운영 기준: `agents.md`
- 프로젝트 상태: `docs/PROJECT_STATUS.md`
- 결정사항: `docs/PROJECT_DECISIONS.md`
- Git 전략: `docs/GIT_WORKFLOW.md`
- 세션 인수인계: `docs/SESSION_HANDOFF.md`
- 자동화 작업 영역: `automation/agents.md`
- 개발 계획: `automation/docs/DEVELOPMENT_PLAN.md`
- 운영 옵션 설명: `docs/product/OPERATING_OPTIONS.md`
- 기존 월드 이전 설계: `automation/docs/WORLD_MIGRATION_DESIGN.md`
- 리서치 문서: `deep-research-report.md`

## 다음 단계

1. Windows 노트북의 서버 운영 세부값을 확정한다.
2. `automation/` 작업 영역에서 PowerShell 기반 템플릿 구현을 시작한다.
3. Windows 환경에서 SteamCMD와 Dedicated Server 실행 방식을 검증한다.

## 주요 열린 질문

- 결정: 현재는 Steam 접속만 사용하므로 SDR(Game ID)를 기본으로 한다.
- SteamCMD를 템플릿이 직접 설치할지, 사용자가 미리 설치할지?
- 기존 월드 파일 위치와 월드 인덱스는 무엇인지?
- 백업 보관 위치와 보존 정책은 어떻게 할지?
