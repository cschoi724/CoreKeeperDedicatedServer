# Core Keeper Dedicated Server Automation

Windows 노트북에서 Core Keeper Dedicated Server를 설치, 업데이트, 수동 실행, 백업, 기존 월드 import, 선택 자동 실행까지 진행하기 위한 PowerShell 자동화 템플릿입니다.

현재 지원 범위는 Steam 전용 SDR(Game ID) 접속입니다. Direct Connect, 공유기 포트포워딩, Windows 방화벽 자동 설정은 현재 범위 밖입니다.

## 전제와 기본값

- 실행 대상: Windows 노트북
- PowerShell: Windows PowerShell 5.1 이상
- 서버 설치 경로: `C:\CoreKeeperServer`
- SteamCMD 설치 경로: `C:\CoreKeeperServer\steamcmd`
- 백업 경로: `D:\Backups\CoreKeeper`
- Dedicated Server App ID: `1963720`
- 기본 실행 방식: 수동 실행
- 자동 실행: 사용자가 선택해 Task Scheduler 작업으로 등록
- 재시작 예약: 안전 종료 방식 검증 전까지 안내 작업만 등록
- 기본 월드: 새 빈 월드
- 기존 월드: 사용자가 가져온 단일 `.world.gzip` 파일 import

macOS에서는 문서와 템플릿만 편집합니다. SteamCMD, Task Scheduler, Core Keeper Dedicated Server 실행 검증은 Windows 노트북에서 진행합니다.

Windows 노트북에서 Codex 세션을 열어 검증하는 자세한 절차는 `docs\WINDOWS_CODEX_RUNBOOK.md`를 따릅니다.

## 처음 설치와 빈 월드 시작

Windows 노트북에서 저장소를 clone한 뒤 `automation` 폴더로 이동합니다.

```powershell
cd .\automation
```

필요하면 로컬 설정 파일을 만듭니다.

```powershell
Copy-Item .\config\settings.example.json .\config\settings.local.json
notepad .\config\settings.local.json
```

PowerShell 모듈 import와 설정 로딩을 확인합니다.

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

SteamCMD를 설치합니다.

```powershell
.\scripts\install-steamcmd.ps1
```

Core Keeper Dedicated Server를 설치합니다.

```powershell
.\scripts\install-server.ps1
```

서버를 수동으로 시작합니다.

```powershell
.\scripts\start-server.ps1
```

서버 콘솔 또는 로그에서 Steam SDR Game ID를 확인해 친구에게 공유합니다. 상태 확인은 별도 PowerShell에서 실행합니다.

```powershell
.\scripts\status-server.ps1
```

## 업데이트

서버를 안전하게 중지한 뒤 업데이트합니다.

```powershell
.\scripts\update-server.ps1
```

업데이트 전 백업을 남기려면 다음 명령을 먼저 실행합니다.

```powershell
.\scripts\backup-server.ps1 -Reason before-update
```

## 서버 중지

`scripts\stop-server.ps1`은 서버를 강제 종료하지 않습니다.

```powershell
.\scripts\stop-server.ps1
```

Core Keeper Dedicated Server의 안전한 종료 방식은 Windows 실기 검증 전까지 미검증입니다. 서버 콘솔 또는 공식 종료 방식으로 직접 종료한 뒤 상태를 다시 확인합니다.

```powershell
.\scripts\status-server.ps1
```

## 백업

Dedicated Server 데이터 백업은 다음 대상을 복사합니다.

- `worlds`
- `worldinfos`
- `ServerConfig.json`

수동 백업:

```powershell
.\scripts\backup-server.ps1 -Reason manual
```

백업 폴더명:

```text
manual-YYYYMMDD-HHMMSS
before-import-YYYYMMDD-HHMMSS
before-update-YYYYMMDD-HHMMSS
```

백업 대상이 아직 없으면 해당 대상은 건너뛰고 manifest만 남깁니다. 복사 실패는 에러로 중단됩니다.

## 기존 월드 Import

기존 월드는 사용자가 가져온 단일 `.world.gzip` 파일만 지원합니다. 원본 월드 파일은 삭제하지 않습니다.

절차:

1. 서버를 안전하게 중지합니다.
2. 현재 서버 데이터를 백업합니다.
3. `.world.gzip` 파일을 Dedicated Server `worlds\<WorldIndex>.world.gzip`로 복사합니다.
4. `ServerConfig.json`에 알려진 월드 인덱스 필드가 있으면 JSON 파서로 값을 맞춥니다.

기본 import:

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

기존 대상 월드 파일이 있으면 기본값으로 덮어쓰지 않습니다. 백업을 확인한 뒤 명시적으로 덮어쓰려면 다음처럼 실행합니다.

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

단일 `.world.gzip`만으로 `worldinfos` 없이 정상 실행되는지는 Windows 실기 검증이 필요합니다.

## 자동 실행 작업

자동 실행은 기본값이 아닙니다. 사용자가 선택할 때만 Windows Task Scheduler 작업을 등록합니다.

등록되는 작업:

- 작업 이름: `CoreKeeperServer`
- 실행 대상: 현재 repo 경로의 `automation\scripts\start-server.ps1`
- 실행 계정: 현재 Windows 로그인 사용자
- 트리거: 현재 사용자 로그온

명령:

```powershell
.\scripts\register-task.ps1
.\scripts\disable-task.ps1
.\scripts\enable-task.ps1
.\scripts\unregister-task.ps1
```

관리자 권한이 아닐 때도 현재 사용자 작업 등록은 가능할 수 있습니다. Windows 정책상 실패하면 관리자 PowerShell에서 다시 실행해야 할 수 있습니다.

## 재시작 예약 작업

재시작 예약은 선택 기능입니다. 시간은 `HH:mm` 24시간 형식만 허용합니다.

```powershell
.\scripts\register-restart-task.ps1 -Time "05:00"
.\scripts\unregister-restart-task.ps1
```

등록되는 작업:

- 작업 이름: `CoreKeeperServerRestart`
- 현재 동작: 지정 시간에 `automation\scripts\stop-server.ps1` 실행

안전 종료 방식이 아직 검증되지 않았으므로 이 작업은 서버를 강제 종료하거나 자동 재시작하지 않습니다. 현재 구현은 안전 종료 미검증 안내 작업입니다. 실제 자동 재시작은 Windows 실기 검증에서 안전 종료 방식이 확인된 뒤 확장합니다.

## 스크립트 목록

| 스크립트 | 용도 |
| --- | --- |
| `scripts\install-steamcmd.ps1` | SteamCMD 자동 설치 |
| `scripts\install-server.ps1` | Core Keeper Dedicated Server 설치 |
| `scripts\update-server.ps1` | Core Keeper Dedicated Server 업데이트 |
| `scripts\start-server.ps1` | 서버 수동 시작 |
| `scripts\status-server.ps1` | 서버 설치/데이터/프로세스/Game ID 힌트 상태 확인 |
| `scripts\stop-server.ps1` | 안전 종료 미검증 안내, 강제 종료 안 함 |
| `scripts\backup-server.ps1` | 서버 데이터 백업 |
| `scripts\import-world.ps1` | 단일 `.world.gzip` import |
| `scripts\register-task.ps1` | 자동 실행 작업 등록 |
| `scripts\disable-task.ps1` | 자동 실행 작업 비활성화 |
| `scripts\enable-task.ps1` | 자동 실행 작업 활성화 |
| `scripts\unregister-task.ps1` | 자동 실행 작업 제거 |
| `scripts\register-restart-task.ps1` | 재시작 예약 안내 작업 등록 |
| `scripts\unregister-restart-task.ps1` | 재시작 예약 작업 제거 |

## 현재 범위 밖

- Direct Connect
- 공유기 포트포워딩
- Windows 방화벽 자동 설정
- Windows 전원/절전모드 자동 변경
- 서버 강제 종료 기반 재시작

절전모드와 최대 절전모드는 Windows 설정에서 사용자가 직접 확인합니다.
