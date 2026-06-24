# Core Keeper Dedicated Server Automation

Windows 노트북에서 Core Keeper Dedicated Server를 설치하고 수동 실행하기 위한 PowerShell 자동화 템플릿입니다.

현재 범위는 Steam 전용 SDR(Game ID) 접속 방식만 지원합니다. Direct Connect, 공유기 포트포워딩, Windows 방화벽 자동 설정은 구현 범위에서 제외합니다.

## 시작 순서

1. Windows 노트북에 이 저장소를 clone합니다.
2. PowerShell 5.1 이상을 실행합니다.
3. `automation` 폴더로 이동합니다.
4. 필요하면 `config\settings.example.json`을 `config\settings.local.json`으로 복사한 뒤 로컬 경로를 수정합니다.
5. PowerShell 모듈 import를 먼저 확인합니다.

```powershell
cd .\automation
Import-Module .\src\CoreKeeper.Common.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
Get-CKSettings
Test-CKRequiredPaths
```

6. SteamCMD를 설치합니다.

```powershell
.\scripts\install-steamcmd.ps1
```

7. Core Keeper Dedicated Server를 설치하거나 업데이트합니다.

```powershell
.\scripts\install-server.ps1
.\scripts\update-server.ps1
```

8. 서버를 수동으로 시작하고 상태를 확인합니다.

```powershell
.\scripts\start-server.ps1
.\scripts\status-server.ps1
```

9. 필요할 때 Dedicated Server 데이터를 백업합니다.

```powershell
.\scripts\backup-server.ps1 -Reason manual
```

10. 기존 월드를 가져올 때는 서버를 안전하게 중지한 뒤 단일 `.world.gzip` 파일을 import합니다.

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

11. 선택 기능으로 Windows 로그인 시 서버 자동 시작 작업을 등록할 수 있습니다.

```powershell
.\scripts\register-task.ps1
.\scripts\disable-task.ps1
.\scripts\enable-task.ps1
.\scripts\unregister-task.ps1
```

12. 선택 기능으로 특정 시간 재시작 예약 작업을 등록할 수 있습니다.

```powershell
.\scripts\register-restart-task.ps1 -Time "05:00"
.\scripts\unregister-restart-task.ps1
```

기본 경로는 다음과 같습니다.

- 서버 설치 경로: `C:\CoreKeeperServer`
- SteamCMD 설치 경로: `C:\CoreKeeperServer\steamcmd`
- 백업 경로: `D:\Backups\CoreKeeper`
- Dedicated Server App ID: `1963720`

## 설정 파일

기본 설정은 `config\settings.example.json`에 있습니다. 개인 환경 설정은 `config\settings.local.json`에 작성합니다.

`settings.local.json`이 있으면 example 설정 위에 같은 이름의 값을 덮어씁니다. 로컬 설정 파일은 저장소에 커밋하지 않습니다.

## 서버 운영 범위

- 기본 월드는 새 빈 월드입니다.
- 기존 월드는 사용자가 가져온 단일 `.world.gzip` 파일을 import하는 방식으로 지원합니다.
- 사용자 월드 원본 파일은 삭제하지 않습니다.
- Dedicated Server 데이터를 덮어쓰기 전에는 백업을 강제합니다.
- 자동 실행은 Task Scheduler 기반 선택 기능으로 제공합니다.
- 특정 시간 재시작 예약은 안전 종료 방식 확인 전까지 보수적 안내 작업으로 제공합니다.
- 절전모드 설정은 자동 변경하지 않고 사용자가 직접 확인합니다.

## SteamCMD 설치

`scripts\install-steamcmd.ps1`은 다음 순서로 동작합니다.

1. 설정 파일을 읽습니다.
2. `steamCmdPath` 폴더를 확인하거나 생성합니다.
3. `steamcmd.exe`가 이미 있으면 재사용합니다.
4. 없으면 Valve CDN의 Windows SteamCMD zip을 다운로드하고 압축을 해제합니다.
5. 압축 해제 후 `steamcmd.exe` 존재 여부를 확인합니다.

이 단계는 네트워크 연결이 필요합니다.

## Dedicated Server 설치와 업데이트

`scripts\install-server.ps1`과 `scripts\update-server.ps1`은 사용자 명령을 분리하지만 내부에서는 같은 SteamCMD 실행 흐름을 사용합니다.

```text
+force_install_dir C:\CoreKeeperServer +login anonymous +app_update 1963720 validate +quit
```

실패하면 SteamCMD exit code, 실행 명령, output log 경로, SteamCMD logs 경로를 출력합니다.

## 수동 서버 시작과 상태 확인

`scripts\start-server.ps1`은 `C:\CoreKeeperServer` 아래에서 서버 실행 파일 또는 배치 파일 후보를 자동 탐색해 시작합니다. 최신 실행 파일명은 Windows 실기 검증에서 재확인해야 합니다.

`scripts\status-server.ps1`은 다음 정보를 출력합니다.

- 서버 설치 폴더 존재 여부
- Dedicated Server 데이터 폴더 존재 여부
- `worlds` 폴더와 `ServerConfig.json` 존재 여부
- 실행 중인 후보 프로세스
- 최근 로그에서 찾은 Game ID 힌트

`scripts\stop-server.ps1`은 안전 종료 방식이 확인되기 전까지 서버를 강제 종료하지 않습니다. 서버 콘솔 또는 공식 종료 방식으로 직접 종료한 뒤 `status-server.ps1`로 상태를 다시 확인합니다.

## 서버 데이터 백업

`scripts\backup-server.ps1`은 Dedicated Server 데이터 폴더에서 다음 대상을 백업합니다.

- `worlds`
- `worldinfos`
- `ServerConfig.json`

백업 위치는 기본값 `D:\Backups\CoreKeeper`이며, 폴더명은 사유와 시각으로 정합니다.

```text
manual-YYYYMMDD-HHMMSS
before-import-YYYYMMDD-HHMMSS
before-update-YYYYMMDD-HHMMSS
```

백업 대상이 아직 생성되지 않았으면 해당 대상을 건너뛰고 메시지를 출력합니다. 복사 실패는 후속 작업을 중단할 수 있도록 에러로 처리합니다.

## 기존 월드 Import

`scripts\import-world.ps1`은 사용자가 가져온 단일 `.world.gzip` 파일만 Dedicated Server 월드로 복사합니다.

동작 순서:

1. 입력 파일이 존재하고 `.world.gzip`이며 비어 있지 않은지 확인합니다.
2. Dedicated Server 데이터 폴더가 있는지 확인합니다.
3. 서버가 실행 중이면 중단합니다.
4. `before-import-YYYYMMDD-HHMMSS` 백업을 먼저 생성합니다.
5. `worlds\<WorldIndex>.world.gzip`로 복사합니다.
6. `ServerConfig.json`에 알려진 월드 인덱스 필드가 있으면 JSON 파서로 값을 맞춥니다.

기존 대상 월드 파일이 있으면 기본값으로 덮어쓰지 않습니다. 백업을 확인한 뒤 명시적으로 덮어쓰려면 `-ConfirmOverwrite`를 추가합니다.

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

원본 월드 파일은 삭제하지 않습니다. 단일 `.world.gzip`만으로 `worldinfos` 없이 정상 실행되는지는 Windows 실기 검증이 필요합니다.

## 자동 실행 작업

자동 실행은 기본값이 아니라 사용자가 선택해 등록하는 기능입니다.

`scripts\register-task.ps1`은 Windows Task Scheduler에 `CoreKeeperServer` 작업을 등록합니다. 작업 대상은 현재 repo 경로의 `scripts\start-server.ps1`입니다.

관리 명령:

```powershell
.\scripts\register-task.ps1
.\scripts\disable-task.ps1
.\scripts\enable-task.ps1
.\scripts\unregister-task.ps1
```

현재 Windows 로그인 사용자로 실행되도록 등록하며, Direct Connect, 포트포워딩, Windows 방화벽 규칙은 설정하지 않습니다. 관리자 권한이 아닐 때도 사용자 작업 등록은 가능할 수 있지만, Windows 정책에 따라 실패하면 관리자 PowerShell로 다시 실행해야 할 수 있습니다.

## 재시작 예약 작업

`scripts\register-restart-task.ps1`은 Windows Task Scheduler에 `CoreKeeperServerRestart` 작업을 등록합니다.

```powershell
.\scripts\register-restart-task.ps1 -Time "05:00"
.\scripts\unregister-restart-task.ps1
```

시간은 `HH:mm` 24시간 형식만 허용합니다. 예: `05:00`, `23:30`

Core Keeper Dedicated Server의 안전한 종료 방식이 아직 Windows에서 검증되지 않았으므로, 이 작업은 서버를 강제 종료하거나 자동 재시작하지 않습니다. 현재 구현은 지정 시간에 `scripts\stop-server.ps1`을 실행해 안전 종료 미확정 안내를 남기는 보수적 예약 작업입니다. 실제 자동 재시작은 Windows 실기 검증에서 안전 종료 방식이 확인된 뒤 확장합니다.

## 모듈 import 검증

macOS에서는 실제 서버 실행 검증을 하지 않습니다. Windows PowerShell에서 다음 명령으로 모듈 로딩만 먼저 확인합니다.

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
