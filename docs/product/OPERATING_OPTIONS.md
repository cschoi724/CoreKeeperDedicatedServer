# 운영 옵션 설명과 추천

이 문서는 사용자가 이해하기 어려웠던 Windows 서버 운영 옵션을 풀어서 설명하고, 현재 프로젝트의 추천 선택지를 기록한다.

## 결론

현재 프로젝트의 추천 옵션은 다음과 같다.

- 서버 설치: SteamCMD 자동 설치/확인 방식
- 접속 방식: Steam 전용 SDR(Game ID)
- Direct Connect: 기본 범위에서 제외
- 서버 실행: 기본 수동 실행
- 서버 자동 시작: Windows Task Scheduler로 선택 등록
- 특정 시간 재시작: 선택 등록
- 서버 실행 계정: Windows 노트북의 일반 사용자 계정 우선
- 서버 설치 경로: `C:\CoreKeeperServer`
- 백업 위치: `D:\Backups\CoreKeeper`

## SteamCMD를 쓸지 Steam GUI Tools를 쓸지

SteamCMD는 Steam 게임 서버를 명령어로 설치하고 업데이트하는 도구다. 일반 Steam 앱 화면을 켜서 버튼을 누르는 방식이 아니라, 스크립트가 Core Keeper Dedicated Server 설치, 업데이트, 파일 검증을 자동으로 수행할 수 있다.

SteamCMD 장점:

- 자동화에 적합하다.
- Windows 재설치나 다른 PC 이전 시 재현하기 쉽다.
- Codex가 PowerShell 스크립트로 다루기 좋다.
- Steam 클라이언트를 계속 켜 둘 필요가 줄어든다.

SteamCMD 단점:

- 처음 보는 사용자에게는 명령어 기반이라 낯설다.
- SteamCMD 다운로드/설치 단계가 필요하다.

Steam GUI Tools는 Steam 앱의 라이브러리 Tools 항목에서 Core Keeper Dedicated Server를 설치하고 실행하는 방식이다.

Steam GUI Tools 장점:

- 처음 설치가 직관적이다.
- Steam 앱에 익숙하면 접근이 쉽다.

Steam GUI Tools 단점:

- 자동화 템플릿으로 만들기 어렵다.
- 업데이트/실행/자동 시작을 스크립트로 일관되게 관리하기 불편하다.
- Windows 부팅 후 자동 실행 구조를 따로 붙여야 한다.

추천:

- 이 프로젝트는 clone 후 실행 가능한 자동화 템플릿이 목표이므로 SteamCMD를 추천한다.
- Steam GUI Tools는 사용자가 수동으로 빠르게 테스트하고 싶을 때의 보조 경로로만 문서화한다.

## SDR(Game ID)와 Direct Connect

SDR(Game ID)는 서버가 Game ID를 만들고, 친구들이 Core Keeper에서 Game ID로 접속하는 방식이다. Steam 중심 서버에 적합하다.

SDR(Game ID) 장점:

- 공유기 포트포워딩을 기본적으로 피할 수 있다.
- 서버 IP를 친구들에게 직접 알려줄 필요가 줄어든다.
- Steam 친구끼리 쓰는 비공개 서버에 가장 단순하다.

SDR(Game ID) 단점:

- Steam 외 플랫폼이나 IP 직접 접속이 필요한 경우에는 적합하지 않을 수 있다.

Direct Connect는 친구들이 IP, Port, Password로 직접 접속하는 방식이다.

Direct Connect 장점:

- IP 기반 직접 접속이 가능하다.
- Steam 외 PC 플랫폼이 섞인 상황에서 필요할 수 있다.

Direct Connect 단점:

- Windows 방화벽 설정이 필요하다.
- 공유기 포트포워딩이 필요할 수 있다.
- 집 인터넷이 CGNAT이면 외부 접속이 막힐 수 있다.
- 보안과 운영 복잡도가 올라간다.

현재 결정:

- 사용자는 Steam에서만 접속한다고 결정했다.
- 현재 프로젝트는 SDR(Game ID)를 기본이자 우선 지원 방식으로 둔다.
- Direct Connect는 지금 구현 우선순위에서 제외하고, 나중에 필요해질 때 선택 기능으로 추가한다.

## Task Scheduler 자동 시작과 재시작

Task Scheduler는 Windows가 부팅될 때 지정한 프로그램이나 스크립트를 자동으로 실행하는 기능이다.

이 프로젝트에서는 기본 서버 실행을 수동으로 둔다. 다만 사용자가 원하면 서버 노트북이 재부팅되어도 Core Keeper Dedicated Server가 다시 켜지도록 Task Scheduler 등록 기능을 제공한다.

추천 방식:

- 서버 설치/첫 실행/월드 import가 끝난 뒤 Task Scheduler 등록
- 작업 이름은 `CoreKeeperServer`
- 실행 대상은 이 프로젝트의 서버 시작 스크립트
- 자동 시작 등록은 관리자 권한이 필요할 수 있으므로 별도 스크립트로 분리
- 자동 실행은 등록/해제 또는 활성화/비활성화할 수 있게 구현
- 특정 시간 재시작은 별도 예약 작업 `CoreKeeperServerRestart` 후보로 구현
- 재시작 시간은 사용자가 직접 입력

## 서버 실행 계정

Windows 노트북의 일반 사용자 계정으로 실행한다.

이유:

- Core Keeper 저장 경로가 사용자 프로필 아래에 생성된다.
- 사용자가 파일을 찾고 백업하기 쉽다.
- Dedicated Server 초기 설정과 월드 import가 단순하다.

별도 서버 전용 Windows 계정은 만들지 않는다.

## 백업 위치

백업은 `D:\Backups\CoreKeeper`를 기본 경로로 사용한다.

추천:

- 기본 경로: `D:\Backups\CoreKeeper`
- D 드라이브가 없으면 구현 세션에서 오류 메시지와 대체 경로 입력을 제공
- 월드 import 전에는 무조건 백업
- 업데이트 전에도 백업 권장

## 기존 월드 가져오기

Windows 노트북에는 Core Keeper 실행 이력과 기존 월드가 없다. 따라서 기존 Steam 계정 폴더 자동 탐색을 기본으로 하지 않는다.

추천 방식:

- 서버 기본값은 새 빈 월드
- 기존 월드를 쓰고 싶을 때만 사용자가 단일 `.world.gzip` 파일을 가져온다.
- import 스크립트는 가져온 파일을 Dedicated Server 저장 경로에 복사한다.
- import 전 Dedicated Server 데이터는 반드시 백업한다.
