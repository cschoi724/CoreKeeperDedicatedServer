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
- 기존 월드는 사용자가 가져온 단일 `.world.gzip` 파일을 import하는 방식으로만 지원할 예정입니다.
- 사용자 월드 원본 파일은 삭제하지 않습니다.
- Dedicated Server 데이터를 덮어쓰기 전에는 백업을 강제합니다.
- 자동 실행과 특정 시간 재시작은 추후 Task Scheduler 기반 선택 기능으로 제공합니다.
- 절전모드 설정은 자동 변경하지 않고 사용자가 직접 확인합니다.

## 모듈 import 검증

macOS에서는 실제 서버 실행 검증을 하지 않습니다. Windows PowerShell에서 다음 명령으로 모듈 로딩만 먼저 확인합니다.

```powershell
Import-Module .\src\CoreKeeper.Common.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
Get-CKSettings
Test-CKRequiredPaths
```
