# Core Keeper Dedicated Server Automation Template

Windows 노트북에서 Core Keeper Dedicated Server를 설치하고 운영하기 위한 PowerShell 자동화 템플릿입니다.

실제 사용자는 먼저 [automation/README.md](automation/README.md)를 따라 진행합니다.

## 빠른 시작

Windows PowerShell에서 저장소 루트 기준으로 실행합니다.

```powershell
cd .\automation
Get-Content .\README.md
```

처음 설치와 기본 빈 월드 시작은 `automation/README.md`의 순서를 따릅니다.

1. SteamCMD 자동 설치
2. Dedicated Server 설치
3. 서버 수동 시작
4. Game ID 확인
5. 백업
6. 선택 기능: 기존 `.world.gzip` import
7. 선택 기능: Task Scheduler 자동 실행
8. 선택 기능: 재시작 예약 안내 작업

## 현재 범위

- 실행 대상: Windows 노트북
- 기본 접속 방식: Steam 전용 SDR(Game ID)
- 서버 설치 경로: `C:\CoreKeeperServer`
- 백업 경로: `D:\Backups\CoreKeeper`
- 자동 실행: 사용자가 선택해 Task Scheduler 작업으로 등록
- 재시작 예약: 안전 종료 방식 확인 전까지 안내 작업만 등록

Direct Connect, 공유기 포트포워딩, Windows 방화벽 자동 설정은 현재 범위 밖입니다. Windows 전원/절전모드 설정도 자동 변경하지 않고 문서로 안내합니다.

## 문서

- 사용자 절차: [automation/README.md](automation/README.md)
- Windows Codex 검증 Runbook: [automation/docs/WINDOWS_CODEX_RUNBOOK.md](automation/docs/WINDOWS_CODEX_RUNBOOK.md)
- 자동화 작업 기준: [automation/agents.md](automation/agents.md)
- 개발 계획: [automation/docs/DEVELOPMENT_PLAN.md](automation/docs/DEVELOPMENT_PLAN.md)
- 작업 상태: [automation/docs/STATUS.md](automation/docs/STATUS.md)
- 테스트 기준: [automation/docs/TESTING.md](automation/docs/TESTING.md)
- 운영 설계: [automation/docs/OPERATIONS_DESIGN.md](automation/docs/OPERATIONS_DESIGN.md)
- 월드 import 설계: [automation/docs/WORLD_MIGRATION_DESIGN.md](automation/docs/WORLD_MIGRATION_DESIGN.md)
- 프로젝트 결정사항: [docs/PROJECT_DECISIONS.md](docs/PROJECT_DECISIONS.md)
- Git 전략: [docs/GIT_WORKFLOW.md](docs/GIT_WORKFLOW.md)

## 검증 상태

현재 macOS에서는 문서와 템플릿만 작성합니다. SteamCMD 설치, Dedicated Server 실행, Task Scheduler 작업 등록, Game ID 확인, 기존 월드 import는 Windows 노트북에서 실기 검증해야 합니다.
