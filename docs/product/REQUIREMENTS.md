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
4. 사용자가 기존 Steam 월드 파일을 Dedicated Server 월드 경로로 이전한다.
5. 서버가 SDR(Game ID) 또는 선택적으로 Direct Connect 방식으로 실행된다.
6. 친구들은 사용자가 게임에 접속하지 않아도 서버에 접속한다.
7. 서버는 재부팅 후 자동 시작되며, 월드는 정기적으로 백업된다.

## 범위

### 포함 후보

- Windows용 설치/업데이트 자동화
- 기존 월드 이전 절차
- 백업/복구 절차
- Task Scheduler 기반 자동 시작
- SDR(Game ID) 기본 운영
- Direct Connect 선택 운영
- Windows 방화벽 규칙 선택 생성

### 제외

- macOS에서 Core Keeper Dedicated Server 실행
- Linux/systemd/Docker/NAS/VPS 구현
- 게임 클라이언트 모드 관리
- 클라우드 인프라 자동 생성

## 성공 기준

- Windows 노트북에서 clone 후 문서만 보고 설치를 시작할 수 있다.
- 기존 월드를 Dedicated Server로 이전할 때 백업이 선행된다.
- 서버 설치/업데이트/시작/백업/자동 시작 절차가 분리되어 있다.
- 불확실하거나 환경 의존적인 값은 사용자 입력 또는 명시적 설정으로 처리한다.

## 열린 질문

- 친구들이 모두 Steam 사용자인가?
- Direct Connect가 꼭 필요한가?
- Windows 노트북은 절전모드가 비활성화되어 있는가?
- 서버를 실행할 Windows 계정은 항상 로그인 상태인가?
- 서버 프로세스를 콘솔 창으로 유지할지, 예약 작업으로 백그라운드 실행할지?

