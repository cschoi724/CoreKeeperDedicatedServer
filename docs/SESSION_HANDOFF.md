# 세션 인수인계

## 현재 운영 방식

- 개발 진행 기준은 `automation/docs/DEVELOPMENT_PLAN.md`입니다.
- 현재 상태와 다음 작업은 `automation/docs/STATUS.md`를 봅니다.
- 검증 명령과 미검증 항목은 `automation/docs/TESTING.md`를 봅니다.
- 작업 기록은 `automation/docs/CHANGELOG.md`를 봅니다.
- 개발 에이전트에게는 긴 요구사항을 반복하지 않고, 기준 문서와 진행할 T번호만 전달합니다.

## 현재 구현 상태

- T1-T8 구현 완료
- T9 사용자 문서 완성 예정
- T10 Windows 실기 검증 예정
- macOS에서는 Windows PowerShell, SteamCMD, Task Scheduler, Core Keeper 서버 실행 검증을 하지 않습니다.

## 검증

- 문서 파일 목록 확인 완료
- 실제 Core Keeper Dedicated Server 실행 검증은 수행하지 않음
- macOS 환경에서는 서버 실행을 하지 않는다는 원칙 유지

## 문서 업데이트

- `README.md`
- `agents.md`
- `docs/`
- `docs/product/REQUIREMENTS.md`
- `automation/`

## 남은 작업

1. `automation/docs/DEVELOPMENT_PLAN.md`의 T9 진행
2. T9 완료 후 Windows 노트북에서 T10 실기 검증 진행
3. T10 결과를 `automation/docs/TESTING.md`, `automation/docs/STATUS.md`에 기록

## 다음 개발 에이전트 지시 템플릿

```text
문서를 기준으로 진행해줘.

먼저 읽을 문서:
- agents.md
- automation/agents.md
- automation/docs/DEVELOPMENT_PLAN.md
- automation/docs/STATUS.md
- automation/docs/TESTING.md

이번 목표:
- DEVELOPMENT_PLAN.md의 T{번호} 진행

완료 후:
- STATUS.md, TESTING.md, CHANGELOG.md 갱신
- 작업 단위 커밋
- git status -sb 공유
```
