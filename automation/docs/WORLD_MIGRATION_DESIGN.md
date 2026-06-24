# 기존 Steam 월드 이전 설계

이 문서는 사용자의 Steam 계정에 속한 기존 Core Keeper 월드를 Windows Dedicated Server로 옮기는 작업을 구현하기 위한 설계다. 현재는 설계 문서이며 실제 스크립트 구현은 아직 하지 않았다.

## 현재 전제

- 기존 월드는 사용자의 Steam 계정에 속해 있다.
- 서버 실행 환경은 집의 Windows 노트북이다.
- 접속 방식은 Steam 전용 SDR(Game ID)이다.
- macOS에서는 실제 월드 파일 이전을 하지 않는다.

## 목표

사용자가 파일 위치를 잘 몰라도, 자동화 스크립트가 가능한 한 안전하게 기존 월드를 찾아 Dedicated Server용 저장 경로로 복사한다.

## Windows 기준 후보 경로

클라이언트 Steam 월드 후보:

```text
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\Steam\<steam-id>\worlds\<index>.world.gzip
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\Steam\<steam-id>\worldinfos\<index>.worldinfo
```

Dedicated Server 월드 후보:

```text
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worlds\<index>.world.gzip
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\worldinfos\<index>.worldinfo
%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer\ServerConfig.json
```

정확한 파일 확장자와 `ServerConfig.json` 구조는 Windows 실기 검증 때 재확인한다.

## 이전 절차 설계

### 1. 사전 확인

스크립트는 먼저 다음을 확인한다.

- Core Keeper 클라이언트 저장 루트가 존재하는지
- Steam 계정 ID 폴더가 몇 개 있는지
- 각 계정 폴더 아래 `worlds` 폴더가 있는지
- Dedicated Server 저장 루트가 존재하는지

Dedicated Server 저장 루트가 없으면, 먼저 서버를 1회 실행해 설정 파일과 폴더를 생성하도록 안내한다.

### 2. Steam 계정 선택

Steam 계정 ID 폴더가 하나면 자동 선택 후보로 표시한다.

Steam 계정 ID 폴더가 여러 개면 다음 정보를 보여주고 사용자가 선택하게 한다.

- Steam ID 폴더명
- 발견된 월드 파일 개수
- 각 월드 파일의 수정 시간

자동으로 임의 계정을 선택하지 않는다.

### 3. 월드 선택

선택한 Steam 계정 폴더 아래에서 `worlds\*.world.gzip` 파일을 찾는다.

스크립트는 다음 정보를 보여준다.

- 월드 인덱스
- 파일명
- 파일 크기
- 마지막 수정 시간
- 대응되는 `worldinfos` 파일 존재 여부

사용자가 옮길 월드를 직접 선택한다.

### 4. 서버 중지 확인

월드 복사 전 Dedicated Server가 실행 중이면 중지해야 한다.

초기 구현에서는 프로세스를 강제로 종료하지 않고, 사용자에게 서버 콘솔에서 정상 종료하도록 안내한다.

이유:

- 월드 저장 중 강제 종료하면 데이터 손상 위험이 있다.
- Core Keeper 서버 정상 종료 방식은 Windows 실기 검증 때 확인해야 한다.

### 5. 서버 데이터 백업

월드 이전 전에는 Dedicated Server 데이터 폴더를 반드시 백업한다.

백업 대상:

- `worlds/`
- `worldinfos/`
- `ServerConfig.json`

백업 경로 후보:

```text
<사용자 지정 백업 루트>\before-migration-YYYYMMDD-HHMMSS\
```

백업 실패 시 월드 이전을 중단한다.

### 6. 월드 복사

선택한 클라이언트 월드 파일을 Dedicated Server의 `worlds` 폴더로 복사한다.

초기 정책:

- 서버 월드 인덱스는 사용자가 선택하게 한다.
- 기본 추천 인덱스는 `0`
- 기존 `0.world.gzip`이 있으면 백업 후 덮어쓰기 확인을 요구한다.

월드 정보 파일이 있으면 `worldinfos` 폴더에도 함께 복사한다.

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

월드 이전이 실패하면 다음 순서로 복구한다.

1. Dedicated Server를 중지한다.
2. 이전 직전 백업 폴더를 찾는다.
3. 백업된 `worlds/`, `worldinfos/`, `ServerConfig.json`을 Dedicated Server 경로로 되돌린다.
4. 서버를 다시 실행한다.

복구 스크립트는 M3 이후 별도 구현 후보로 둔다.

## 구현 시 안전 원칙

- 사용자 Steam 월드 원본은 절대 삭제하지 않는다.
- Dedicated Server 데이터를 덮어쓰기 전 백업을 강제한다.
- 여러 Steam 계정이나 여러 월드가 있으면 자동 선택하지 않는다.
- `ServerConfig.json`은 구조를 보존하며 필요한 필드만 변경한다.
- 실패 시 어느 단계에서 멈췄는지 로그를 남긴다.

## 열린 질문

- 현재 Windows 노트북에서 Steam 계정 ID 폴더가 몇 개 존재하는가?
- 옮길 월드 인덱스는 무엇인가?
- Dedicated Server의 `ServerConfig.json` 최신 월드 필드명은 무엇인가?
- `worldinfos` 파일 확장자와 구조는 현재 버전에서도 위 후보와 동일한가?

