# 작업 영역 상태

## 현재 상태

- 상태: T1 자동화 골격 작성 중
- 개발 환경: macOS에서 문서 작성, 실제 실행 대상은 Windows 노트북
- 검증 명령: 문서 파일 목록 확인, `git status -sb`
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

1. `DEVELOPMENT_PLAN.md`의 T1 자동화 골격 생성부터 진행
2. T2 SteamCMD 자동 설치 구현
3. T3 Dedicated Server 설치/업데이트 구현
4. T4 수동 서버 시작과 상태 확인 구현
5. 이후 T5-T10 순서로 진행

## 최근 작업

- 2026-06-24: T1 자동화 골격으로 README, example 설정, 공통/설정/경로 PowerShell 모듈을 추가
- 2026-06-24: `automation/` 작업 영역 문서 생성
- 2026-06-24: Git 저장소 초기화 상태를 문서에 반영
- 2026-06-24: Steam 전용 접속과 기본 빈 월드/기존 월드 import 방향을 반영
- 2026-06-24: 운영 기본값과 기본 빈 월드/import 설계를 반영
- 2026-06-24: `DEVELOPMENT_PLAN.md`를 T1-T10 작업 단위 기반 실행 계획으로 구체화

## 열린 질문

- Windows 노트북에서 T1 PowerShell 모듈 import 검증이 통과하는지?
- Windows 노트북의 PowerShell 버전은 5.1인지 7.x인지?
- 특정 시간 재시작 예약의 기본 추천 시간이 필요한지?

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
