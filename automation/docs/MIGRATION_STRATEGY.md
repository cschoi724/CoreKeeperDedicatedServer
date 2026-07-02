# 마이그레이션 전략

이 문서는 Core Keeper 전용 구조에서 Steam Game Server Manager 구조로 이동하는 호환 전략을 정의한다.

## 1. 마이그레이션 원칙

- 기존 동작 보존을 우선한다.
- 사용자 명령어를 한 번에 바꾸지 않는다.
- 기존 설정 파일을 즉시 제거하지 않는다.
- Core Keeper는 새 구조의 첫 Adapter로 유지한다.
- 각 단계는 독립적으로 검증 가능해야 한다.

## 2. 호환 계층

기존 항목:

```text
automation/src/CoreKeeper.*.psm1
automation/config/settings.example.json
automation/config/settings.local.json
automation/scripts/*.ps1
```

전환 후:

```text
automation/src/Core/*.psm1
automation/src/Games/CoreKeeper/*
automation/src/Compatibility/CoreKeeper.Legacy.psm1
automation/config/manager.example.json
automation/config/games/corekeeper.example.json
automation/scripts/*.ps1 -Game corekeeper
```

호환 정책:

- 기존 스크립트 파일명은 유지한다.
- 기존 `settings.local.json`은 fallback으로 읽는다.
- 기존 `CoreKeeper.*.psm1`는 wrapper로 유지한다.
- 새 Core 모듈 안정화 전까지 기존 함수 삭제를 금지한다.
- deprecation 메시지는 기능 안정화 후 추가한다.

## 3. 설정 마이그레이션

### 기존 설정

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

### 새 설정 분리

`manager.example.json`:

```json
{
  "defaultGame": "corekeeper",
  "steamCmdPath": "C:\\GameServers\\steamcmd",
  "serverRoot": "C:\\GameServers",
  "backupRoot": "D:\\Backups\\GameServers"
}
```

`config/games/corekeeper.example.json`:

```json
{
  "gameId": "corekeeper",
  "serverInstallPath": "C:\\GameServers\\CoreKeeper",
  "backupRoot": "D:\\Backups\\GameServers\\CoreKeeper",
  "worldIndex": 0,
  "taskName": "GameServer-CoreKeeper",
  "restartTaskName": "GameServer-CoreKeeper-Restart"
}
```

마이그레이션 규칙:

1. 새 설정 파일이 있으면 새 설정을 우선한다.
2. 새 설정이 없고 `settings.local.json`이 있으면 기존 설정을 `corekeeper` Adapter 설정으로 해석한다.
3. 둘 다 없으면 example 설정을 사용한다.
4. 기존 경로를 자동으로 이동하지 않는다.
5. 경로 이동 기능은 별도 승인된 Task로만 추가한다.

### 현재 구현된 설정 우선순위

GSM-R3 기준 설정 병합은 아래 순서를 따른다. 아래쪽 값으로 기본값을 만들고, 위쪽 값이 있을 때 덮어쓴다.

1. 게임별 local 설정: `config/games/<game>.local.json`
2. manager local 설정: `config/manager.local.json`
3. 기존 local 설정: `config/settings.local.json`
   - 단, 새 local 설정이 없을 때만 기존 Core Keeper 설정으로 해석한다.
4. 게임별 example 설정: `config/games/<game>.example.json`
5. manager example 설정: `config/manager.example.json`
6. Adapter manifest 기본값: `src/Games/<GameName>/game.json`

`settings.example.json`은 삭제하지 않는다. 기존 스크립트와 문서 호환을 위한 기준 파일로 유지하며, 새 설정 파일이 없고 사용자가 `settings.local.json`을 만든 경우 기존 설정을 계속 반영한다.

## 4. 스크립트 마이그레이션

기존:

```powershell
.\scripts\install-server.ps1
.\scripts\start-server.ps1
.\scripts\backup-server.ps1
```

새 구조:

```powershell
.\scripts\install-server.ps1 -Game corekeeper
.\scripts\start-server.ps1 -Game corekeeper
.\scripts\backup-server.ps1 -Game corekeeper
```

호환:

```powershell
.\scripts\install-server.ps1
```

위 명령은 기본 게임 `corekeeper`로 해석한다.

## 5. 데이터 마이그레이션

초기 리팩터링에서는 실제 서버 데이터 이동을 하지 않는다.

유지 대상:

- 기존 설치 폴더
- 기존 SteamCMD 폴더
- 기존 백업 폴더
- 기존 Core Keeper Dedicated Server 데이터 폴더

금지:

- 자동 폴더 이동
- 자동 백업 삭제
- 자동 설정 덮어쓰기
- 자동 월드 변환

필요하면 추후 별도 `migrate-game-path.ps1` Task로 설계한다.

## 6. 검증 전략

각 단계는 다음 순서로 검증한다.

1. macOS 정적 검증
   - 파일 구조 확인
   - 문서 링크 확인
   - PowerShell syntax 수준 확인 가능 여부 검토
2. Windows 모듈 import 검증
   - Core 모듈 import
   - Compatibility wrapper import
   - Core Keeper Adapter import
3. Windows 기능 검증
   - SteamCMD 설치
   - Core Keeper 설치/업데이트
   - 서버 시작/상태 확인
   - 백업
   - 월드 import
   - Task Scheduler 등록/해제

## 7. 롤백 전략

리팩터링 중 문제가 생기면 아래 순서로 롤백한다.

1. 새 Core 모듈 사용을 중지하고 기존 `CoreKeeper.*.psm1` wrapper가 기존 구현을 직접 사용하게 한다.
2. `-Game` 인자 추가 전 명령 흐름으로 되돌린다.
3. 새 설정 파일을 무시하고 기존 `settings.local.json`만 사용한다.
4. 코드 삭제 없이 Task 단위 커밋을 revert한다.

주의:

- 사용자 데이터 폴더는 리팩터링 대상이 아니므로 롤백 과정에서 삭제하지 않는다.
- 백업 폴더는 자동 정리하지 않는다.

## 8. 완료 기준

- 기존 명령이 기본 Core Keeper 게임으로 계속 동작한다.
- 새 명령의 `-Game corekeeper`가 동일한 결과를 낸다.
- Core Keeper 전용 상수는 `Games/CoreKeeper` 또는 호환 wrapper에만 존재한다.
- `automation/docs/TESTING.md`가 공통 Core 검증과 Core Keeper Adapter 검증을 분리한다.
- 두 번째 게임 skeleton Adapter가 Core 수정 없이 로드된다.
