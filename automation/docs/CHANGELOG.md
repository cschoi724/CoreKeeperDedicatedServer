# automation 변경 기록

## 2026-06-24

- T1 자동화 골격 추가: `README.md`, `config/settings.example.json`, 공통/설정/경로 PowerShell 모듈 생성
- T1 검증 문서 추가: Windows PowerShell 모듈 import 확인 명령 기록
- T2 SteamCMD 자동 설치 추가: `scripts/install-steamcmd.ps1`, `src/CoreKeeper.SteamCmd.psm1` 생성
- T2 검증 문서 추가: SteamCMD 설치 확인 명령과 macOS 미검증 항목 기록
- T3 Dedicated Server 설치/업데이트 추가: `scripts/install-server.ps1`, `scripts/update-server.ps1` 생성
- T3 SteamCMD 공통 실행 함수 추가: `app_update 1963720 validate` 실행, output log, exit code 에러 처리 기록
- 작업 영역 `agents.md` 추가
- 개발 계획, 상태, 테스트 문서 추가
- 실제 구현은 보류하고 열린 질문을 문서화
- Git 저장소 초기화 상태 반영
- Steam 전용 SDR(Game ID) 운영 결정 반영
- 기본 빈 월드/기존 월드 import 설계 문서 추가
- 설치/백업 경로, SteamCMD 자동 설치, 기본 수동 실행, 선택 자동 실행/재시작, 기본 빈 월드/import 방향 반영
- 개발 계획을 T1-T10 작업 단위, 산출 파일, 완료 조건, 검증 명령, 권장 커밋 단위로 구체화
