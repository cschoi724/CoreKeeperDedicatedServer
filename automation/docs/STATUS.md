# 작업 영역 상태

## 현재 상태

- 상태: T1-T9 완료, Windows 실기 검증 필요
- 개발 환경: macOS에서 문서 작성, 실제 실행 대상은 Windows 노트북
- 검증 명령: 문서 파일 목록 확인, `git status -sb`, `command -v pwsh`, `git diff --cached --check`
- 접속 방식: Steam 전용 SDR(Game ID)
- 서버 설치 경로: `C:\CoreKeeperServer`
- 백업 경로: `D:\Backups\CoreKeeper`
- SteamCMD 설치: 템플릿에서 자동 설치
- 실행 방식: 기본 수동 실행
- 자동 실행: 선택 기능, 온/오프 가능
- 특정 시간 재시작: 선택 기능
- 서버 실행 계정: 현재 Windows 로그인 사용자
- 기존 월드: 서버 노트북에는 없음, 필요 시 사용자가 가져온 파일을 import

## 다음 작업

1. T10 Windows 실기 검증 진행
2. Windows 노트북에서 T1-T9 문서 절차대로 모듈 import, SteamCMD 설치, 서버 설치/업데이트, 수동 시작/상태 확인, 백업, 월드 import, 자동 실행/재시작 예약 작업 관리를 검증
3. Windows 실기 검증 결과에 따라 안전 종료/실제 재시작 확장 여부 결정
4. T10 이후 운영 확장 후보는 `docs/product/DEDICATED_SERVER_OPERATION_KNOWLEDGE.md` 기준으로 검토

## 최근 작업

- 2026-06-24: T1 자동화 골격으로 README, example 설정, 공통/설정/경로 PowerShell 모듈을 추가
- 2026-06-24: T2 SteamCMD 자동 설치 스크립트와 SteamCMD PowerShell 모듈을 추가
- 2026-06-24: T3 Dedicated Server 설치/업데이트 스크립트와 SteamCMD 공통 실행 함수를 추가
- 2026-06-24: T4 수동 서버 시작, 상태 확인, 보수적 종료 안내 스크립트를 추가
- 2026-06-24: T5 Dedicated Server 데이터 백업 스크립트와 백업 모듈을 추가
- 2026-06-24: T6 단일 `.world.gzip` import 스크립트와 월드 import 모듈을 추가
- 2026-06-24: T7 Windows Task Scheduler 자동 실행 등록/해제/활성화/비활성화 스크립트를 추가
- 2026-06-24: T8 Windows Task Scheduler 재시작 예약 등록/해제 스크립트를 추가
- 2026-06-24: T9 사용자 README와 Windows 실기 검증 체크리스트를 현재 구현 스크립트 기준으로 정리
- 2026-06-24: `automation/` 작업 영역 문서 생성
- 2026-06-24: Git 저장소 초기화 상태를 문서에 반영
- 2026-06-24: Steam 전용 접속과 기본 빈 월드/기존 월드 import 방향을 반영
- 2026-06-24: 운영 기본값과 기본 빈 월드/import 설계를 반영
- 2026-06-24: `DEVELOPMENT_PLAN.md`를 T1-T10 작업 단위 기반 실행 계획으로 구체화

## 열린 질문

- Windows 노트북에서 T1 PowerShell 모듈 import 검증이 통과하는지?
- Windows 노트북에서 T2 SteamCMD 다운로드/압축 해제 검증이 통과하는지?
- Windows 노트북에서 SteamCMD anonymous `app_update 1963720 validate`가 성공하는지?
- 최신 Windows Dedicated Server 실행 파일명/배치 파일명이 현재 후보 탐색 목록과 일치하는지?
- 안전한 서버 종료 명령 또는 콘솔 입력 방식은 무엇인지?
- Windows 노트북에서 `D:\Backups\CoreKeeper` 경로 생성과 백업 복사가 정상 동작하는지?
- 단일 `.world.gzip`만 import했을 때 `worldinfos` 없이 Dedicated Server가 정상적으로 월드를 여는지?
- 최신 `ServerConfig.json`의 월드 인덱스 필드명이 현재 후보 목록과 일치하는지?
- Windows Task Scheduler에서 현재 사용자 AtLogOn 작업 등록/해제/활성화/비활성화가 정상 동작하는지?
- Task Scheduler 등록에 관리자 권한이 필요한 Windows 정책인지?
- `CoreKeeperServerRestart` 예약 작업 등록/해제가 정상 동작하는지?
- 안전 종료 방식 확인 후 실제 자동 재시작 작업을 어떻게 확장할지?
- Windows 노트북의 PowerShell 버전은 5.1인지 7.x인지?

## 확인된 운영 지식

- Core Keeper Dedicated Server는 플레이어 0명일 때 자동으로 sleep 또는 대기 모드로 전환된다.
- Watchdog 또는 상태 조회 확장 시 이 상태를 장애로 오인하지 않는다.

## 세션 시작 체크리스트

- [ ] `git status -sb` 확인
- [ ] 작업 영역 `agents.md` 확인
- [ ] 개발 계획 확인
- [ ] 루트 결정사항과 열린 질문 확인

## 세션 종료 체크리스트

- [ ] 상태 업데이트
- [ ] 계획 업데이트
- [ ] 테스트 결과 업데이트
- [ ] 변경 기록 업데이트
