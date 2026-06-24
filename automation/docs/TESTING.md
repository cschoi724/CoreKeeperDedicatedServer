# 테스트 기준

## 기본 검증 명령

### T1 모듈 import 검증

Windows PowerShell 5.1 이상에서 `automation/` 폴더 기준으로 실행한다.

```powershell
Import-Module .\src\CoreKeeper.Common.psm1 -Force
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
Get-CKSettings
Test-CKRequiredPaths
```

`Test-CKRequiredPaths`는 아직 디렉터리를 만들지 않은 초기 상태에서 `False` 값을 포함할 수 있다.

### T2 SteamCMD 설치 검증

Windows PowerShell 5.1 이상에서 `automation/` 폴더 기준으로 실행한다.

```powershell
Import-Module .\src\CoreKeeper.SteamCmd.psm1 -Force
Get-CKSteamCmdDownloadUrl
.\scripts\install-steamcmd.ps1
Test-Path C:\CoreKeeperServer\steamcmd\steamcmd.exe
```

기대 결과:

- `steamcmd.exe`가 이미 있으면 재사용한다.
- 없으면 `C:\CoreKeeperServer\steamcmd`에 다운로드/압축 해제한다.
- 다운로드 실패, 압축 해제 실패, `steamcmd.exe` 미존재는 명확한 에러로 중단한다.

### T3 Dedicated Server 설치/업데이트 검증

Windows PowerShell 5.1 이상에서 `automation/` 폴더 기준으로 실행한다.

```powershell
Import-Module .\src\CoreKeeper.SteamCmd.psm1 -Force
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

### PowerShell 문법 검사 후보

```powershell
Get-ChildItem .\scripts\*.ps1 | ForEach-Object {
  $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$null)
}
```

```powershell
# PSScriptAnalyzer 도입 시 후보
Invoke-ScriptAnalyzer -Path .\scripts -Recurse
```

## Windows 실기 검증 항목

- 저장소 clone 후 README 절차만으로 시작 가능한지
- SteamCMD 설치 또는 경로 확인이 동작하는지
- App ID `1963720` 설치/업데이트가 동작하는지
- 첫 실행 후 Dedicated Server 데이터 경로가 생성되는지
- 기본 빈 월드가 생성되는지
- 기존 월드 import 후 올바른 월드가 열리는지
- Game ID가 확인 가능한지
- Task Scheduler 자동 시작 등록/해제/활성화/비활성화가 동작하는지
- 특정 시간 재시작 예약이 등록되는지
- Steam 전용 SDR(Game ID) 접속 흐름이 문서와 일치하는지

## 검증 기록

- 날짜: 2026-06-24
- 명령: `git status -sb`
- 결과: 구현 전 기준 작업 트리 확인 완료
- 비고: 실제 서버 실행 환경은 Windows 노트북이며, macOS에서는 서버 실행 검증을 하지 않음

- 날짜: 2026-06-24
- 명령: `command -v pwsh`
- 결과: 로컬 macOS 환경에 `pwsh` 없음
- 비고: PowerShell 모듈 import와 SteamCMD 설치 검증은 Windows 노트북에서 수행 필요

- 날짜: 2026-06-24
- 명령: `find . -maxdepth 3 -type f | sort`
- 결과: T1/T2 파일 구조 생성 확인
- 비고: macOS에서는 SteamCMD 다운로드/실행 검증을 하지 않음

- 날짜: 2026-06-24
- 명령: `git diff --cached --check`
- 결과: T3 스테이징 전 공백 오류 확인 예정
- 비고: 최종 커밋 전 실행 필요

- 날짜: 2026-06-24
- 명령: PowerShell 문법 검사
- 결과: 로컬 macOS 환경에 `pwsh`가 없어 미실행
- 비고: Windows PowerShell에서 T1-T3 검증 명령 실행 필요

## 알려진 이슈

- macOS에서는 Windows PowerShell/Task Scheduler/SteamCMD 실행 검증을 하지 않는다.
- Core Keeper Dedicated Server 최신 실행 인자는 구현 전 Windows에서 재확인해야 한다.
- SteamCMD anonymous `app_update 1963720 validate` 성공 여부는 Windows 노트북에서 재확인해야 한다.
- Windows 실기 검증은 집 Windows 노트북에서 새 Codex 세션으로 진행한다.
