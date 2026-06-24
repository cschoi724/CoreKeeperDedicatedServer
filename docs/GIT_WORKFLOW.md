# Git 운영 기준

## 현재 상태

- 2026-06-24 기준 로컬 Git 저장소를 `main` 브랜치로 초기화했다.
- 원격 저장소: `https://github.com/cschoi724/CoreKeeperDedicatedServer.git`
- 원격 이름: `origin`

## 기본 전략

- 기본 브랜치: `main`
- 평소 작업은 `main`에서 진행 가능
- 큰 실험이나 충돌 가능 작업만 `work/{topic}` 브랜치 사용
- 다른 장비나 Codex 세션에서 이어가기 전에는 push 수행

## 작업 전 체크

```bash
git status -sb
```

Git 저장소가 아니면 먼저 사용자에게 초기화/원격 연결 방식을 확인한다. 현재 프로젝트는 이미 로컬 저장소로 초기화되어 있다.

## 원격 설정

```bash
git remote add origin https://github.com/cschoi724/CoreKeeperDedicatedServer.git
git push -u origin main
```

## 커밋 단위

- 문서 구조 추가: `docs: 프로젝트 운영 문서 추가`
- 자동화 기능 추가: `feat: Windows 서버 설치 자동화 추가`
- 버그 수정: `fix: 백업 경로 처리 수정`
- 검증 추가: `test: PowerShell 스크립트 검증 추가`
- 환경 정리: `chore: 개발 환경 정리`

## 금지 사항

- 사용자 변경사항 임의 되돌리기 금지
- 요청 없는 destructive 명령 금지
- 확정되지 않은 서버 설정을 결정사항처럼 커밋 메시지에 적지 않기
