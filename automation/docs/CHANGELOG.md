# automation 변경 기록

## 2026-06-24

- T1 자동화 골격 추가: `README.md`, `config/settings.example.json`, 공통/설정/경로 PowerShell 모듈 생성
- T1 검증 문서 추가: Windows PowerShell 모듈 import 확인 명령 기록
- T2 SteamCMD 자동 설치 추가: `scripts/install-steamcmd.ps1`, `src/CoreKeeper.SteamCmd.psm1` 생성
- T2 검증 문서 추가: SteamCMD 설치 확인 명령과 macOS 미검증 항목 기록
- T3 Dedicated Server 설치/업데이트 추가: `scripts/install-server.ps1`, `scripts/update-server.ps1` 생성
- T3 SteamCMD 공통 실행 함수 추가: `app_update 1963720 validate` 실행, output log, exit code 에러 처리 기록
- T4 수동 서버 운영 추가: `scripts/start-server.ps1`, `scripts/status-server.ps1`, `scripts/stop-server.ps1`, `src/CoreKeeper.Server.psm1` 생성
- T4 상태 확인 추가: Dedicated Server 데이터 폴더, 실행 후보, 실행 프로세스, Game ID 로그 힌트 확인
- T5 서버 데이터 백업 추가: `scripts/backup-server.ps1`, `src/CoreKeeper.Backup.psm1` 생성
- T5 백업 정책 추가: `worlds`, `worldinfos`, `ServerConfig.json` 백업, 누락 대상 skip 메시지, manifest 기록
- T6 기존 월드 import 추가: `scripts/import-world.ps1`, `src/CoreKeeper.World.psm1` 생성
- T6 import 안전 정책 추가: 단일 `.world.gzip` 검증, import 전 백업 강제, 기존 대상 덮어쓰기 명시 확인, 원본 파일 보존
- T7 자동 실행 작업 관리 추가: `scripts/register-task.ps1`, `scripts/unregister-task.ps1`, `scripts/enable-task.ps1`, `scripts/disable-task.ps1`, `src/CoreKeeper.Tasks.psm1` 생성
- T7 Task Scheduler 정책 추가: 현재 사용자 AtLogOn 작업, `start-server.ps1` 실행 대상, 관리자 권한 안내
- T8 재시작 예약 작업 추가: `scripts/register-restart-task.ps1`, `scripts/unregister-restart-task.ps1` 생성
- T8 안전 제한 추가: `HH:mm` 시간 검증, 강제 종료 없는 보수적 예약 작업, 안전 종료 미검증 문서화
- T9 사용자 문서 정리: `automation/README.md`를 현재 스크립트 이름과 Windows 사용 순서 기준으로 재작성
- T9 테스트 문서 정리: `docs/TESTING.md`를 Windows 실기 검증 명령 순서, 미검증 항목, 현재 범위 밖 항목 중심으로 재구성
- Windows Codex 실기 검증 Runbook 추가: Codex 세션 시작, 설치, 실행, 백업, import, Task Scheduler 검증, 결과 커밋 절차 정리
- 작업 영역 `agents.md` 추가
- 개발 계획, 상태, 테스트 문서 추가
- 실제 구현은 보류하고 열린 질문을 문서화
- Git 저장소 초기화 상태 반영
- Steam 전용 SDR(Game ID) 운영 결정 반영
- 기본 빈 월드/기존 월드 import 설계 문서 추가
- 설치/백업 경로, SteamCMD 자동 설치, 기본 수동 실행, 선택 자동 실행/재시작, 기본 빈 월드/import 방향 반영
- 개발 계획을 T1-T10 작업 단위, 산출 파일, 완료 조건, 검증 명령, 권장 커밋 단위로 구체화
