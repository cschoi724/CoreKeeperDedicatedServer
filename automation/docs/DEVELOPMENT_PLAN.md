# 개발 계획

이 문서는 `automation/` 영역의 실제 진행 기준이다.

2026-07-01부터 프로젝트 방향은 **Core Keeper 중심 자동화 템플릿**에서 **Steam 게임 데디케이티드 서버 관리 플랫폼**으로 전환한다. Core Keeper는 삭제 대상이 아니라 첫 번째 공식 지원 게임 Adapter이자 회귀 검증 기준으로 유지한다.

## 1. 제품 방향

### 변경 전

```text
기존 Core Keeper 중심 자동화 템플릿
```

### 변경 후

```text
Steam Game Server Manager
```

또는 짧게:

```text
Game Server Manager
```

최종 목표는 SteamCMD 기반 데디케이티드 서버를 게임별 Adapter로 확장할 수 있는 Windows 자동화 플랫폼이다.

## 2. 핵심 원칙

- Big Bang Rewrite를 하지 않는다.
- 기존 Core Keeper 기능은 동작 가능한 상태로 유지하면서 점진적으로 분리한다.
- Core 모듈은 특정 게임 이름, AppID, 데이터 경로, 월드 형식을 직접 알지 않는다.
- 게임별 차이는 Adapter 또는 Plugin 계층에 둔다.
- 신규 게임 추가 시 `Games/<GameId>/` Adapter 추가만으로 동작하는 구조를 목표로 한다.
- 기존 사용자 스크립트 이름은 당분간 유지하고, `-Game corekeeper` 기본값을 통해 호환한다.
- Windows 실기 검증 전에는 서버 실행 방식과 안전 종료 방식에 대한 추측 구현을 늘리지 않는다.

## 3. 현재 상태 요약

- 현재 구현 상태: 기존 Core Keeper 중심 T1-T9 완료, Windows 실기 검증 필요
- 기존 구현 위치: `automation/scripts/`, `automation/src/CoreKeeper.*.psm1`
- 기존 검증 기준: `automation/docs/TESTING.md`
- 기존 Core Keeper 구현은 범용화의 출발점으로 사용한다.
- 새 Task 실행 기준은 `.ai_project/tasks/`에 등록된 Task 파일이다.

## 4. 현재 Core Keeper 종속 지점

| 영역 | 현재 종속 내용 | 전환 방향 |
|---|---|---|
| 설정 | `appId: 1963720`, `C:\CoreKeeperServer`, `D:\Backups\CoreKeeper` | 게임별 Adapter manifest로 이동 |
| 모듈명 | `CoreKeeper.*.psm1` | `Core/*.psm1`, `Games/CoreKeeper/*`로 분리 |
| 함수명 | `CK` 접두어 | 공통 함수는 `GSM` 또는 명확한 Manager 이름으로 전환 |
| 경로 | `Pugstorm\Core Keeper\DedicatedServer` | Adapter의 `dataRoot`로 이동 |
| 백업 | `worlds`, `worldinfos`, `ServerConfig.json` 고정 | Adapter의 backup targets로 이동 |
| 실행 | Core Keeper 실행 후보명과 프로세스 패턴 | Adapter의 launch candidates/process patterns로 이동 |
| 월드 import | 단일 `.world.gzip`, world index 수정 | Core Keeper Adapter 전용 기능으로 격리 |
| 상태 조회 | Game ID 로그 탐색 | Adapter의 log/status hint 규칙으로 이동 |
| Task Scheduler | 작업 설명과 이름이 Core Keeper 전용 | 게임 ID 기반 task name 템플릿으로 전환 |

## 5. 목표 구조

초기 전환 목표 구조:

```text
automation/
├── README.md
├── config/
│   ├── manager.example.json
│   ├── settings.example.json
│   └── games/
│       └── corekeeper.example.json
├── scripts/
│   ├── install-steamcmd.ps1
│   ├── install-server.ps1
│   ├── update-server.ps1
│   ├── start-server.ps1
│   ├── stop-server.ps1
│   ├── status-server.ps1
│   ├── backup-server.ps1
│   ├── restore-server.ps1
│   ├── import-world.ps1
│   ├── register-task.ps1
│   ├── unregister-task.ps1
│   ├── enable-task.ps1
│   ├── disable-task.ps1
│   ├── register-restart-task.ps1
│   └── unregister-restart-task.ps1
├── src/
│   ├── Core/
│   │   ├── Common.psm1
│   │   ├── ConfigManager.psm1
│   │   ├── AdapterManager.psm1
│   │   ├── SteamCmdManager.psm1
│   │   ├── ServerManager.psm1
│   │   ├── BackupManager.psm1
│   │   ├── LogManager.psm1
│   │   ├── MonitoringManager.psm1
│   │   └── SchedulerManager.psm1
│   ├── Games/
│   │   └── CoreKeeper/
│   │       ├── CoreKeeper.Adapter.psm1
│   │       └── game.json
│   └── Compatibility/
│       └── CoreKeeper.Legacy.psm1
└── docs/
    ├── ARCHITECTURE.md
    ├── ADAPTER_GUIDE.md
    ├── REFACTORING_PLAN.md
    ├── MIGRATION_STRATEGY.md
    ├── TESTING.md
    └── WINDOWS_CODEX_RUNBOOK.md
```

`settings.example.json`은 즉시 삭제하지 않는다. 기존 설정 호환을 위해 유지하고, 새 구조가 안정화된 뒤 deprecation 문서화 후 제거 여부를 결정한다.

## 6. Core와 Adapter 책임 분리

### Core 책임

- SteamCMD 다운로드/설치
- SteamCMD 명령 실행
- Steam App 설치/업데이트
- 서버 실행/종료/재시작의 공통 흐름
- 백업/복원 엔진
- 로그 파일 탐색 프레임워크
- 프로세스 모니터링 프레임워크
- Watchdog 프레임워크
- 설정 로딩/병합/검증
- Windows Task Scheduler 등록/해제
- 공통 오류 처리와 사용자 메시지

### Adapter 책임

- Steam AppID
- SteamCMD 로그인 방식
- 설치 경로 기본값
- 데이터 루트 경로
- 실행 파일 후보와 실행 인자
- 프로세스 식별 규칙
- 설정 파일 위치와 수정 방식
- 월드/세이브 저장 위치
- 백업 대상 목록
- 복원/import 규칙
- 기본 포트
- 서버 이름/비밀번호/공개 여부 설정 방식
- 게임별 로그 패턴
- 게임별 Health Check

## 7. Adapter Manifest 초안

`automation/src/Games/CoreKeeper/game.json` 또는 `automation/config/games/corekeeper.example.json`의 기준 초안:

```json
{
  "gameId": "corekeeper",
  "displayName": "Core Keeper",
  "steam": {
    "appId": "1963720",
    "login": "anonymous"
  },
  "paths": {
    "defaultInstallPath": "C:\\GameServers\\CoreKeeper",
    "defaultBackupRoot": "D:\\Backups\\GameServers\\CoreKeeper",
    "dataRoot": "%USERPROFILE%\\AppData\\LocalLow\\Pugstorm\\Core Keeper\\DedicatedServer"
  },
  "server": {
    "launchCandidates": [
      "Launch.bat",
      "LaunchServer.bat",
      "StartServer.bat",
      "CoreKeeperServer.exe",
      "Core Keeper Dedicated Server.exe"
    ],
    "processNamePatterns": [
      "CoreKeeper",
      "Core Keeper",
      "Dedicated"
    ],
    "arguments": []
  },
  "backup": {
    "targets": [
      { "name": "worlds", "path": "worlds", "type": "directory" },
      { "name": "worldinfos", "path": "worldinfos", "type": "directory" },
      { "name": "ServerConfig.json", "path": "ServerConfig.json", "type": "file" }
    ]
  },
  "logs": {
    "directories": [],
    "statusPatterns": [
      "Game ID",
      "GameID",
      "game id",
      "join code",
      "Join Code"
    ]
  },
  "features": {
    "worldImport": true,
    "configPatch": true,
    "gracefulStop": false,
    "healthCheck": false
  }
}
```

## 8. PowerShell Adapter 계약

Adapter는 manifest만으로 처리 가능한 기능을 우선 제공한다. 게임별 코드가 필요한 경우 아래 함수 계약을 선택적으로 구현한다.

필수:

```powershell
Get-GameServerAdapter
Get-GameServerPaths
Get-GameServerLaunchCandidates
Get-GameServerBackupTargets
```

선택:

```powershell
Get-GameServerStatusHints
Import-GameServerWorld
Update-GameServerConfig
Test-GameServerHealth
Stop-GameServerGracefully
```

Core 모듈은 선택 함수가 없을 때 명확한 메시지로 기능 미지원 상태를 보고한다.

## 9. 단계별 리팩터링 계획

### R0. 방향 전환 문서화

상태: 완료

목표:

- 프로젝트 방향을 Core Keeper 전용에서 Steam Game Server Manager로 변경한다.
- Core Keeper를 첫 Adapter로 재정의한다.
- 기존 T10 Windows 검증을 Core Keeper Adapter 회귀 검증으로 재정의한다.

산출물:

- `docs/PROJECT_STATUS.md`
- `docs/PROJECT_DECISIONS.md`
- `automation/docs/DEVELOPMENT_PLAN.md`
- `automation/docs/REFACTORING_PLAN.md`
- `automation/docs/MIGRATION_STRATEGY.md`
- `.ai_project/tasks/`

### R1. Adapter 아키텍처 설계

상태: 완료

목표:

- Core/Adapter 경계를 문서로 확정한다.
- Adapter manifest schema와 함수 계약을 정한다.
- 신규 게임 추가 가이드를 작성한다.

산출물:

- `automation/docs/ARCHITECTURE.md`
- `automation/docs/ADAPTER_GUIDE.md`

검증:

```bash
rg -n "CoreKeeper|Core Keeper|1963720|Pugstorm" automation/docs
```

목표는 해당 문자열이 Core Keeper Adapter 섹션에만 존재하는 것이다.

### R2. Core Keeper Adapter Manifest 도입

상태: 완료

목표:

- 현재 `settings.example.json`의 게임별 값을 Core Keeper Adapter manifest로 이동한다.
- 기존 설정 파일은 fallback으로 유지한다.
- 스크립트에는 `-Game corekeeper` 기본값을 추가한다.

산출물:

- `automation/config/manager.example.json`
- `automation/config/games/corekeeper.example.json`
- `automation/src/Core/AdapterManager.psm1`
- `automation/src/Games/CoreKeeper/game.json`

검증:

```powershell
Import-Module .\src\Core\AdapterManager.psm1 -Force
Get-GameServerAdapter -Game corekeeper
```

### R3. Config/Path Core 분리

상태: 완료

목표:

- `CoreKeeper.Config.psm1`, `CoreKeeper.Paths.psm1`의 범용 로직을 Core 모듈로 분리한다.
- 기존 `Get-CKSettings`, `Get-CKPathSet`은 wrapper로 유지한다.

산출물:

- `automation/src/Core/ConfigManager.psm1`
- `automation/src/Core/PathManager.psm1`
- `automation/src/Compatibility/CoreKeeper.Legacy.psm1`

검증:

```powershell
Import-Module .\src\Core\ConfigManager.psm1 -Force
Import-Module .\src\Core\PathManager.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
```

### R4. SteamCMD Core 분리

상태: 완료

목표:

- SteamCMD 설치와 `app_update` 실행을 게임 무관 모듈로 분리한다.
- AppID와 로그인 방식은 Adapter에서 받는다.
- 기존 Core Keeper 설치/업데이트 스크립트는 wrapper로 유지한다.

산출물:

- `automation/src/Core/SteamCmdManager.psm1`
- `automation/scripts/install-server.ps1`
- `automation/scripts/update-server.ps1`

검증:

```powershell
.\scripts\install-server.ps1 -Game corekeeper -WhatIf
.\scripts\update-server.ps1 -Game corekeeper -WhatIf
```

실제 SteamCMD 실행 검증은 Windows 환경에서만 진행한다.

### R5. Server/Backup/Scheduler Core 분리

상태: 완료

목표:

- 서버 실행 후보, 프로세스 식별, 백업 대상, Task Scheduler 이름을 Adapter 기반으로 전환한다.
- 기존 Core Keeper 동작은 유지한다.

산출물:

- `automation/src/Core/ServerManager.psm1`
- `automation/src/Core/BackupManager.psm1`
- `automation/src/Core/SchedulerManager.psm1`

검증:

```powershell
.\scripts\status-server.ps1 -Game corekeeper
.\scripts\backup-server.ps1 -Game corekeeper -WhatIf
```

### R6. Core Keeper 월드 import Adapter 격리

상태: 완료

목표:

- `.world.gzip` import와 `ServerConfig.json` world index 수정 로직을 Core Keeper Adapter 전용으로 이동한다.
- Core는 Adapter가 world import를 지원하는지 확인하고 위임한다.

산출물:

- `automation/src/Games/CoreKeeper/CoreKeeper.Adapter.psm1`
- `automation/scripts/import-world.ps1`

검증:

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -WhatIf
```

### R7. 문서/테스트 재정렬

상태: 계획

목표:

- 기존 Core Keeper 전용 검증 문서를 공통 플랫폼 검증과 Core Keeper Adapter 검증으로 분리한다.
- Windows Codex Runbook을 새 구조 기준으로 갱신한다.

산출물:

- `automation/docs/TESTING.md`
- `automation/docs/WINDOWS_CODEX_RUNBOOK.md`
- `automation/README.md`

### R8. 두 번째 게임 Skeleton Adapter 추가

상태: 완료

목표:

- Core가 Core Keeper에 종속되지 않았음을 검증하기 위해 두 번째 게임 Adapter skeleton을 추가한다.
- 실제 서버 실행 지원 완료가 아니라 manifest 구조 검증을 목표로 한다.

후보:

- 선택 완료: `Valheim`
- 보류 후보: `Enshrouded`, `AbioticFactor`

완료 조건:

- Core 모듈 수정 없이 Adapter discovery가 동작한다.
- 미구현 기능은 명확히 `unsupported`로 보고된다.

## 10. 마이그레이션 전략

자세한 기준은 `automation/docs/MIGRATION_STRATEGY.md`를 따른다.

요약:

1. 기존 Core Keeper 스크립트 이름을 유지한다.
2. 새 스크립트 인자로 `-Game corekeeper`를 추가하되 기본값으로 둔다.
3. 기존 `settings.local.json`을 fallback으로 읽는다.
4. 새 설정은 `manager.local.json`과 `config/games/<game>.local.json`로 분리한다.
5. 기존 `CoreKeeper.*.psm1` 모듈은 즉시 삭제하지 않고 wrapper로 유지한다.
6. Core Keeper Windows 실기 검증 전에는 기능 동작을 바꾸는 리팩터링을 최소화한다.
7. 각 리팩터링 Task는 QA 통과 후 다음 Task로 넘어간다.

## 11. 실행 Task Queue

실제 실행은 `.ai_project/tasks/`의 Task 파일을 기준으로 한다.

현재 등록 대상:

| 순서 | Task | 목표 | 상태 |
|---:|---|---|---|
| 1 | GSM-R0 | 방향 전환 문서화와 Queue 등록 | done |
| 2 | GSM-R1 | Adapter 아키텍처 문서 작성 | ready_for_qa |
| 3 | GSM-R2 | Core Keeper Adapter manifest 도입 | ready_for_qa |
| 4 | GSM-R3 | Config/Path Core 분리 | ready_for_qa |
| 5 | GSM-R4 | SteamCMD Core 분리 | ready_for_qa |
| 6 | GSM-R5 | Server/Backup/Scheduler Core 분리 | done |
| 7 | GSM-R6 | Core Keeper world import Adapter 격리 | ready_for_qa |
| 8 | GSM-R7 | 테스트/Runbook 재정렬 | done |
| 9 | GSM-R8 | 두 번째 게임 skeleton Adapter 추가 | ready_for_qa |

## 12. Windows 검증 기준 변경

기존 T10은 폐기하지 않고 이름을 바꾼다.

변경 전:

```text
T10 Windows 실기 검증
```

변경 후:

```text
Core Keeper Adapter Windows 회귀 검증
```

검증 대상:

- SteamCMD 설치
- Core Keeper AppID 설치/업데이트
- Core Keeper 서버 시작/상태 확인
- Game ID 확인
- 데이터 경로 확인
- 백업
- 월드 import
- Task Scheduler 등록/해제
- 안전 종료 방식 확인

## 13. 보류 항목

- GUI 또는 웹 대시보드 제공 여부
- Windows 외 Linux/systemd 지원 여부
- 멀티 인스턴스 동시 운영 방식
- 공통 Health Check 표준
- Direct Connect/포트포워딩 자동화
- Discord/Webhook 알림
- 자동 백업 보관 정책
- 서버별 config patch DSL

## 14. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-06-24 | 기존 Core Keeper 중심 T1-T10 개발 계획 작성 |
| 2026-07-01 | Steam Game Server Manager 방향으로 전면 개정, Core/Adapter 리팩터링 계획 추가 |
