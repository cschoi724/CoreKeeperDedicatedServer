# Steam Game Server Manager Automation

Windows 노트북에서 Steam Dedicated Server를 설치, 업데이트, 수동 실행, 백업, 선택 자동 실행까지 재현 가능하게 운영하기 위한 PowerShell 자동화 템플릿입니다.

현재 구현된 Adapter는 `corekeeper` 하나입니다. Core Keeper 전용 AppID, 데이터 경로, 백업 대상, `.world.gzip` import 규칙은 Core가 아니라 Core Keeper Adapter와 compatibility wrapper에 둡니다.

## 지원 범위

- 실행 대상: Windows 노트북
- PowerShell: Windows PowerShell 5.1 이상
- 기본 게임: `corekeeper`
- 접속 방식: Steam SDR Game ID
- 서버 설치: SteamCMD 기반
- 기본 실행: 수동 실행
- 자동 실행: 사용자가 선택할 때만 Task Scheduler 등록
- 재시작 예약: 안전 종료 검증 전까지 안내 작업만 등록
- 기존 월드: 사용자가 가져온 단일 `.world.gzip` 파일 import

현재 범위 밖:

- Direct Connect
- 공유기 포트포워딩
- Windows 방화벽 자동 설정
- Windows 전원/절전모드 자동 변경
- 서버 강제 종료 기반 재시작
- Core Keeper 외 다른 게임의 실제 운영 지원

macOS에서는 문서와 템플릿만 편집합니다. PowerShell import, SteamCMD, Task Scheduler, Dedicated Server 실행 검증은 Windows에서 수행합니다.

## 설정 구조

공통 설정:

```text
config/manager.example.json
config/manager.local.json
```

게임별 설정:

```text
config/games/corekeeper.example.json
config/games/corekeeper.local.json
```

기존 Core Keeper 전용 설정 호환:

```text
config/settings.example.json
config/settings.local.json
```

새 구조에서는 `manager.local.json`과 `games/<game>.local.json`을 우선 사용합니다. 기존 `settings.local.json`은 Core Keeper 호환 fallback으로 유지합니다.

## 기본 사용 흐름

모든 명령은 `automation` 폴더에서 실행합니다.

```powershell
cd .\automation
```

모듈 import와 설정 로딩을 확인합니다.

```powershell
Import-Module .\src\Core\AdapterManager.psm1 -Force
Import-Module .\src\Core\ConfigManager.psm1 -Force
Import-Module .\src\Core\PathManager.psm1 -Force
Import-Module .\src\Core\SteamCmdManager.psm1 -Force
Import-Module .\src\Core\ServerManager.psm1 -Force
Import-Module .\src\Core\BackupManager.psm1 -Force
Import-Module .\src\Core\SchedulerManager.psm1 -Force
Import-Module .\src\CoreKeeper.World.psm1 -Force
Get-GameServerAdapter -Game corekeeper
Get-GameServerSettings -Game corekeeper
```

SteamCMD를 설치하고 서버를 설치합니다.

```powershell
.\scripts\install-steamcmd.ps1 -Game corekeeper
.\scripts\install-server.ps1 -Game corekeeper
```

서버를 수동으로 시작하고 상태를 확인합니다.

```powershell
.\scripts\start-server.ps1 -Game corekeeper
.\scripts\status-server.ps1 -Game corekeeper
```

서버 콘솔 또는 로그에서 Steam SDR Game ID를 확인해 공유합니다.

## 업데이트

서버를 안전하게 중지한 뒤 업데이트합니다.

```powershell
.\scripts\backup-server.ps1 -Game corekeeper -Reason before-update
.\scripts\update-server.ps1 -Game corekeeper
```

SteamCMD 실행 명령은 Adapter 설정의 AppID와 로그인 방식을 사용합니다.

## 서버 중지

`scripts\stop-server.ps1`은 서버를 강제 종료하지 않습니다.

```powershell
.\scripts\stop-server.ps1 -Game corekeeper
```

Core Keeper Dedicated Server의 안전한 종료 방식은 Windows 실기 검증 전까지 미검증입니다. 서버 콘솔 또는 공식 종료 방식으로 직접 종료한 뒤 상태를 다시 확인합니다.

## 백업

백업 대상은 Adapter manifest의 `backup.targets`에서 읽습니다. Core Keeper Adapter의 현재 백업 대상은 다음과 같습니다.

- `worlds`
- `worldinfos`
- `ServerConfig.json`

수동 백업:

```powershell
.\scripts\backup-server.ps1 -Game corekeeper -Reason manual
```

백업 대상이 아직 없으면 해당 대상은 건너뛰고 manifest를 남깁니다. 복사 실패는 에러로 중단됩니다.

## 기존 월드 Import

월드 import는 Core Keeper Adapter가 지원하는 선택 기능입니다. 원본 월드 파일은 삭제하지 않습니다.

검증 실행:

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -WhatIf
```

실제 import:

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

기존 대상 월드 파일이 있으면 기본값으로 덮어쓰지 않습니다. 백업을 확인한 뒤 명시적으로 덮어쓰려면 다음처럼 실행합니다.

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

단일 `.world.gzip`만으로 `worldinfos` 없이 정상 실행되는지는 Windows 실기 검증이 필요합니다.

## 자동 실행 작업

자동 실행은 기본값이 아닙니다. 사용자가 선택할 때만 Windows Task Scheduler 작업을 등록합니다.

```powershell
.\scripts\register-task.ps1 -Game corekeeper -WhatIf
.\scripts\register-task.ps1 -Game corekeeper
.\scripts\disable-task.ps1 -Game corekeeper
.\scripts\enable-task.ps1 -Game corekeeper
.\scripts\unregister-task.ps1 -Game corekeeper
```

작업 이름은 설정 병합 결과의 `taskName`을 사용합니다. 기존 Core Keeper 호환 기본값은 `CoreKeeperServer`입니다.

## 재시작 예약 작업

재시작 예약은 선택 기능입니다. 시간은 `HH:mm` 24시간 형식만 허용합니다.

```powershell
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "05:00" -WhatIf
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "05:00"
.\scripts\unregister-restart-task.ps1 -Game corekeeper
```

안전 종료 방식이 아직 검증되지 않았으므로 이 작업은 서버를 강제 종료하거나 자동 재시작하지 않습니다.

## 검증 문서

- 테스트 기준: `docs\TESTING.md`
- Windows Codex 실기 검증 Runbook: `docs\WINDOWS_CODEX_RUNBOOK.md`
- Adapter 작성 기준: `docs\ADAPTER_GUIDE.md`
- 구조 설명: `docs\ARCHITECTURE.md`

T10이라는 기존 Windows 실기 검증 개념은 유지하되, 새 문서에서는 공통 Core 검증과 Core Keeper Adapter 회귀 검증으로 나누어 기록합니다.
