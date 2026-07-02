# Windows Codex 검증 Runbook

이 문서는 Windows 노트북에서 Codex 세션을 열고 Steam Game Server Manager 자동화 템플릿을 실제로 검증하는 절차다. 현재 실제 회귀 대상 Adapter는 `corekeeper`다.

## 목표

- 저장소를 Windows 노트북에 준비한다.
- 공통 Core 검증과 Core Keeper Adapter 회귀 검증을 분리해 실행한다.
- SteamCMD 설치, Dedicated Server 설치, 서버 시작, SDR Game ID 확인, 백업, 월드 import, Task Scheduler 등록을 검증한다.
- T10 증거 수집 항목을 문서에 기록한다.

## 전제

- 실행 장비: Windows 노트북
- PowerShell: Windows PowerShell 5.1 이상
- Git: Windows에서 `git` 명령 사용 가능
- 기본 게임: `corekeeper`
- 접속 방식: Steam SDR Game ID
- 기존 월드: 기본은 사용하지 않음, 필요 시 단일 `.world.gzip` 파일 import
- Direct Connect, 포트포워딩, Windows 방화벽 자동 설정은 현재 범위 밖
- Windows 절전모드는 자동 변경하지 않고 사용자가 직접 확인

## 1. Windows 준비

```powershell
$PSVersionTable.PSVersion
git --version
mkdir C:\Projects
cd C:\Projects
```

## 2. 저장소 Clone

```powershell
git clone https://github.com/cschoi724/CoreKeeperDedicatedServer.git
cd .\CoreKeeperDedicatedServer
git status -sb
git log --oneline -5
```

## 3. Codex 세션 시작 지시

Windows에서 Codex 도구를 열고 작업 폴더를 이 저장소 루트로 지정한다.

```text
C:\Projects\CoreKeeperDedicatedServer
```

Codex 세션에 전달할 첫 지시:

```text
문서를 기준으로 진행해줘.

먼저 읽을 문서:
- agents.md
- automation/agents.md
- automation/README.md
- automation/docs/DEVELOPMENT_PLAN.md
- automation/docs/STATUS.md
- automation/docs/TESTING.md
- automation/docs/WINDOWS_CODEX_RUNBOOK.md

이번 목표:
- Steam Game Server Manager Windows 실기 검증
- 공통 Core 검증과 Core Keeper Adapter 회귀 검증을 분리해 실행
- TESTING.md와 WINDOWS_CODEX_RUNBOOK.md 순서대로 실행

완료 후:
- automation/docs/TESTING.md에 성공/실패 결과 기록
- automation/docs/STATUS.md 갱신
- automation/docs/CHANGELOG.md 갱신
- 실패 항목은 다음 작업으로 분리
- 작업 단위 커밋
- git status -sb 공유
```

## 4. Automation 폴더로 이동

```powershell
cd C:\Projects\CoreKeeperDedicatedServer\automation
```

## 5. 설정 확인

```powershell
Get-Content .\config\manager.example.json
Get-Content .\config\games\corekeeper.example.json
Get-Content .\src\Games\CoreKeeper\game.json
```

필요하면 로컬 설정 파일을 만든다.

```powershell
Copy-Item .\config\manager.example.json .\config\manager.local.json
Copy-Item .\config\games\corekeeper.example.json .\config\games\corekeeper.local.json
notepad .\config\manager.local.json
notepad .\config\games\corekeeper.local.json
```

기존 Core Keeper 전용 설정 호환 검증이 필요할 때만 `config\settings.local.json`을 만든다.

## 6. 공통 Core 모듈 Import

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
```

확인할 것:

- `corekeeper` Adapter discovery 성공
- AppID `1963720`과 login `anonymous`가 Adapter 설정에서 나온다
- 경로가 로컬 설정, game 설정, manifest, compatibility fallback 순서를 반영한다

## 7. Core Keeper 호환 wrapper Import

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
Get-CKServerStatus
```

초기 상태에서는 일부 경로가 `False`일 수 있다.

## 8. SteamCMD 설치

먼저 WhatIf:

```powershell
.\scripts\install-steamcmd.ps1 -Game corekeeper -WhatIf
```

실제 설치:

```powershell
.\scripts\install-steamcmd.ps1 -Game corekeeper
```

확인할 것:

- SteamCMD 설치 경로
- `steamcmd.exe` 존재 여부
- 다운로드 실패 시 네트워크 또는 보안 프로그램 차단 여부

## 9. Dedicated Server 설치와 업데이트

```powershell
.\scripts\install-server.ps1 -Game corekeeper -WhatIf
.\scripts\install-server.ps1 -Game corekeeper
.\scripts\update-server.ps1 -Game corekeeper -WhatIf
.\scripts\update-server.ps1 -Game corekeeper
```

확인할 것:

- SteamCMD가 `app_update 1963720 validate`를 실행한다
- 설치 폴더에 서버 파일이 생성된다
- 실행 파일 또는 배치 파일 후보가 실제 파일명과 맞는다

## 10. 서버 첫 실행

```powershell
.\scripts\status-server.ps1 -Game corekeeper
.\scripts\start-server.ps1 -Game corekeeper
```

서버 콘솔 창이 열리면 잠시 기다린다.

별도 PowerShell 창에서:

```powershell
cd C:\Projects\CoreKeeperDedicatedServer\automation
.\scripts\status-server.ps1 -Game corekeeper
```

확인할 것:

- 서버 프로세스 실행 여부
- 콘솔 또는 로그의 SDR Game ID 출력 위치
- 플레이어 접속 가능 여부

## 11. 서버 중지

현재 `stop-server.ps1`은 강제 종료하지 않는다.

```powershell
.\scripts\stop-server.ps1 -Game corekeeper
```

확인할 것:

- 안전 종료 입력이 무엇인지
- 저장 완료 시점이 어떻게 표시되는지
- 종료 후 `status-server.ps1 -Game corekeeper`에서 프로세스가 사라지는지

## 12. 기본 빈 월드와 데이터 경로 확인

서버를 1회 실행한 뒤 Dedicated Server 데이터 경로가 생겼는지 확인한다.

```powershell
Get-GameServerPathSet -Game corekeeper
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer"
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worlds"
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\ServerConfig.json"
```

실제 생성 경로가 다르면 기록한다.

## 13. 백업 검증

```powershell
Get-GameServerBackupTargets -Game corekeeper
.\scripts\backup-server.ps1 -Game corekeeper -Reason manual -WhatIf
.\scripts\backup-server.ps1 -Game corekeeper -Reason manual
```

확인할 것:

- 백업 루트와 백업 폴더명
- `backup-manifest.json`
- 존재하는 `worlds`, `worldinfos`, `ServerConfig.json` 복사
- 없는 대상 skip 메시지

## 14. 기존 월드 Import 검증

기존 월드 파일이 아직 준비되지 않았으면 이 단계는 skip하고 “월드 파일 미준비로 미검증”이라고 기록한다.

월드 파일 예시:

```text
D:\Incoming\0.world.gzip
```

서버가 꺼진 상태에서 실행한다.

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -WhatIf
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

이미 대상 월드가 있으면 기본적으로 중단된다. 백업을 확인한 뒤 덮어쓰려면 명시적으로 실행한다.

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

확인할 것:

- Adapter `features.worldImport` 지원 확인
- import 전 `before-import-*` 백업 생성
- 원본 파일 삭제 또는 이동 없음
- `worlds\0.world.gzip` 생성
- `ServerConfig.json` 월드 인덱스 필드 수정 여부
- `worldinfos` 없이 정상 실행되는지

## 15. 자동 실행 작업 검증

```powershell
.\scripts\register-task.ps1 -Game corekeeper -WhatIf
.\scripts\register-task.ps1 -Game corekeeper
Get-ScheduledTask -TaskName CoreKeeperServer
.\scripts\disable-task.ps1 -Game corekeeper
.\scripts\enable-task.ps1 -Game corekeeper
.\scripts\unregister-task.ps1 -Game corekeeper
```

확인할 것:

- 작업 이름
- 실행 대상
- 현재 사용자 로그온 트리거
- 관리자 권한 필요 여부

## 16. 재시작 예약 작업 검증

```powershell
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "05:00" -WhatIf
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "05:00"
Get-ScheduledTask -TaskName CoreKeeperServerRestart
.\scripts\unregister-restart-task.ps1 -Game corekeeper
```

잘못된 시간 형식도 확인한다.

```powershell
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "5:00"
.\scripts\register-restart-task.ps1 -Game corekeeper -Time "24:00"
```

확인할 것:

- `HH:mm` 형식만 허용
- 현재는 강제 종료/자동 재시작이 아니라 `stop-server.ps1` 안내 작업 실행

## 17. 절전모드 수동 확인

서버를 24시간 켜 둘 계획이면 Windows 설정에서 절전모드와 최대 절전모드를 직접 확인한다.

- 전원 연결 시 절전모드 끄기
- 덮개 닫기 동작 확인
- Windows 업데이트 후 자동 재부팅 정책 확인

자동화 스크립트는 전원 설정을 변경하지 않는다.

## 18. T10 증거 수집

T10은 기존 이름을 유지하는 Windows 실기 검증/증거 수집 단계다. 새 구조에서는 공통 Core와 Core Keeper Adapter 회귀 검증 결과를 분리해 기록한다.

수집 항목:

- PowerShell 버전과 실행 정책
- Adapter discovery 출력
- 설정 병합 결과와 실제 경로
- SteamCMD 설치 경로와 `app_update` 출력
- Dedicated Server 실행 파일명 또는 배치 파일명
- 서버 시작 콘솔 출력과 Game ID 출력 위치
- Dedicated Server 데이터 경로와 `ServerConfig.json` 실제 구조
- 서버 로그 파일 위치와 접속/퇴장 로그
- 플레이어 0명 sleep/idle 진입 및 재접속 복귀 로그
- 안전 종료 명령, 저장 완료 시점, 실행 중 백업 안전성
- Task Scheduler 자동 실행과 예약 작업의 실제 동작 결과

자동 백업 정책, Watchdog, Discord Webhook, 상태 조회 확장은 위 증거를 수집한 뒤 다음 개발 범위로 분리한다.

## 19. 검증 결과 기록

검증 결과는 아래 문서에 남긴다.

- `automation/docs/TESTING.md`
- `automation/docs/STATUS.md`
- `automation/docs/CHANGELOG.md`

기록 형식:

```text
- 날짜:
- 환경:
- 구분: 공통 Core / Core Keeper Adapter / Windows 운영
- 명령:
- 결과:
- 비고:
```

성공과 실패를 모두 기록한다. 실패한 항목은 다음 작업으로 분리한다.

## 20. 커밋과 Push

검증 문서를 수정한 뒤 상태를 확인한다.

```powershell
git status -sb
git diff -- automation/docs/TESTING.md automation/docs/STATUS.md automation/docs/CHANGELOG.md
```

커밋:

```powershell
git add automation/docs/TESTING.md automation/docs/STATUS.md automation/docs/CHANGELOG.md
git commit -m "test: Windows 실기 검증 결과 기록"
git push
```

최종 확인:

```powershell
git status -sb
```

## 실패 시 우선순위

1. PowerShell 모듈 import 실패
2. Adapter discovery 실패
3. 설정 병합 또는 경로 계산 실패
4. SteamCMD 다운로드 실패
5. `app_update 1963720 validate` 실패
6. 서버 실행 파일 탐색 실패
7. Game ID 확인 실패
8. Dedicated Server 데이터 경로 불일치
9. 백업 실패
10. 월드 import 실패
11. Task Scheduler 등록 실패

실패한 단계에서 멈추고 출력 전체와 함께 `automation/docs/TESTING.md`에 기록한다.
