# 제품 요구사항

## 배경

현재 사용자는 Core Keeper를 Steam에서 직접 호스트해 친구들과 플레이하고 있다. 이 방식은 사용자가 게임에 접속해 있어야만 친구들이 월드에 접속할 수 있다.

## 목표

기존에 플레이하던 월드를 Dedicated Server로 이전하여, 사용자가 게임에 접속하지 않아도 친구들이 언제든 접속할 수 있게 한다.

## 실행 환경

- 문서/템플릿 작성 환경: macOS
- 실제 서버 실행 환경: 집에 있는 Windows 노트북
- macOS에서는 서버 실행, SteamCMD 설치, Dedicated Server 구동 검증을 하지 않는다.

## 사용자 시나리오

1. 사용자가 Windows 노트북에서 저장소를 clone한다.
2. 사용자가 README 또는 자동화 스크립트 안내에 따라 서버 설치를 실행한다.
3. 템플릿이 SteamCMD 기반으로 Core Keeper Dedicated Server를 설치 또는 업데이트한다.
4. 서버는 기본적으로 새 빈 월드로 시작한다.
5. 사용자가 기존 월드를 쓰고 싶으면 별도 파일로 가져와 Dedicated Server 월드 경로에 import한다.
6. 서버가 Steam 전용 SDR(Game ID) 방식으로 실행된다.
7. 친구들은 사용자가 게임에 접속하지 않아도 서버에 접속한다.
8. 서버는 기본 수동 실행이며, 사용자가 원하면 자동 실행과 특정 시간 재시작을 켤 수 있다.

## 범위

### 포함 후보

- Windows용 설치/업데이트 자동화
- 기존 월드 import 절차
- 백업/복구 절차
- Task Scheduler 기반 자동 시작 온/오프
- 특정 시간 서버 재시작 예약
- SDR(Game ID) 기본 운영

### 추후 후보

- Direct Connect 선택 운영
- Windows 방화벽 규칙 선택 생성

### 제외

- macOS에서 Core Keeper Dedicated Server 실행
- Linux/systemd/Docker/NAS/VPS 구현
- 게임 클라이언트 모드 관리
- 클라우드 인프라 자동 생성

## 성공 기준

- Windows 노트북에서 clone 후 문서만 보고 설치를 시작할 수 있다.
- 기존 월드를 Dedicated Server로 import할 때 백업이 선행된다.
- 서버 설치/업데이트/시작/백업/import/자동 시작 절차가 분리되어 있다.
- 불확실하거나 환경 의존적인 값은 사용자 입력 또는 명시적 설정으로 처리한다.

## 확인된 운영 지식

- Core Keeper Dedicated Server는 플레이어가 0명일 때 자동으로 sleep 또는 대기 모드로 전환된다.
- 따라서 서버가 24시간 실행 중이어도 무인 상태에서 월드 시뮬레이션이 계속 진행된다고 가정하지 않는다.
- Watchdog 또는 상태 조회 기능을 추가할 때 sleep/idle 상태를 장애로 오인하지 않는다.

자세한 내용은 `DEDICATED_SERVER_OPERATION_KNOWLEDGE.md`를 따른다.

## 열린 질문

- 친구들은 Steam으로만 접속한다.
- Direct Connect는 현재 필요하지 않다.
- Windows 노트북은 Core Keeper를 실행한 적이 없고 기존 월드도 없다.
- 기존 월드는 하나이며, 필요 시 사용자가 별도 파일로 가져온다.
- Steam 계정 폴더는 우선 하나로 예상하지만 기본 흐름은 로컬 계정 폴더 탐색에 의존하지 않는다.
- 절전모드는 문서로 안내한다.
