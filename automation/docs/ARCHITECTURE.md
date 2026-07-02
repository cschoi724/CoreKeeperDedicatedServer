# 아키텍처

이 문서는 Steam Game Server Manager의 Core/Adapter 구조를 정의한다.

## 1. 목표

- SteamCMD 기반 데디케이티드 서버 관리 흐름을 공통 Core로 분리한다.
- 게임별 AppID, 설치 경로, 실행 파일, 데이터 경로, 백업 대상, 로그 규칙은 Adapter에 둔다.
- 기존 게임 전용 스크립트는 호환성을 위해 유지하되, 내부 구현은 점진적으로 Core/Adapter 구조로 위임한다.
- 신규 게임 추가 시 공통 Core 코드를 수정하지 않는 구조를 목표로 한다.

## 2. 비목표

- 기존 구현을 한 번에 재작성하지 않는다.
- Windows 실기 검증 전 안전 종료, 자동 재시작, Health Check 동작을 추측으로 확정하지 않는다.
- 첫 전환 단계에서 여러 게임의 완전한 운영 지원을 목표로 하지 않는다.
- 사용자 서버 데이터, 백업 데이터, 기존 설정 파일을 자동 이동하지 않는다.

## 3. 상위 구조

```text
automation/
├── config/
│   ├── manager.example.json
│   └── games/
│       └── <game>.example.json
├── scripts/
│   └── *.ps1
└── src/
    ├── Core/
    │   ├── AdapterManager.psm1
    │   ├── ConfigManager.psm1
    │   ├── SteamCmdManager.psm1
    │   ├── ServerManager.psm1
    │   ├── BackupManager.psm1
    │   └── SchedulerManager.psm1
    ├── Games/
    │   └── <GameName>/
    │       ├── game.json
    │       └── <GameName>.Adapter.psm1
    └── Compatibility/
        └── *.psm1
```

## 4. 실행 흐름

공통 스크립트는 다음 순서로 동작한다.

1. `-Game` 인자를 읽는다. 값이 없으면 manager 설정의 기본 게임을 사용한다.
2. `AdapterManager`가 대상 게임의 manifest와 선택 Adapter 모듈을 로드한다.
3. `ConfigManager`가 manager 설정, 게임별 설정, 기존 호환 설정을 병합한다.
4. 각 Core manager가 Adapter에서 받은 값으로 설치, 실행, 백업, 스케줄링을 수행한다.
5. Adapter가 지원하지 않는 선택 기능은 명확한 unsupported 메시지를 반환한다.

## 5. Core 책임

Core는 게임 이름이나 게임별 파일 구조를 직접 알지 않는다.

Core가 담당하는 범위:

- Adapter discovery와 manifest 로딩
- manager 설정 로딩과 게임별 설정 병합
- SteamCMD 설치, 업데이트, 명령 실행
- Steam App 설치와 업데이트 실행
- 서버 프로세스 시작, 상태 조회, 종료 위임 흐름
- 백업/복원 엔진
- 로그 파일 탐색 프레임워크
- Windows Task Scheduler 등록, 해제, 활성화, 비활성화
- 공통 오류 처리와 사용자 메시지
- 선택 기능 미지원 상태 보고

Core에서 금지하는 항목:

- 특정 게임 AppID 하드코딩
- 특정 게임 실행 파일명 하드코딩
- 특정 게임 저장 데이터 경로 하드코딩
- 특정 게임 월드 파일 형식 처리
- 특정 게임 로그 문구를 공통 로직에 직접 삽입

## 6. Adapter 책임

Adapter는 게임별 차이를 Core에 제공한다.

Adapter가 담당하는 범위:

- Steam AppID와 로그인 방식
- 기본 설치 경로와 기본 백업 경로
- 서버 실행 파일 후보와 실행 인자
- 프로세스 식별 규칙
- 서버 데이터 루트와 설정 파일 위치
- 백업 대상 목록
- 로그 파일 위치와 상태 힌트 패턴
- 게임별 config patch 방식
- 게임별 월드 import, restore, migrate 방식
- 게임별 안전 종료 방식
- 게임별 Health Check

## 7. Manifest 우선 원칙

Adapter는 먼저 `game.json` manifest로 표현한다.

Manifest만으로 처리할 수 있는 값:

- 게임 ID와 표시 이름
- Steam AppID와 로그인 방식
- 기본 설치/백업/데이터 경로
- 실행 파일 후보
- 프로세스명 패턴
- 백업 대상 목록
- 로그 탐색 힌트
- 지원 기능 플래그

PowerShell Adapter 모듈은 manifest로 표현하기 어려운 동작이 있을 때만 추가한다. 예를 들면 월드 import, 설정 파일 patch, 안전 종료, 게임별 Health Check가 여기에 해당한다.

## 8. 설정 계층

설정은 다음 우선순위로 병합한다.

1. 실행 인자
2. 게임별 local 설정
3. manager local 설정
4. 게임별 example 설정
5. manager example 설정
6. 기존 호환 설정
7. Adapter manifest 기본값

초기 마이그레이션에서는 기존 설정 파일을 fallback으로 유지한다. 기존 경로를 새 경로로 자동 이동하지 않는다.

## 9. 호환 계층

기존 사용자 명령은 즉시 제거하지 않는다.

호환 정책:

- 기존 스크립트 파일명은 유지한다.
- 기존 명령에서 `-Game`을 생략하면 기본 게임으로 해석한다.
- 기존 게임 전용 모듈은 wrapper로 유지한다.
- 새 Core 모듈이 안정화되기 전에는 기존 함수를 삭제하지 않는다.
- deprecation 메시지는 기능 안정화 후 별도 Task에서 도입한다.

## 10. 오류 처리

Core는 실패 지점을 명확히 구분한다.

| 상황 | 처리 |
|---|---|
| 게임 ID를 찾을 수 없음 | 사용 가능한 Adapter 목록과 함께 실패 |
| manifest가 유효하지 않음 | 누락 필드와 파일 경로를 출력 |
| 필수 Adapter 함수 없음 | Adapter 계약 위반으로 실패 |
| 선택 Adapter 함수 없음 | 기능 미지원 메시지 출력 |
| SteamCMD 실패 | SteamCMD 로그 위치와 종료 코드를 출력 |
| 백업 대상 없음 | 대상 목록과 Adapter ID를 출력 |

## 11. 후속 구현 순서

1. `AdapterManager`와 게임 manifest 로딩을 도입한다.
2. 설정/경로 계산을 Core로 분리한다.
3. SteamCMD 설치/업데이트를 Adapter 값 기반으로 전환한다.
4. 서버 실행/상태/백업/스케줄링을 Adapter 값 기반으로 전환한다.
5. 게임별 월드 import와 설정 patch를 Adapter 모듈로 격리한다.
6. 테스트 문서를 공통 Core 검증과 게임 Adapter 검증으로 나눈다.

## 12. Core Keeper Adapter 예시

Core Keeper는 첫 번째 공식 Adapter이자 회귀 검증 기준이다. 다음 값은 공통 Core가 아니라 Core Keeper Adapter manifest 또는 Core Keeper Adapter 모듈에 위치해야 한다.

| 항목 | 예시 값 |
|---|---|
| gameId | `corekeeper` |
| displayName | `Core Keeper` |
| Steam AppID | `1963720` |
| 데이터 루트 | `%USERPROFILE%\AppData\LocalLow\Pugstorm\Core Keeper\DedicatedServer` |
| 백업 대상 | `worlds`, `worldinfos`, `ServerConfig.json` |
| 특수 기능 | `.world.gzip` import, Game ID 로그 탐색 |

Core Keeper 전용 문자열인 `CoreKeeper`, `Core Keeper`, `1963720`, `Pugstorm`은 이 예시, Core Keeper Adapter 파일, 또는 호환 wrapper에만 남아야 한다.
