# 테스트 기준

이 문서는 Steam Game Server Manager의 검증 기준을 정의한다. macOS에서는 문서와 정적 검증만 수행하고, PowerShell import, SteamCMD, Task Scheduler, Dedicated Server 실행은 Windows에서 검증한다.

Windows Codex 세션의 상세 절차는 `WINDOWS_CODEX_RUNBOOK.md`를 따른다.

## 1. 검증 구분

### macOS 정적 검증

macOS에서 허용되는 검증:

```bash
git status -sb
git diff --check
rg -n "Steam Game Server Manager|Adapter|Core Keeper 전용|T10" automation/README.md automation/docs/TESTING.md automation/docs/WINDOWS_CODEX_RUNBOOK.md
```

PowerShell이 없는 macOS 환경에서는 다음을 실행하지 않는다.

- PowerShell 모듈 import
- SteamCMD 다운로드와 `app_update`
- Core Keeper Dedicated Server 실행
- Task Scheduler 등록
- 실제 월드 import

### Windows 실기 검증

Windows PowerShell 5.1 이상에서 `automation/` 폴더 기준으로 실행한다.

검증은 두 층으로 나눈다.

- 공통 Core 검증: Adapter discovery, 설정 병합, 경로 계산, SteamCMD 명령 생성, 서버/백업/스케줄러 공통 흐름
- Core Keeper Adapter 회귀 검증: AppID `1963720`, SDR Game ID, Core Keeper 데이터 경로, `.world.gzip` import, `ServerConfig.json` world index 패치

## 2. 저장소와 설정 확인

```powershell
cd .\automation
Get-ChildItem .\scripts
Get-Content .\config\manager.example.json
Get-Content .\config\games\corekeeper.example.json
Get-Content .\src\Games\CoreKeeper\game.json
```

필요하면 로컬 설정을 만든다.

```powershell
Copy-Item .\config\manager.example.json .\config\manager.local.json
Copy-Item .\config\games\corekeeper.example.json .\config\games\corekeeper.local.json
notepad .\config\manager.local.json
notepad .\config\games\corekeeper.local.json
```

기존 Core Keeper 전용 설정 호환을 확인해야 할 때만 `settings.local.json`을 사용한다.

## 3. 공통 Core 모듈 검증

```powershell
Import-Module .\src\Core\AdapterManager.psm1 -Force
Import-Module .\src\Core\ConfigManager.psm1 -Force
Import-Module .\src\Core\PathManager.psm1 -Force
Import-Module .\src\Core\SteamCmdManager.psm1 -Force
Import-Module .\src\Core\ServerManager.psm1 -Force
Import-Module .\src\Core\BackupManager.psm1 -Force
Import-Module .\src\Core\SchedulerManager.psm1 -Force

Get-GameServerAdapterList
Get-GameServerAdapter -Game corekeeper
Get-GameServerSettings -Game corekeeper
Get-GameServerPathSet -Game corekeeper
$settings = Get-GameServerSettings -Game corekeeper
New-GameServerSteamCmdAppUpdateArguments -Settings $settings
Get-GameServerBackupTargets -Game corekeeper
Test-GameServerAdministrator
```

기대 결과:

- `corekeeper` Adapter가 발견된다.
- 설정은 manager 설정, game 설정, manifest, 기존 `settings.local.json` fallback 순서를 반영한다.
- Core Keeper 전용 AppID와 경로는 Adapter 또는 compatibility wrapper를 통해서만 나타난다.

## 4. Core Keeper 호환 wrapper 검증

```powershell
Import-Module .\src\CoreKeeper.Common.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
Import-Module .\src\CoreKeeper.SteamCmd.psm1 -Force
Import-Module .\src\CoreKeeper.Server.psm1 -Force
Import-Module .\src\CoreKeeper.Backup.psm1 -Force
Import-Module .\src\CoreKeeper.Tasks.psm1 -Force
Import-Module .\src\CoreKeeper.World.psm1 -Force

Get-CKSettings
Get-CKPathSet
Test-CKRequiredPaths
Get-CKBackupTargets
Get-CKServerStatus
```

기대 결과:

- 기존 `CoreKeeper.*` 함수명이 유지된다.
- 내부 동작은 공통 Core 또는 Core Keeper Adapter로 위임된다.

## 5. SteamCMD 설치와 서버 설치

먼저 WhatIf 경로를 확인한다.

```powershell
.\scripts\install-steamcmd.ps1 -Game corekeeper -WhatIf
.\scripts\install-server.ps1 -Game corekeeper -WhatIf
.\scripts\update-server.ps1 -Game corekeeper -WhatIf
```

실제 설치:

```powershell
.\scripts\install-steamcmd.ps1 -Game corekeeper
.\scripts\install-server.ps1 -Game corekeeper
.\scripts\update-server.ps1 -Game corekeeper
```

기대 결과:

- SteamCMD가 없으면 설치된다.
- SteamCMD 명령은 Adapter 설정의 `appId`와 `login`을 사용한다.
- Core Keeper Adapter의 기본 AppID는 `1963720`, login은 `anonymous`다.

## 6. 서버 시작과 상태 확인

```powershell
Get-GameServerLaunchCandidates -Game corekeeper
Get-GameServerStatus -Game corekeeper
.\scripts\status-server.ps1 -Game corekeeper
.\scripts\start-server.ps1 -Game corekeeper
```

별도 PowerShell 창에서:

```powershell
cd .\automation
.\scripts\status-server.ps1 -Game corekeeper
```

기대 결과:

- 설치 폴더에서 실행 후보를 찾는다.
- 실행 프로세스가 상태에 반영된다.
- 콘솔 또는 로그에서 SDR Game ID를 확인할 수 있다.

## 7. 서버 중지 안내

```powershell
.\scripts\stop-server.ps1 -Game corekeeper
.\scripts\status-server.ps1 -Game corekeeper
```

기대 결과:

- 스크립트는 강제 종료를 수행하지 않는다.
- 안전 종료 방식 미검증 안내가 유지된다.

## 8. 백업

```powershell
Get-GameServerBackupTargets -Game corekeeper
.\scripts\backup-server.ps1 -Game corekeeper -Reason manual -WhatIf
.\scripts\backup-server.ps1 -Game corekeeper -Reason manual
```

기대 결과:

- 백업 대상은 Adapter manifest의 `backup.targets`에서 온다.
- Core Keeper 대상은 `worlds`, `worldinfos`, `ServerConfig.json`이다.
- 누락 대상은 skip 메시지와 manifest에 기록된다.
- 사용자 데이터 삭제나 이동은 수행하지 않는다.

## 9. Core Keeper Adapter 월드 Import

서버를 안전하게 중지한 상태에서 실행한다.

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -WhatIf
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

덮어쓰기 확인:

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

기대 결과:

- Adapter가 `features.worldImport`를 지원하는지 확인한다.
- 입력 파일이 단일 `.world.gzip`이 아니거나 비어 있으면 중단한다.
- 서버가 실행 중이면 import를 중단한다.
- import 전 `before-import-*` 백업을 강제한다.
- 기존 대상 파일이 있으면 `-ConfirmOverwrite` 없이는 덮어쓰지 않는다.
- 원본 월드 파일은 삭제하거나 이동하지 않는다.
- `ServerConfig.json`에 알려진 월드 인덱스 필드가 있으면 JSON 파서로 업데이트한다.

## 10. Task Scheduler

자동 실행:

```powershell
.\scripts\register-task.ps1 -Game corekeeper -WhatIf
.\scripts\register-task.ps1 -Game corekeeper
Get-ScheduledTask -TaskName CoreKeeperServer
.\scripts\disable-task.ps1 -Game corekeeper
.\scripts\enable-task.ps1 -Game corekeeper
.\scripts\unregister-task.ps1 -Game corekeeper
```

재시작 예약:

```powershell
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "05:00" -WhatIf
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "05:00"
Get-ScheduledTask -TaskName CoreKeeperServerRestart
.\scripts\unregister-restart-task.ps1 -Game corekeeper
```

잘못된 시간 형식:

```powershell
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "5:00"
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "24:00"
```

기대 결과:

- 작업 이름은 설정 병합 결과를 따른다.
- 현재 사용자 로그온 작업 등록/해제가 가능하다.
- 관리자 권한 요구 여부를 기록한다.
- 재시작 예약은 안전 종료 방식 확인 전까지 강제 종료나 자동 재시작을 수행하지 않는다.

## 11. Windows 미검증 항목

- PowerShell 모듈 import가 Windows PowerShell 5.1에서 통과하는지
- SteamCMD 자동 다운로드/압축 해제가 동작하는지
- SteamCMD anonymous `app_update 1963720 validate`가 성공하는지
- 최신 Core Keeper Dedicated Server 실행 파일명/배치 파일명이 현재 후보 목록과 일치하는지
- SDR Game ID가 콘솔 또는 로그에서 확인되는지
- Dedicated Server 데이터 경로가 현재 후보와 일치하는지
- 안전한 서버 종료 방식이 무엇인지
- 백업 경로 생성과 Dedicated Server 데이터 백업이 동작하는지
- 단일 `.world.gzip` import가 `worldinfos` 없이 정상 실행되는지
- 최신 `ServerConfig.json` 월드 인덱스 필드명이 현재 후보 목록과 일치하는지
- Task Scheduler 작업 등록/해제가 동작하는지
- Task Scheduler 등록에 관리자 권한이 필요한 Windows 정책인지

## 12. T10 증거 수집 체크리스트

T10은 기존 이름을 유지하는 Windows 실기 검증/증거 수집 단계다. 새 구조에서는 아래 항목을 공통 Core와 Core Keeper Adapter 회귀 검증 결과로 나누어 기록한다.

- PowerShell 버전과 실행 정책
- Adapter discovery 출력
- 설정 병합 결과와 실제 경로
- SteamCMD 설치 경로와 `app_update` 출력
- Dedicated Server 실행 파일명 또는 배치 파일명
- 서버 시작 콘솔 출력
- Game ID 출력 위치와 값 변경 방식
- Dedicated Server 데이터 경로
- `worlds`, `worldinfos`, `ServerConfig.json` 실제 존재 여부
- `ServerConfig.json` 실제 필드명과 월드 인덱스 지정 방식
- 서버 로그 파일 위치와 주요 로그 형식
- 플레이어 접속/퇴장 시 콘솔 또는 로그 출력
- 플레이어 0명일 때 sleep/idle 진입 로그
- 플레이어 재접속 시 sleep/idle에서 복귀하는지
- 안전 종료 명령과 저장 완료 시점
- 실행 중 백업의 안전성
- Task Scheduler 자동 실행과 예약 작업의 실제 동작 결과

자동 백업 정책, Watchdog, Discord Webhook, 상태 조회 확장은 위 증거 수집 이후 별도 Task로 분리한다.
