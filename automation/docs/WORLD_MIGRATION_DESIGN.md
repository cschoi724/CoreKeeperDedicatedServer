# 기존 월드 import 설계

이 문서는 기존 Core Keeper 월드를 Windows Dedicated Server로 가져오는 작업을 구현하기 위한 설계다. 현재는 설계 문서이며 실제 스크립트 구현은 아직 하지 않았다.

## 현재 전제

- Windows 노트북에서는 Core Keeper를 실행한 적이 없다.
- Windows 노트북에는 기존 클라이언트 월드가 없다.
- 서버 기본값은 새 빈 월드다.
- 기존 월드는 하나로 예상한다.
- 기존 월드를 쓰려면 사용자가 단일 `.world.gzip` 파일로 Windows 노트북에 가져온 뒤 import한다.
- 접속 방식은 Steam 전용 SDR(Game ID)이다.
- macOS에서는 실제 월드 파일 이전을 하지 않는다.

## 목표

기본 서버는 새 빈 월드로 시작하게 하고, 기존 월드가 필요할 때만 사용자가 가져온 월드 파일을 안전하게 Dedicated Server 저장 경로로 복사한다.

## 추천 사용자 흐름

### 기본 흐름: 새 빈 월드

1. 서버를 설치한다.
2. 서버를 1회 실행한다.
3. Dedicated Server가 새 월드와 설정 파일을 생성한다.
4. Game ID를 확인해 친구들에게 공유한다.

이 흐름은 기존 월드 파일이 없어도 동작해야 한다.

### 선택 흐름: 기존 월드 import

1. 기존 Core Keeper 월드 파일을 Windows 노트북으로 가져온다.
2. 서버를 중지한다.
3. import 스크립트를 실행한다.
4. 스크립트가 현재 Dedicated Server 데이터를 백업한다.
5. 사용자가 가져온 월드 파일을 Dedicated Server 월드 경로로 복사한다.
6. 필요한 경우 `ServerConfig.json`의 월드 인덱스를 맞춘다.
7. 서버를 다시 실행해 올바른 월드가 열리는지 확인한다.

## 입력 형식

초기 구현 추천 입력:

```text
<가져온 월드 파일>.world.gzip
```

추후 후보:

```text
worlds\*.world.gzip
worldinfos\*
CoreKeeperSaves.zip
```

초기 구현은 단일 `.world.gzip` 파일 import로 확정한다. 폴더/zip import는 Windows 실기 검증 후 추후 확장 후보로 둔다.

## Windows 기준 Dedicated Server 후보 경로

```text
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worlds\<index>.world.gzip
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worldinfos\<index>.worldinfo
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\ServerConfig.json
```

정확한 파일 확장자와 `ServerConfig.json` 구조는 Windows 실기 검증 때 재확인한다.

## import 절차 설계

### 1. Dedicated Server 저장 루트 확인

스크립트는 Dedicated Server 저장 루트가 존재하는지 확인한다.

저장 루트가 없으면 import를 중단하고, 먼저 서버를 1회 실행해 설정 파일과 폴더를 생성하도록 안내한다.

### 2. 입력 파일 확인

스크립트는 사용자가 지정한 입력 경로를 확인한다.

확인 항목:

- 파일이 존재하는지
- 확장자가 `.world.gzip`인지
- 파일 크기가 0보다 큰지

초기 구현에서는 Steam 계정 폴더 자동 탐색을 기본 흐름에 넣지 않는다.

### 3. 서버 중지 확인

월드 복사 전 Dedicated Server가 실행 중이면 중지해야 한다.

초기 구현에서는 프로세스를 강제로 종료하지 않고, 사용자에게 서버 콘솔에서 정상 종료하도록 안내한다.

이유:

- 월드 저장 중 강제 종료하면 데이터 손상 위험이 있다.
- Core Keeper 서버 정상 종료 방식은 Windows 실기 검증 때 확인해야 한다.

### 4. 서버 데이터 백업

월드 import 전에는 Dedicated Server 데이터 폴더를 반드시 백업한다.

백업 대상:

- `worlds/`
- `worldinfos/`
- `ServerConfig.json`

백업 경로:

```text
D:\Backups\CoreKeeper\before-import-YYYYMMDD-HHMMSS\
```

백업 실패 시 import를 중단한다.

### 5. 대상 월드 인덱스 선택

초기 추천 인덱스는 `0`이다.

정책:

- 기본 대상: `0.world.gzip`
- 기존 `0.world.gzip`이 있으면 백업 후 덮어쓰기 확인을 요구한다.
- 사용자가 다른 인덱스를 지정할 수 있게 한다.

### 6. 월드 파일 복사

입력 `.world.gzip` 파일을 Dedicated Server의 `worlds\<index>.world.gzip`로 복사한다.

원본 파일은 절대 삭제하지 않는다.

### 7. ServerConfig.json 수정

`ServerConfig.json`에 월드 인덱스를 지정하는 필드가 있으면, 복사한 월드 인덱스와 맞춘다.

주의:

- 필드명이 현재 버전에서 무엇인지 Windows 실기 검증이 필요하다.
- JSON 수정은 문자열 치환이 아니라 PowerShell의 JSON 파서를 사용한다.
- 알 수 없는 필드는 유지한다.

### 8. 검증

복사 후 다음을 확인한다.

- Dedicated Server `worlds\<index>.world.gzip` 존재
- 파일 크기가 0보다 큼
- 백업 폴더 생성 완료
- `ServerConfig.json`의 월드 인덱스가 선택값과 일치

실제 게임 접속 검증은 Windows 노트북에서 서버를 실행한 뒤 진행한다.

## 실패 시 복구 설계

월드 import가 실패하면 다음 순서로 복구한다.

1. Dedicated Server를 중지한다.
2. import 직전 백업 폴더를 찾는다.
3. 백업된 `worlds/`, `worldinfos/`, `ServerConfig.json`을 Dedicated Server 경로로 되돌린다.
4. 서버를 다시 실행한다.

복구 스크립트는 M3 이후 별도 구현 후보로 둔다.

## 구현 시 안전 원칙

- 가져온 월드 원본은 절대 삭제하지 않는다.
- Dedicated Server 데이터를 덮어쓰기 전 백업을 강제한다.
- 기본은 새 빈 월드이며, import는 명시적으로 실행할 때만 수행한다.
- `ServerConfig.json`은 구조를 보존하며 필요한 필드만 변경한다.
- 실패 시 어느 단계에서 멈췄는지 로그를 남긴다.

## 추후 확장 후보

- `CoreKeeperSaves.zip` import 지원
- `worlds/`, `worldinfos/` 폴더 묶음 import 지원

## 열린 질문

- Dedicated Server의 `ServerConfig.json` 최신 월드 필드명은 무엇인가?
- `worldinfos` 파일이 없을 때 Dedicated Server가 정상적으로 월드를 열 수 있는가?
