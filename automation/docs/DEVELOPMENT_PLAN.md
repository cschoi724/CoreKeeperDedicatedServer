# 개발 계획

이 문서는 Core Keeper Dedicated Server Windows 자동화 템플릿의 실제 진행 기준이다. 다음 개발 세션은 이 문서를 기준으로 작업 단위를 하나씩 완료한다.

## 현재 상태 요약

- 현재 이정표: M1 설계 확정 직전
- 완료된 범위:
  - 루트 운영 문서 생성
  - GitHub 원격 저장소 push
  - Steam 전용 SDR(Game ID) 운영 방향 확정
  - Windows 운영 기본값 확정
  - 기본 빈 월드와 단일 `.world.gzip` import 방향 확정
- 다음 범위:
  - 자동화 템플릿 파일 구조 생성
  - PowerShell 공통 유틸리티와 설정 파일 작성
  - SteamCMD 설치/서버 설치/서버 시작 스크립트 구현

## 확정 기본값

- 서버 설치 경로: `C:\CoreKeeperServer`
- 백업 경로: `D:\Backups\CoreKeeper`
- SteamCMD 설치 경로 후보: `C:\CoreKeeperServer\steamcmd`
- SteamCMD 설치 방식: 템플릿에서 자동 다운로드/설치
- Core Keeper Dedicated Server App ID: `1963720`
- 접속 방식: Steam 전용 SDR(Game ID)
- Direct Connect: 현재 구현 제외
- 서버 실행: 기본 수동 실행
- 자동 실행: 선택 기능
- 특정 시간 재시작: 선택 기능
- 서버 실행 계정: 현재 Windows 로그인 사용자
- 절전모드 설정: 자동 변경하지 않고 문서로 안내
- 기본 월드: 새 빈 월드
- 기존 월드: 사용자가 가져온 단일 `.world.gzip` 파일 import

## 목표 파일 구조

```text
automation/
├── README.md
├── config/
│   └── settings.example.json
├── scripts/
│   ├── backup-server.ps1
│   ├── disable-task.ps1
│   ├── enable-task.ps1
│   ├── import-world.ps1
│   ├── install-server.ps1
│   ├── install-steamcmd.ps1
│   ├── register-restart-task.ps1
│   ├── register-task.ps1
│   ├── start-server.ps1
│   ├── status-server.ps1
│   ├── stop-server.ps1
│   ├── unregister-restart-task.ps1
│   ├── unregister-task.ps1
│   └── update-server.ps1
├── src/
│   ├── CoreKeeper.Common.psm1
│   ├── CoreKeeper.Config.psm1
│   ├── CoreKeeper.Paths.psm1
│   ├── CoreKeeper.SteamCmd.psm1
│   └── CoreKeeper.Tasks.psm1
└── docs/
    ├── OPERATIONS_DESIGN.md
    ├── TESTING.md
    └── WORLD_MIGRATION_DESIGN.md
```

## 설정 파일 초안

`automation/config/settings.example.json`은 다음 필드를 기본으로 둔다.

```json
{
  "serverInstallPath": "C:\\CoreKeeperServer",
  "steamCmdPath": "C:\\CoreKeeperServer\\steamcmd",
  "backupRoot": "D:\\Backups\\CoreKeeper",
  "appId": "1963720",
  "taskName": "CoreKeeperServer",
  "restartTaskName": "CoreKeeperServerRestart",
  "worldIndex": 0,
  "restartTime": null
}
```

실제 사용자 설정 파일은 `settings.local.json` 후보로 두고 `.gitignore` 대상에 둔다.

## 작업 단위

### T0. 문서 기준 확정

상태: 완료

목표:

- 운영 기본값과 구현 범위를 문서에 고정한다.

완료 조건:

- `docs/PROJECT_DECISIONS.md`에 결정사항이 반영되어 있다.
- `automation/docs/OPERATIONS_DESIGN.md`와 `automation/docs/WORLD_MIGRATION_DESIGN.md`가 존재한다.
- 원격 저장소 `origin/main`에 push되어 있다.

검증:

```bash
git status -sb
git log --oneline --decorate -4
```

### T1. 자동화 골격 생성

상태: 완료

목표:

- 구현 파일 구조와 사용자 README를 만든다.
- 아직 SteamCMD 다운로드나 서버 실행은 하지 않는다.

생성/수정 파일:

- `automation/README.md`
- `automation/config/settings.example.json`
- `automation/src/CoreKeeper.Common.psm1`
- `automation/src/CoreKeeper.Config.psm1`
- `automation/src/CoreKeeper.Paths.psm1`
- `automation/docs/TESTING.md`

핵심 내용:

- PowerShell 5.1 이상을 우선 지원한다.
- 모든 스크립트는 repo 루트가 아니라 `automation/` 기준으로 동작하게 설계한다.
- 경로 기본값은 설정 파일에서 읽는다.
- `settings.local.json`이 있으면 example 기본값 위에 덮어쓴다.

완료 조건:

- 파일 구조가 생성되어 있다.
- 설정 파일 로딩 함수가 있다.
- 경로 생성/검증 함수가 있다.
- `README.md`에 Windows 노트북에서 시작하는 순서가 적혀 있다.

검증:

```powershell
Import-Module .\src\CoreKeeper.Config.psm1 -Force
Import-Module .\src\CoreKeeper.Paths.psm1 -Force
```

권장 커밋:

```text
chore: 자동화 템플릿 골격 추가
```

### T2. SteamCMD 자동 설치

상태: 완료, Windows 실기 검증 필요

목표:

- SteamCMD가 없으면 자동 다운로드/압축 해제한다.
- 이미 있으면 재사용한다.

생성/수정 파일:

- `automation/scripts/install-steamcmd.ps1`
- `automation/src/CoreKeeper.SteamCmd.psm1`
- `automation/docs/TESTING.md`

핵심 내용:

- 기본 설치 경로: `C:\CoreKeeperServer\steamcmd`
- SteamCMD zip 다운로드 URL은 구현 시 공식 Valve 문서 기준으로 재확인한다.
- 다운로드 실패, 압축 해제 실패, `steamcmd.exe` 미존재를 명확히 에러 처리한다.
- 네트워크가 필요한 작업임을 README에 명시한다.

완료 조건:

- `steamcmd.exe` 경로를 찾거나 설치할 수 있다.
- 동일 명령을 반복 실행해도 기존 설치를 망가뜨리지 않는다.

검증:

```powershell
.\scripts\install-steamcmd.ps1
Test-Path C:\CoreKeeperServer\steamcmd\steamcmd.exe
```

권장 커밋:

```text
feat: SteamCMD 자동 설치 스크립트 추가
```

### T3. Dedicated Server 설치/업데이트

상태: 완료, Windows 실기 검증 필요

목표:

- SteamCMD로 Core Keeper Dedicated Server App `1963720`을 설치하고 업데이트한다.

생성/수정 파일:

- `automation/scripts/install-server.ps1`
- `automation/scripts/update-server.ps1`
- `automation/src/CoreKeeper.SteamCmd.psm1`
- `automation/docs/TESTING.md`

핵심 내용:

- 설치 경로: `C:\CoreKeeperServer`
- SteamCMD 명령 후보:

```text
+force_install_dir C:\CoreKeeperServer +login anonymous +app_update 1963720 validate +quit
```

- 설치와 업데이트는 같은 SteamCMD 동작을 공유하되 사용자 명령은 분리한다.
- 서버 실행 파일명/배치 파일명은 Windows 실기 검증에서 확인하고 문서화한다.

완료 조건:

- 서버 파일이 `C:\CoreKeeperServer`에 설치된다.
- 반복 실행 시 업데이트/검증이 가능하다.
- 실패 시 SteamCMD exit code와 로그 위치를 출력한다.

검증:

```powershell
.\scripts\install-server.ps1
.\scripts\update-server.ps1
```

권장 커밋:

```text
feat: 전용 서버 설치와 업데이트 스크립트 추가
```

### T4. 수동 서버 시작과 상태 확인

상태: 완료, Windows 실기 검증 필요

목표:

- 기본 수동 실행 흐름을 구현한다.
- Game ID 확인 방법을 안내하거나 자동 표시한다.

생성/수정 파일:

- `automation/scripts/start-server.ps1`
- `automation/scripts/status-server.ps1`
- `automation/scripts/stop-server.ps1`
- `automation/docs/TESTING.md`

핵심 내용:

- 기본 실행은 사용자가 명령을 직접 실행하는 방식이다.
- 서버 실행 파일/배치 파일 후보를 자동 탐색한다.
- 안전한 종료 방식은 Windows 검증 전까지 보수적으로 처리한다.
- `stop-server.ps1`은 안전 종료 방식이 확인되기 전에는 안내 중심으로 구현한다.

완료 조건:

- 설치된 서버를 수동으로 시작할 수 있다.
- Dedicated Server 데이터 폴더 생성 여부를 확인할 수 있다.
- Game ID 확인 위치를 문서에 기록한다.

검증:

```powershell
.\scripts\start-server.ps1
.\scripts\status-server.ps1
```

권장 커밋:

```text
feat: 서버 수동 시작과 상태 확인 스크립트 추가
```

### T5. 백업

상태: 완료, Windows 실기 검증 필요

목표:

- Dedicated Server 데이터를 백업한다.

생성/수정 파일:

- `automation/scripts/backup-server.ps1`
- `automation/docs/TESTING.md`

핵심 내용:

- 백업 경로: `D:\Backups\CoreKeeper`
- 백업 대상:
  - `worlds/`
  - `worldinfos/`
  - `ServerConfig.json`
- 백업 폴더명:

```text
manual-YYYYMMDD-HHMMSS
before-import-YYYYMMDD-HHMMSS
before-update-YYYYMMDD-HHMMSS
```

- 백업 대상이 없어도 명확한 메시지를 출력한다.

완료 조건:

- 백업 폴더가 생성된다.
- 백업 대상 파일/폴더가 있으면 복사된다.
- 실패 시 후속 destructive 작업을 중단할 수 있는 exit code를 반환한다.

검증:

```powershell
.\scripts\backup-server.ps1 -Reason manual
```

권장 커밋:

```text
feat: 서버 데이터 백업 스크립트 추가
```

### T6. 기존 월드 import

상태: 완료, Windows 실기 검증 필요

목표:

- 사용자가 가져온 단일 `.world.gzip` 파일을 Dedicated Server 월드로 import한다.

생성/수정 파일:

- `automation/scripts/import-world.ps1`
- `automation/docs/TESTING.md`

핵심 내용:

- 입력은 단일 `.world.gzip` 파일로 제한한다.
- import 전 `before-import-*` 백업을 강제한다.
- 기본 대상 월드 인덱스는 `0`이다.
- 기존 대상 파일이 있으면 명시 확인을 요구한다.
- 원본 월드 파일은 삭제하지 않는다.
- `ServerConfig.json` 수정은 JSON 파서로 처리한다.

완료 조건:

- 입력 파일 검증이 동작한다.
- 백업 성공 후에만 복사가 진행된다.
- `worlds\0.world.gzip`로 복사된다.
- `ServerConfig.json`의 월드 인덱스를 맞추는 로직이 구현되어 있다.

검증:

```powershell
.\scripts\import-world.ps1 -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0
```

권장 커밋:

```text
feat: 기존 월드 import 스크립트 추가
```

### T7. 자동 실행 온/오프

상태: 완료, Windows 실기 검증 필요

목표:

- Windows Task Scheduler로 서버 자동 실행을 등록하고 관리한다.

생성/수정 파일:

- `automation/scripts/register-task.ps1`
- `automation/scripts/unregister-task.ps1`
- `automation/scripts/enable-task.ps1`
- `automation/scripts/disable-task.ps1`
- `automation/src/CoreKeeper.Tasks.psm1`
- `automation/docs/TESTING.md`

핵심 내용:

- 작업 이름: `CoreKeeperServer`
- 실행 대상: `start-server.ps1`
- 자동 실행은 기본값이 아니라 사용자가 선택해 등록한다.
- 관리자 권한 필요 여부를 사전에 확인하고 안내한다.

완료 조건:

- 작업 등록/해제/활성화/비활성화가 가능하다.
- 등록된 작업의 실행 대상이 현재 repo 경로의 `start-server.ps1`를 가리킨다.

검증:

```powershell
.\scripts\register-task.ps1
.\scripts\disable-task.ps1
.\scripts\enable-task.ps1
.\scripts\unregister-task.ps1
```

권장 커밋:

```text
feat: 서버 자동 실행 작업 관리 추가
```

### T8. 특정 시간 재시작 예약

상태: 완료, Windows 실기 검증 필요

목표:

- 사용자가 입력한 시간에 서버 재시작 작업을 예약한다.

생성/수정 파일:

- `automation/scripts/register-restart-task.ps1`
- `automation/scripts/unregister-restart-task.ps1`
- `automation/docs/TESTING.md`

핵심 내용:

- 작업 이름: `CoreKeeperServerRestart`
- 시간 입력 형식: `HH:mm`
- 기본 추천 시간은 두지 않고 사용자 입력을 요구한다.
- 안전 종료 방식이 검증되기 전에는 강제 종료를 기본값으로 넣지 않는다.
- 검증 전 구현은 “예약 작업 등록 + 재시작 실행 스크립트 후보”까지로 제한할 수 있다.

완료 조건:

- 재시작 예약 작업 등록/해제가 가능하다.
- 잘못된 시간 형식을 거부한다.
- 안전 종료 미검증 상태가 README와 테스트 문서에 기록되어 있다.

검증:

```powershell
.\scripts\register-restart-task.ps1 -Time "05:00"
.\scripts\unregister-restart-task.ps1
```

권장 커밋:

```text
feat: 서버 재시작 예약 작업 추가
```

### T9. 사용자 문서 완성

상태: 완료, Windows 실기 검증 전 문서 정리 완료

목표:

- Windows 노트북 사용자가 문서만 보고 설치/실행/import/자동 실행을 진행할 수 있게 한다.

생성/수정 파일:

- `automation/README.md`
- `README.md`
- `automation/docs/TESTING.md`
- `automation/docs/STATUS.md`

핵심 내용:

- 처음 설치 순서
- 기본 빈 월드 시작 순서
- 기존 월드 import 순서
- 백업/복구 순서
- 자동 실행 켜기/끄기
- 특정 시간 재시작 예약
- 절전모드 수동 확인 안내

완료 조건:

- README가 구현된 스크립트 이름과 일치한다.
- Windows 검증 전 항목과 검증 완료 항목이 분리되어 있다.

검증:

```bash
rg -n "migrate[-]world|월드[ ]이전|TO""DO" README.md automation docs
```

권장 커밋:

```text
docs: Windows 사용 절차 문서화
```

### T10. Windows 실기 검증

목표:

- 집 Windows 노트북의 새 Codex 세션에서 실제 설치와 실행을 검증한다.
- T1-T9 구현의 성공/실패만 확인하지 않고, T10 이후 운영 확장 설계에 필요한 로그와 실제 파일 구조를 수집한다.

검증 순서:

1. 저장소 clone
2. `automation/README.md` 확인
3. SteamCMD 자동 설치
4. Dedicated Server 설치
5. 서버 수동 시작
6. Game ID 확인
7. 기본 빈 월드 생성 확인
8. 백업 실행
9. 단일 `.world.gzip` import 테스트
10. 자동 실행 작업 등록/해제 테스트
11. 특정 시간 재시작 예약 등록/해제 테스트

검증 기록 위치:

- `automation/docs/TESTING.md`
- `automation/docs/STATUS.md`
- `automation/docs/WINDOWS_CODEX_RUNBOOK.md`의 기록 형식

완료 조건:

- 성공/실패 명령과 결과가 문서에 기록되어 있다.
- 실패한 항목은 다음 작업으로 분리되어 있다.
- 서버 실행 파일명, Game ID 출력 위치, Dedicated Server 데이터 경로, `ServerConfig.json` 실제 구조가 확인되어 있다.
- 안전 종료 방식, sleep/idle 진입/복귀 로그, 접속/퇴장 로그, 실행 중 백업 안전성은 확인 결과 또는 미확인 사유가 기록되어 있다.

권장 커밋:

```text
test: Windows 실기 검증 결과 기록
```

## 구현 원칙

- 사용자 월드 원본 파일은 삭제하지 않는다.
- Dedicated Server 데이터 덮어쓰기 전에는 백업을 강제한다.
- Direct Connect, 방화벽, 포트포워딩은 현재 범위에서 제외한다.
- Windows 전원 설정은 자동 변경하지 않는다.
- 경로와 설정은 하드코딩 대신 설정 파일과 공통 모듈에서 관리한다.
- 스크립트는 반복 실행해도 기존 설치를 최대한 망가뜨리지 않게 작성한다.
- Windows에서 검증하지 못한 항목은 문서에 미검증으로 남긴다.

## 현재 열린 질문

- Core Keeper Dedicated Server의 최신 Windows 실행 파일명 또는 배치 파일명은 무엇인가?
- 서버 콘솔의 안전 종료 방식은 무엇인가?
- `ServerConfig.json`에서 월드 인덱스 필드명은 무엇인가?
- 단일 `.world.gzip`만 import해도 `worldinfos` 없이 정상 실행되는가?

## T10 이후 운영 확장 후보

운영 확장 요구사항과 Dedicated Server sleep/대기 동작 기준은 `../../docs/product/DEDICATED_SERVER_OPERATION_KNOWLEDGE.md`를 따른다.

T11-T15는 추가 요구사항에 해당한다. T10 Windows 실기 검증에서 로그와 파일 구조를 수집한 뒤 설계/구현 여부를 결정한다.

- T11 Dedicated Server 운영 특성 검증
- T12 상태 조회와 서버 시작 정보 출력 개선
- T13 자동 백업 정책
- T14 Watchdog 자동 재시작
- T15 Discord Webhook 알림

## 다음 작업

1. T10 Windows 실기 검증
2. T10 로그/증거 수집 결과를 문서에 반영
3. Windows 실기 검증 결과에 따라 안전 종료/실제 재시작 확장 여부 결정
4. T11-T15 운영 확장 후보 중 구현할 항목을 확정

## 최근 작업 로그

- 2026-06-24: 루트 관리 세션에서 개발 계획 초안을 작성함.
- 2026-06-24: Git 저장소 초기화와 원격 저장소 정보를 반영함.
- 2026-06-24: Steam 전용 접속 결정과 기본 빈 월드/기존 월드 import 설계를 반영함.
- 2026-06-24: 사용자의 운영 기본값 결정을 반영해 설치/백업/실행/재시작/import 계획을 구체화함.
- 2026-06-24: T10을 Windows 실기 검증과 2차 운영 확장용 로그/증거 수집 단계로 명확히 분리함.
- 2026-06-24: 개발계획을 작업 단위별 실행 계획으로 구체화함.
- 2026-06-24: T1-T8 구현 완료 후 다음 작업을 T9/T10으로 갱신함.
