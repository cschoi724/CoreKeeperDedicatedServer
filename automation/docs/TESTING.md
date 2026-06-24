# 테스트 기준

이 문서는 Windows 노트북에서 실제 검증할 명령 순서를 기록한다. macOS에서는 Windows PowerShell, SteamCMD, Task Scheduler, Core Keeper Dedicated Server 실행 검증을 하지 않는다.

Codex 세션 시작부터 검증 결과 커밋까지의 상세 절차는 `WINDOWS_CODEX_RUNBOOK.md`를 따른다.

## Windows 실기 검증 순서

모든 명령은 Windows PowerShell 5.1 이상에서 `automation/` 폴더 기준으로 실행한다.

### 1. 저장소와 설정 확인

```powershell
cd .\automation
Get-ChildItem .\scripts
Get-Content .\config\settings.example.json
```

필요하면 로컬 설정을 만든다.

```powershell
Copy-Item .\config\settings.example.json .\config\settings.local.json
notepad .\config\settings.local.json
```

### 2. 모듈 import 확인

```powershell
Import-Module .\src\CoreKeeper.Common.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
Import-Module .\src\CoreKeeper.Backup.psm1 -Force
Import-Module .\src\CoreKeeper.SteamCmd.psm1 -Force
Import-Module .\src\CoreKeeper.Server.psm1 -Force
Import-Module .\src\CoreKeeper.Tasks.psm1 -Force
Import-Module .\src\CoreKeeper.World.psm1 -Force
Get-CKSettings
Test-CKRequiredPaths
```

기대 결과:

- 모든 모듈이 import된다.
- `Get-CKSettings`가 설정을 출력한다.
- 초기 상태에서 일부 경로는 아직 `False`일 수 있다.

### 3. SteamCMD 설치

```powershell
.\scripts\install-steamcmd.ps1
Test-Path C:\CoreKeeperServer\steamcmd\steamcmd.exe
```

기대 결과:

- `steamcmd.exe`가 이미 있으면 재사용한다.
- 없으면 `C:\CoreKeeperServer\steamcmd`에 다운로드/압축 해제한다.
- 다운로드 실패, 압축 해제 실패, `steamcmd.exe` 미존재는 명확한 에러로 중단한다.

### 4. Dedicated Server 설치와 업데이트

```powershell
New-CKSteamCmdAppUpdateArguments -Settings (Get-CKSettings)
.\scripts\install-server.ps1
.\scripts\update-server.ps1
Test-Path C:\CoreKeeperServer
```

기대 결과:

- SteamCMD가 없으면 먼저 자동 설치한다.
- SteamCMD 명령은 `+force_install_dir C:\CoreKeeperServer +login anonymous +app_update 1963720 validate +quit` 흐름을 사용한다.
- 반복 실행해도 `app_update 1963720 validate`로 설치/업데이트를 재수행한다.
- 실패 시 SteamCMD exit code, 실행 명령, output log, SteamCMD logs 경로를 출력한다.

### 5. 서버 수동 시작과 상태 확인

```powershell
Get-CKServerLaunchCandidates
Get-CKServerStatus
.\scripts\start-server.ps1
.\scripts\status-server.ps1
```

기대 결과:

- 설치 폴더에서 서버 실행 파일/배치 파일 후보를 찾는다.
- 서버를 수동 시작한다.
- 서버 콘솔 또는 로그에서 Steam SDR Game ID를 확인할 수 있다.
- `status-server.ps1`이 설치 폴더, Dedicated Server 데이터 폴더, `worlds`, `ServerConfig.json`, 실행 프로세스, Game ID 로그 힌트를 출력한다.

### 6. 서버 중지 안내 확인

```powershell
.\scripts\stop-server.ps1
.\scripts\status-server.ps1
```

기대 결과:

- `stop-server.ps1`은 서버를 강제 종료하지 않는다.
- 안전 종료 방식이 Windows에서 확인되기 전까지 수동 종료 안내만 출력한다.

### 7. 백업

```powershell
Get-CKBackupTargets
.\scripts\backup-server.ps1 -Reason manual
Test-Path D:\Backups\CoreKeeper
```

기대 결과:

- `D:\Backups\CoreKeeper\manual-YYYYMMDD-HHMMSS` 백업 폴더가 생성된다.
- `worlds`, `worldinfos`, `ServerConfig.json`이 있으면 백업 폴더로 복사된다.
- 백업 대상이 없으면 skip 메시지를 출력하고 manifest를 생성한다.
- 복사 실패는 에러로 중단되어 후속 destructive 작업을 막을 수 있다.

### 8. 기존 월드 Import

서버를 안전하게 중지한 상태에서 실행한다.

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worlds\0.world.gzip"
```

기대 결과:

- 입력 파일이 단일 `.world.gzip`이 아니거나 비어 있으면 중단한다.
- Dedicated Server 데이터 폴더가 없으면 먼저 서버를 1회 실행하라고 안내하고 중단한다.
- 서버가 실행 중이면 import를 중단한다.
- import 전 `before-import-YYYYMMDD-HHMMSS` 백업을 강제한다.
- 기존 대상 파일이 있으면 `-ConfirmOverwrite` 없이는 덮어쓰지 않는다.
- 원본 월드 파일은 삭제하지 않는다.
- `ServerConfig.json`에 알려진 월드 인덱스 필드가 있으면 JSON 파서로 업데이트한다.

덮어쓰기 확인 검증:

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

### 9. 자동 실행 작업

```powershell
Test-CKAdministrator
.\scripts\register-task.ps1
Get-ScheduledTask -TaskName CoreKeeperServer
.\scripts\disable-task.ps1
.\scripts\enable-task.ps1
.\scripts\unregister-task.ps1
```

기대 결과:

- 작업 이름은 `CoreKeeperServer`이다.
- 작업 실행 대상은 현재 repo 경로의 `automation\scripts\start-server.ps1`이다.
- 자동 실행은 사용자가 `register-task.ps1`을 실행할 때만 등록된다.
- 등록/해제/활성화/비활성화가 가능하다.
- 관리자 권한이 아니면 안내 메시지를 출력하고, Windows 정책상 실패하면 관리자 PowerShell 재실행 안내가 포함된 에러로 중단한다.
- Direct Connect, 포트포워딩, Windows 방화벽 자동 설정은 수행하지 않는다.

### 10. 재시작 예약 작업

```powershell
Assert-CKRestartTime -Time "05:00"
.\scripts\register-restart-task.ps1 -Time "05:00"
Get-ScheduledTask -TaskName CoreKeeperServerRestart
.\scripts\unregister-restart-task.ps1
```

잘못된 시간 형식 거부 확인:

```powershell
.\scripts\register-restart-task.ps1 -Time "5:00"
.\scripts\register-restart-task.ps1 -Time "24:00"
```

기대 결과:

- 작업 이름은 `CoreKeeperServerRestart`이다.
- 시간 입력은 `HH:mm` 24시간 형식만 허용한다.
- 기본 추천 시간은 없고 사용자가 `-Time`으로 명시해야 한다.
- 안전 종료 방식이 Windows에서 확인되기 전까지 강제 종료 기반 재시작을 등록하지 않는다.
- 현재 구현은 지정 시간에 `stop-server.ps1` 안전 종료 안내를 실행하는 보수적 예약 작업이다.

## PowerShell 문법 검사 후보

Windows PowerShell에서 실행한다.

```powershell
Get-ChildItem .\scripts\*.ps1 | ForEach-Object {
  $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$null)
}
```

PSScriptAnalyzer 도입 시 후보:

```powershell
Invoke-ScriptAnalyzer -Path .\scripts -Recurse
```

## macOS 검증 기록

- 날짜: 2026-06-24
- 명령: `git status -sb`
- 결과: 작업 전 상태 확인 완료
- 비고: 실제 서버 실행 환경은 Windows 노트북이며, macOS에서는 서버 실행 검증을 하지 않음

- 날짜: 2026-06-24
- 명령: `command -v pwsh`
- 결과: 로컬 macOS 환경에 `pwsh` 없음
- 비고: PowerShell 모듈 import, SteamCMD 설치, Task Scheduler 검증은 Windows 노트북에서 수행 필요

- 날짜: 2026-06-24
- 명령: `git diff --cached --check`
- 결과: T3-T8 스테이징 기준 공백 오류 없음
- 비고: 각 커밋 전 확인 완료

- 날짜: 2026-06-24
- 명령: `rg -n 'migrate[-]world|월드[ ]이전|TODO' README.md automation/README.md automation/docs`
- 결과: T9 문서 정리 기준 오래된 스크립트명, 오래된 월드 이전 표현, TODO 없음
- 비고: 루트 저장소 기준으로 실행

- 날짜: 2026-06-24
- 명령: `rg -n "미확정" automation/README.md automation/docs`
- 결과: `미확정` 표현 없음
- 비고: 안전 종료와 재시작 예약 제한은 `미검증`으로 표기

## Windows 미검증 항목

- PowerShell 모듈 import가 Windows PowerShell 5.1에서 통과하는지
- SteamCMD 자동 다운로드/압축 해제가 동작하는지
- SteamCMD anonymous `app_update 1963720 validate`가 성공하는지
- Core Keeper Dedicated Server 최신 Windows 실행 파일명/배치 파일명이 현재 후보 목록과 일치하는지
- Game ID가 콘솔 또는 로그에서 확인되는지
- Dedicated Server 데이터 경로가 현재 후보와 일치하는지
- 안전한 서버 종료 방식이 무엇인지
- `D:\Backups\CoreKeeper` 생성과 Dedicated Server 데이터 백업이 동작하는지
- 단일 `.world.gzip` import가 `worldinfos` 없이 정상 실행되는지
- 최신 `ServerConfig.json` 월드 인덱스 필드명이 현재 후보 목록과 일치하는지
- Task Scheduler `CoreKeeperServer` 작업 등록/해제/활성화/비활성화가 동작하는지
- Task Scheduler 등록에 관리자 권한이 필요한 Windows 정책인지
- Task Scheduler `CoreKeeperServerRestart` 작업 등록/해제가 동작하는지
- 재시작 예약은 안전 종료 방식 확인 전까지 실제 강제 재시작을 수행하지 않음

## 현재 범위 밖

- Direct Connect 구현
- 공유기 포트포워딩 안내 자동화
- Windows 방화벽 자동 설정
- Windows 전원/절전모드 자동 변경
- 서버 강제 종료 기반 재시작
