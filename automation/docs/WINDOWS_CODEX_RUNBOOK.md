# Windows Codex 검증 Runbook

이 문서는 집 Windows 노트북에서 Codex 세션을 열고 Core Keeper Dedicated Server 자동화 템플릿을 실제로 설치, 실행, 검증하는 절차다.

## 목표

- GitHub 저장소를 Windows 노트북에 준비한다.
- Codex 검증 세션을 열어 문서를 기준으로 T10 실기 검증을 진행한다.
- SteamCMD 설치, Dedicated Server 설치, 서버 시작, Game ID 확인, 백업, 월드 import, Task Scheduler 작업 등록을 검증한다.
- 검증 결과를 문서에 기록하고 커밋한다.

## 전제

- 실행 장비: Windows 노트북
- PowerShell: Windows PowerShell 5.1 이상
- Git: Windows에서 `git` 명령 사용 가능
- 접속 방식: Steam 전용 SDR(Game ID)
- 서버 설치 경로: `C:\CoreKeeperServer`
- SteamCMD 설치 경로: `C:\CoreKeeperServer\steamcmd`
- 백업 경로: `D:\Backups\CoreKeeper`
- 기존 월드: 기본은 사용하지 않음, 필요 시 단일 `.world.gzip` 파일 import
- Direct Connect, 포트포워딩, Windows 방화벽 자동 설정은 현재 범위 밖
- Windows 절전모드는 자동 변경하지 않고 사용자가 직접 확인

## 1. Windows 준비

Windows PowerShell을 열고 버전을 확인한다.

```powershell
$PSVersionTable.PSVersion
```

Git을 확인한다.

```powershell
git --version
```

작업 폴더 예시:

```powershell
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

기대 결과:

- `main...origin/main` 상태
- 최신 커밋이 원격과 일치

## 3. Codex 세션 시작

Windows에서 사용하는 Codex 도구를 열고 작업 폴더를 이 저장소 루트로 지정한다.

작업 폴더 예시:

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
- DEVELOPMENT_PLAN.md의 T10 Windows 실기 검증 진행
- TESTING.md와 WINDOWS_CODEX_RUNBOOK.md의 순서대로 실행

완료 후:
- automation/docs/TESTING.md에 성공/실패 결과 기록
- automation/docs/STATUS.md 갱신
- automation/docs/CHANGELOG.md 갱신
- 실패 항목은 다음 작업으로 분리
- 작업 단위 커밋
- git status -sb 공유
```

## 4. Automation 폴더로 이동

모든 명령은 저장소의 `automation` 폴더 기준으로 실행한다.

```powershell
cd C:\Projects\CoreKeeperDedicatedServer\automation
```

## 5. 설정 확인

```powershell
Get-Content .\config\settings.example.json
```

기본값을 바꿀 필요가 있으면 로컬 설정 파일을 만든다.

```powershell
Copy-Item .\config\settings.example.json .\config\settings.local.json
notepad .\config\settings.local.json
```

기본값 그대로 진행한다면 `settings.local.json`은 만들지 않아도 된다.

## 6. PowerShell 모듈 Import

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

초기 상태에서는 일부 경로가 `False`일 수 있다.

## 7. SteamCMD 설치

```powershell
.\scripts\install-steamcmd.ps1
Test-Path C:\CoreKeeperServer\steamcmd\steamcmd.exe
```

기대 결과:

- `True`
- `C:\CoreKeeperServer\steamcmd\steamcmd.exe` 생성

실패하면 확인할 것:

- 인터넷 연결
- 보안 프로그램 또는 네트워크 차단 여부
- `C:\CoreKeeperServer` 생성 권한

## 8. Dedicated Server 설치와 업데이트

```powershell
.\scripts\install-server.ps1
Test-Path C:\CoreKeeperServer
Get-ChildItem C:\CoreKeeperServer
```

기대 결과:

- SteamCMD가 `app_update 1963720 validate`를 실행
- `C:\CoreKeeperServer` 아래에 서버 파일 생성

업데이트 검증:

```powershell
.\scripts\update-server.ps1
```

## 9. 서버 첫 실행

```powershell
.\scripts\status-server.ps1
.\scripts\start-server.ps1
```

서버 콘솔 창이 열리면 잠시 기다린다.

확인할 것:

- 서버 프로세스가 실행되는지
- 콘솔 또는 로그에 Game ID가 표시되는지
- Game ID를 친구에게 공유할 수 있는지

상태 확인은 별도 PowerShell 창에서 실행한다.

```powershell
cd C:\Projects\CoreKeeperDedicatedServer\automation
.\scripts\status-server.ps1
```

## 10. 서버 중지

현재 `stop-server.ps1`은 강제 종료하지 않는다.

```powershell
.\scripts\stop-server.ps1
```

서버 콘솔에 안전 종료 방법이 표시되거나 공식 종료 입력이 확인되면 그 방식으로 종료한다.

확인할 것:

- 안전 종료 입력이 `q`인지, 다른 명령인지
- 종료 후 `status-server.ps1`에서 프로세스가 사라지는지

## 11. 기본 빈 월드 확인

서버를 1회 실행한 뒤 아래 경로가 생겼는지 확인한다.

```powershell
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer"
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worlds"
Test-Path "$env:USERPROFILE\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\ServerConfig.json"
```

실제 생성 경로가 다르면 문서에 기록한다.

## 12. 백업 검증

```powershell
.\scripts\backup-server.ps1 -Reason manual
Get-ChildItem D:\Backups\CoreKeeper
```

기대 결과:

- `manual-YYYYMMDD-HHMMSS` 폴더 생성
- `backup-manifest.json` 생성
- 존재하는 `worlds`, `worldinfos`, `ServerConfig.json` 복사
- 없는 대상은 skip 메시지로 기록

## 13. 기존 월드 Import 검증

기존 월드 파일이 아직 준비되지 않았으면 이 단계는 skip하고 문서에 “월드 파일 미준비로 미검증”이라고 기록한다.

월드 파일 예시 위치:

```text
D:\Incoming\0.world.gzip
```

서버가 꺼진 상태에서 실행한다.

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

이미 대상 월드가 있으면 기본적으로 중단된다. 백업을 확인한 뒤 덮어쓰려면 명시적으로 실행한다.

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -ConfirmOverwrite
```

확인할 것:

- import 전에 `before-import-*` 백업 생성
- 원본 파일 삭제되지 않음
- `worlds\0.world.gzip` 생성
- `ServerConfig.json` 월드 인덱스 필드 수정 여부
- `worldinfos` 없이 정상 실행되는지

## 14. 자동 실행 작업 검증

```powershell
Test-CKAdministrator
.\scripts\register-task.ps1
Get-ScheduledTask -TaskName CoreKeeperServer
.\scripts\disable-task.ps1
.\scripts\enable-task.ps1
.\scripts\unregister-task.ps1
```

확인할 것:

- 작업 이름: `CoreKeeperServer`
- 실행 대상: 현재 저장소의 `automation\scripts\start-server.ps1`
- 현재 사용자 로그온 트리거
- 관리자 권한 없이 되는지, 관리자 권한이 필요한지

## 15. 재시작 예약 작업 검증

```powershell
Assert-CKRestartTime -Time "05:00"
.\scripts\register-restart-task.ps1 -Time "05:00"
Get-ScheduledTask -TaskName CoreKeeperServerRestart
.\scripts\unregister-restart-task.ps1
```

잘못된 시간 형식도 확인한다.

```powershell
.\scripts\register-restart-task.ps1 -Time "5:00"
.\scripts\register-restart-task.ps1 -Time "24:00"
```

확인할 것:

- `HH:mm` 형식만 허용
- 작업 이름: `CoreKeeperServerRestart`
- 현재는 강제 종료/자동 재시작이 아니라 `stop-server.ps1` 안내 작업 실행

## 16. 절전모드 수동 확인

서버를 24시간 켜 둘 계획이면 Windows 설정에서 절전모드와 최대 절전모드를 직접 확인한다.

권장:

- 전원 연결 시 절전모드 끄기
- 덮개 닫기 동작 확인
- Windows 업데이트 후 자동 재부팅 정책 확인

자동화 스크립트는 전원 설정을 변경하지 않는다.

## 17. 검증 결과 기록

검증 결과는 아래 문서에 남긴다.

- `automation/docs/TESTING.md`
- `automation/docs/STATUS.md`
- `automation/docs/CHANGELOG.md`

기록 형식 예시:

```text
- 날짜:
- 환경:
- 명령:
- 결과:
- 비고:
```

성공/실패를 모두 기록한다. 실패한 항목은 다음 작업으로 분리한다.

## 18. 커밋과 Push

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
2. SteamCMD 다운로드 실패
3. `app_update 1963720 validate` 실패
4. 서버 실행 파일 탐색 실패
5. Game ID 확인 실패
6. Dedicated Server 데이터 경로 불일치
7. 백업 실패
8. 월드 import 실패
9. Task Scheduler 등록 실패

실패한 단계에서 멈추고, 출력 전체와 함께 `automation/docs/TESTING.md`에 기록한다.

