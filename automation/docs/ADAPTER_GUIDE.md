# Adapter 가이드

이 문서는 Steam Game Server Manager에 새 게임 Adapter를 추가하는 방법을 정의한다.

## 1. Adapter 구성 요소

Adapter는 최소 하나의 manifest로 구성한다.

```text
automation/src/Games/<GameName>/
├── game.json
└── <GameName>.Adapter.psm1
```

`game.json`은 필수다. PowerShell Adapter 모듈은 게임별 코드가 필요할 때만 추가한다.

게임별 사용자 설정은 다음 위치를 사용한다.

```text
automation/config/games/<game>.example.json
automation/config/games/<game>.local.json
```

## 2. 이름 규칙

| 항목 | 규칙 |
|---|---|
| `gameId` | 소문자, 공백 없음, 스크립트 `-Game` 값으로 사용 |
| `displayName` | 사용자에게 보여줄 게임 이름 |
| 폴더명 | 사람이 읽기 쉬운 PascalCase 권장 |
| manifest 파일명 | `game.json` 고정 |
| Adapter 모듈명 | `<GameName>.Adapter.psm1` 권장 |

`gameId`는 저장소 안에서 안정적인 식별자로 취급한다. 나중에 변경하면 설정 파일, 백업 경로, 스케줄러 작업명과 충돌할 수 있으므로 초기 정의 후 변경하지 않는다.

## 3. Manifest Schema 초안

초기 schema는 JSON Schema 파일이 아니라 문서 계약으로 관리한다. 실제 schema 검증 파일은 후속 Task에서 추가한다.

```json
{
  "gameId": "example",
  "displayName": "Example Game",
  "steam": {
    "appId": "000000",
    "login": "anonymous"
  },
  "paths": {
    "defaultInstallPath": "C:\\GameServers\\Example",
    "defaultBackupRoot": "D:\\Backups\\GameServers\\Example",
    "dataRoot": "%USERPROFILE%\\AppData\\LocalLow\\Vendor\\Example"
  },
  "server": {
    "launchCandidates": [
      "StartServer.bat",
      "ExampleServer.exe"
    ],
    "processNamePatterns": [
      "ExampleServer"
    ],
    "arguments": []
  },
  "backup": {
    "targets": [
      {
        "name": "saves",
        "path": "saves",
        "type": "directory"
      }
    ]
  },
  "logs": {
    "directories": [],
    "statusPatterns": []
  },
  "features": {
    "worldImport": false,
    "configPatch": false,
    "gracefulStop": false,
    "healthCheck": false
  }
}
```

## 4. 필수 Manifest 필드

| 필드 | 설명 |
|---|---|
| `gameId` | Adapter 식별자 |
| `displayName` | 사용자 표시 이름 |
| `steam.appId` | Steam Dedicated Server AppID |
| `steam.login` | SteamCMD 로그인 방식 |
| `paths.defaultInstallPath` | 기본 서버 설치 경로 |
| `paths.defaultBackupRoot` | 기본 백업 경로 |
| `server.launchCandidates` | 설치 폴더 기준 실행 후보 목록 |
| `server.processNamePatterns` | 상태 조회에 사용할 프로세스명 후보 |
| `backup.targets` | 백업 대상 목록 |
| `features` | 선택 기능 지원 여부 |

`paths.dataRoot`는 게임 데이터나 설정 파일이 설치 폴더 밖에 있을 때 필수로 둔다. 데이터가 설치 폴더 안에만 있으면 후속 schema에서 생략 가능하도록 조정할 수 있다.

## 5. 백업 대상 규칙

백업 대상은 Adapter 기준 데이터 루트 또는 설치 경로를 기준으로 해석한다.

```json
{
  "name": "config",
  "path": "config\\server.json",
  "type": "file"
}
```

| 필드 | 허용 값 | 설명 |
|---|---|---|
| `name` | 문자열 | 백업 로그에 표시할 이름 |
| `path` | 상대 경로 | 기준 경로 아래 대상 |
| `type` | `file`, `directory` | 대상 종류 |

초기 구현에서는 상대 경로만 허용한다. 절대 경로 백업 대상이 필요한 게임은 별도 설계 후 확장한다.

## 6. PowerShell 함수 계약

Adapter 모듈은 manifest만으로 부족한 게임별 동작을 제공한다.

### 필수 함수

후속 R2 단계에서는 manifest 기반 Adapter도 허용한다. PowerShell 모듈이 존재하는 경우 아래 함수는 필수다.

```powershell
Get-GameServerAdapter
Get-GameServerPaths
Get-GameServerLaunchCandidates
Get-GameServerBackupTargets
```

`Get-GameServerAdapter`는 Adapter 메타데이터와 지원 기능을 반환한다.

```powershell
function Get-GameServerAdapter {
    [CmdletBinding()]
    param()

    [pscustomobject]@{
        GameId = "example"
        DisplayName = "Example Game"
        SupportsWorldImport = $false
        SupportsConfigPatch = $false
    }
}
```

### 선택 함수

선택 함수는 기능 플래그가 `true`일 때 구현한다.

```powershell
Get-GameServerStatusHints
Import-GameServerWorld
Update-GameServerConfig
Test-GameServerHealth
Stop-GameServerGracefully
```

선택 함수가 없으면 Core는 기능 미지원으로 처리해야 한다. Core가 임의로 게임별 동작을 추측해서는 안 된다.

## 7. 함수 반환 원칙

PowerShell 함수는 문자열 배열보다 구조화된 객체를 우선 반환한다.

권장 반환 형식:

```powershell
[pscustomobject]@{
    Name = "saves"
    Path = "saves"
    Type = "directory"
}
```

오류는 `throw` 또는 PowerShell error record로 명확히 보고한다. 사용자에게 보여줄 메시지는 Core에서 일관된 형식으로 감싼다.

## 8. 신규 Adapter 추가 절차

1. `automation/src/Games/<GameName>/game.json`을 만든다.
2. `gameId`, Steam AppID, 로그인 방식을 채운다.
3. 기본 설치 경로와 백업 경로를 정한다.
4. 실행 후보와 프로세스명 후보를 적는다.
5. 백업 대상을 상대 경로로 정의한다.
6. 지원하지 않는 기능은 `features`에서 `false`로 둔다.
7. manifest로 부족한 기능이 있을 때만 Adapter 모듈을 추가한다.
8. `automation/config/games/<game>.example.json`에 사용자 조정 가능한 값을 분리한다.
9. macOS에서는 문서/정적 검증만 수행하고, 실제 서버 실행은 Windows에서 검증한다.

## 9. QA 체크리스트

- manifest에 게임별 상수가 모두 모여 있는가?
- 공통 Core 수정 없이 Adapter discovery가 가능한가?
- 백업 대상이 사용자 데이터 삭제나 이동을 수행하지 않는가?
- 지원하지 않는 기능이 명확히 `false`로 표시되어 있는가?
- Windows 실기 검증 전 위험한 종료/재시작 동작을 추가하지 않았는가?
- 기존 기본 게임 명령과 새 `-Game` 명령이 공존 가능한가?

## 10. Core Keeper Adapter 예시

Core Keeper Adapter manifest 예시는 다음 기준을 따른다.

```json
{
  "gameId": "corekeeper",
  "displayName": "Core Keeper",
  "steam": {
    "appId": "1963720",
    "login": "anonymous"
  },
  "paths": {
    "defaultInstallPath": "C:\\GameServers\\CoreKeeper",
    "defaultBackupRoot": "D:\\Backups\\GameServers\\CoreKeeper",
    "dataRoot": "%USERPROFILE%\\AppData\\LocalLow\\Pugstorm\\Core Keeper\\DedicatedServer"
  },
  "server": {
    "launchCandidates": [
      "Launch.bat",
      "LaunchServer.bat",
      "StartServer.bat",
      "CoreKeeperServer.exe",
      "Core Keeper Dedicated Server.exe"
    ],
    "processNamePatterns": [
      "CoreKeeper",
      "Core Keeper",
      "Dedicated"
    ],
    "arguments": []
  },
  "backup": {
    "targets": [
      { "name": "worlds", "path": "worlds", "type": "directory" },
      { "name": "worldinfos", "path": "worldinfos", "type": "directory" },
      { "name": "ServerConfig.json", "path": "ServerConfig.json", "type": "file" }
    ]
  },
  "logs": {
    "directories": [],
    "statusPatterns": [
      "Game ID",
      "GameID",
      "game id",
      "join code",
      "Join Code"
    ]
  },
  "features": {
    "worldImport": true,
    "configPatch": true,
    "gracefulStop": false,
    "healthCheck": false
  }
}
```

Core Keeper의 `.world.gzip` import, `ServerConfig.json` world index 수정, Game ID 로그 탐색은 Core가 아니라 Core Keeper Adapter 모듈에서 처리한다.

## 11. Valheim Skeleton Adapter 예시

Valheim은 두 번째 Adapter discovery 검증용 skeleton으로 추가했다.

```text
automation/src/Games/Valheim/game.json
automation/config/games/valheim.example.json
```

초기 목적은 Core 수정 없이 두 번째 manifest가 discovery되는지 확인하는 것이다. 실제 Valheim 서버 설치/실행 보장은 후속 Windows/SteamCMD 검증 범위로 남긴다.

현재 skeleton 기준:

- `gameId`: `valheim`
- `displayName`: `Valheim`
- Steam AppID 후보: `896660`
- 로그인 후보: `anonymous`
- 실행 후보: `start_headless_server.bat`, `valheim_server.exe`
- 데이터 경로 후보: `%USERPROFILE%\AppData\LocalLow\IronGate\Valheim`
- 백업 대상 후보: `worlds`, `worlds_local`

지원하지 않는 기능:

- `features.worldImport`: `false`
- `features.configPatch`: `false`
- `features.gracefulStop`: `false`
- `features.healthCheck`: `false`

AppID와 게임별 경로/포트/실행 파일 후보는 공개 정보 기반 skeleton 값이며, 현재 macOS 환경에서는 SteamCMD와 Windows 실행으로 검증하지 못했다. Windows 검증 전까지 Valheim Adapter는 “manifest discovery 검증용”으로 취급한다.
