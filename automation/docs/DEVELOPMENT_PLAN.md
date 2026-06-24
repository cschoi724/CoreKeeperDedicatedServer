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
│   └── server.example.json
├── scripts/
│   ├── install-steamcmd.ps1
│   ├── install-server.ps1
│   ├── update-server.ps1
│   ├── migrate-world.ps1
│   ├── backup-server.ps1
│   ├── register-task.ps1
│   └── start-server.ps1
└── docs/
```

## 이정표

### M0. 기반 준비

- [x] 루트 운영 문서 생성
- [x] 작업 영역 문서 생성
- [x] Git 저장소 초기화/원격 연결 방식 확정
- [ ] 원격 저장소 push 완료 확인

### M1. Windows 자동화 설계

- [ ] PowerShell 버전과 실행 정책 요구사항 정리
- [ ] 설치/업데이트/백업/월드 이전 명령 경계 정의
- [ ] 설정 파일 템플릿 형식 정의
- [ ] 위험 작업 확인 절차 정의

### M2. 설치/업데이트 자동화 구현

- [ ] SteamCMD 설치 또는 경로 확인
- [ ] Core Keeper Dedicated Server App `1963720` 설치
- [ ] 서버 업데이트 명령 작성
- [ ] Game ID 확인 안내 또는 자동 표시 방식 작성

### M3. 월드 이전/백업 자동화 구현

- [ ] 기존 Steam 월드 경로 입력/탐지 방식 작성
- [ ] Dedicated Server 월드 경로 백업
- [ ] 월드 파일 복사와 인덱스 일치 검증
- [ ] 복구 절차 문서화

### M4. Windows 운영 자동화

- [ ] Task Scheduler 자동 시작 등록
- [ ] Direct Connect 선택 시 Windows 방화벽 규칙 생성
- [ ] 로그/상태 확인 명령 작성
- [ ] 제거/비활성화 절차 작성

### M5. Windows 실기 검증

- [ ] Windows 노트북에서 clone 후 설치 검증
- [ ] 서버 첫 실행과 Game ID 확인
- [ ] 기존 월드 이전 검증
- [ ] 재부팅 후 자동 시작 검증

## 다음 작업

1. 원격 저장소 push 완료 여부를 확인한다.
2. 열린 질문을 사용자와 정리한다.
3. Windows 자동화 템플릿 파일 구조를 확정한다.
4. 구현 세션에서 PowerShell 스크립트를 작성한다.

## 최근 작업 로그

- 2026-06-24: 루트 관리 세션에서 개발 계획 초안을 작성함.
- 2026-06-24: Git 저장소 초기화와 원격 저장소 정보를 반영함.
