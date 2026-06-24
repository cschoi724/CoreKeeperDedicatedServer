# 개발 계획

## 현재 상태 요약

- 현재 이정표: M0 문서 기반 준비
- 완료된 범위: 운영 문서 구조 생성
- 다음 범위: Windows 자동화 템플릿 파일 구조 설계

## 산출물 후보

구현 세션에서 아래 파일 구조를 검토한다. 아직 확정된 구현은 아니다.

```text
automation/
├── README.md
├── config/
│   └── settings.example.json
├── scripts/
│   ├── install-steamcmd.ps1
│   ├── install-server.ps1
│   ├── update-server.ps1
│   ├── migrate-world.ps1
│   ├── backup-server.ps1
│   ├── register-task.ps1
│   ├── unregister-task.ps1
│   ├── enable-task.ps1
│   ├── disable-task.ps1
│   ├── register-restart-task.ps1
│   └── start-server.ps1
└── docs/
    ├── OPERATIONS_DESIGN.md
    └── WORLD_MIGRATION_DESIGN.md
```

## 이정표

### M0. 기반 준비

- [x] 루트 운영 문서 생성
- [x] 작업 영역 문서 생성
- [x] Git 저장소 초기화/원격 연결 방식 확정
- [x] 원격 저장소 push 완료 확인
- [x] Steam 전용 SDR(Game ID) 운영 방향 확정
- [x] 기본 빈 월드와 단일 `.world.gzip` import 설계 작성
- [x] 설치 경로 `C:\CoreKeeperServer` 확정
- [x] 백업 경로 `D:\Backups\CoreKeeper` 확정
- [x] SteamCMD 자동 설치 방식 확정
- [x] 기본 수동 실행 및 선택 자동 실행/재시작 방향 확정

### M1. Windows 자동화 설계

- [ ] PowerShell 버전과 실행 정책 요구사항 정리
- [ ] 설치/업데이트/백업/월드 import 명령 경계 정의
- [ ] 설정 파일 템플릿 형식 정의
- [ ] 위험 작업 확인 절차 정의
- [ ] Steam 전용 SDR(Game ID) 기준 서버 시작 흐름 정의
- [ ] 자동 실행 온/오프와 특정 시간 재시작 Task Scheduler 설계 확정

### M2. 설치/업데이트 자동화 구현

- [ ] SteamCMD 자동 다운로드/설치
- [ ] SteamCMD 기존 설치 경로 확인
- [ ] Core Keeper Dedicated Server App `1963720` 설치
- [ ] 서버 업데이트 명령 작성
- [ ] Game ID 확인 안내 또는 자동 표시 방식 작성

### M3. 월드 import/백업 자동화 구현

- [ ] 기본 빈 월드 시작 흐름 작성
- [ ] 사용자가 가져온 단일 `.world.gzip` 파일 import 방식 작성
- [ ] Dedicated Server 월드 경로 백업
- [ ] 월드 파일 복사와 서버 월드 인덱스 일치 검증
- [ ] 복구 절차 문서화

### M4. Windows 운영 자동화

- [ ] Task Scheduler 자동 시작 등록
- [ ] 자동 시작 등록 해제
- [ ] 자동 시작 활성화/비활성화
- [ ] 특정 시간 서버 재시작 예약 등록
- [ ] 로그/상태 확인 명령 작성
- [ ] 제거/비활성화 절차 작성
- [ ] Direct Connect는 추후 선택 기능으로 별도 계획

### M5. Windows 실기 검증

- [ ] Windows 노트북에서 clone 후 설치 검증
- [ ] 서버 첫 실행과 Game ID 확인
- [ ] 기본 빈 월드 생성 검증
- [ ] 기존 월드 import 검증
- [ ] 자동 시작 온/오프 검증
- [ ] 특정 시간 재시작 예약 검증
- [ ] 집 Windows 노트북의 새 Codex 세션에서 검증 기록 작성

## 다음 작업

1. Windows 자동화 템플릿 파일 구조를 확정한다.
2. SteamCMD 자동 설치 스크립트부터 구현한다.
3. 서버 설치/시작 스크립트를 구현한다.
4. 월드 import 스크립트는 `WORLD_MIGRATION_DESIGN.md` 기준으로 구현한다.
5. 자동 실행/재시작 스크립트는 `OPERATIONS_DESIGN.md` 기준으로 구현한다.

## 최근 작업 로그

- 2026-06-24: 루트 관리 세션에서 개발 계획 초안을 작성함.
- 2026-06-24: Git 저장소 초기화와 원격 저장소 정보를 반영함.
- 2026-06-24: Steam 전용 접속 결정과 기본 빈 월드/기존 월드 import 설계를 반영함.
- 2026-06-24: 사용자의 운영 기본값 결정을 반영해 설치/백업/실행/재시작/import 계획을 구체화함.
