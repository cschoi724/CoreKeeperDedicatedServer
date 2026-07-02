---
id: T-20260701-009
title: GSM-R8 두 번째 게임 Skeleton Adapter 추가
status: done
type: feature
priority: P2
priority_reason: Core가 Core Keeper에 종속되지 않았음을 최소 비용으로 검증
target_agent: QA Agent
required_capabilities:
  - qa_review
  - risk_review
depends_on:
  - T-20260701-008
allowed_paths:
  - .ai_project/reports/
  - .ai_project/tasks/T-20260701-009_gsm-r8-second-game-skeleton.md
  - automation/config/games/
  - automation/src/Games/
  - automation/docs/
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/ADAPTER_GUIDE.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-009_dev-report.md
qa_to: .ai_project/qa/T-20260701-009_qa-report.md
---

## 작업 범위

- Product Owner가 선택한 두 번째 게임 `Valheim`의 skeleton Adapter 추가
- manifest discovery 검증
- 미구현 기능은 unsupported로 명확히 표시
- `ADAPTER_GUIDE.md`에 신규 Adapter 추가 절차 검증 결과 반영

## 산출물 책임

- 산출물 작성 Agent: Development Agent
- 현재 실행 담당 Agent: QA Agent
- 사유: Development Agent가 Valheim skeleton Adapter 산출물을 작성하고 `ready_for_qa`로 전환했으므로, `.ai/task_queue.md` 기준에 따라 QA 단계의 `target_agent`는 QA Agent로 둔다.

## 제외 범위

- 두 번째 게임 실제 서버 설치/실행 보장
- 게임별 상세 설정 patch 구현
- 포트포워딩/방화벽 자동화

## 완료 조건

- Core 모듈 수정 없이 두 번째 Adapter가 로드된다.
- Core Keeper 전용 fallback 없이 Adapter discovery가 동작한다.
- 미지원 기능이 실패가 아니라 명시적 unsupported 상태로 보고된다.

## 검증 기준

```powershell
Get-GameServerAdapter -Game valheim
```

## 선택 게임

- 게임: `Valheim`
- Adapter ID: `valheim`
- 선택 이유: Core Keeper와 다른 게임을 최소 skeleton으로 추가해 Core/Adapter discovery가 특정 게임에 종속되지 않았음을 검증하기에 적합함.

## 구현 지시

- 구현 전 Valheim Dedicated Server의 Steam AppID, 기본 실행 파일 후보, 기본 포트, 설정/세이브 경로 후보를 확인하고 dev report에 출처 또는 확인 근거를 남긴다.
- 실제 서버 설치/실행 보장은 제외 범위이므로, 확실하지 않은 게임별 기능은 `features` 또는 문서에서 unsupported/unknown으로 명확히 둔다.
- Core 모듈은 수정하지 않는다. Core 수정이 필요해 보이면 구현하지 말고 report에 구조 이슈로 기록한다.
- `automation/src/Games/Valheim/game.json`과 필요한 example config만 추가한다.
- PowerShell이 현재 환경에 없으면 원 검증 명령은 Windows/PowerShell 검증 필요로 남기고, JSON parse와 manifest discovery 구조 정적 검증을 수행한다.

## 사용자 결정 기록

- 2026-07-02: Product Owner가 T-20260701-009 진행을 승인했고, PM Agent가 두 번째 skeleton Adapter 후보를 `Valheim`으로 확정함.

## 완료 기록

- 2026-07-02: PM Agent가 `Valheim`을 선택 게임으로 지정하고 T-20260701-009를 `approved`로 전환함.
- 2026-07-02: Development Agent가 `Valheim` skeleton Adapter manifest와 example config를 추가하고 Core 수정 없이 정적 discovery 검증 후 `ready_for_qa`로 전환함.
- 2026-07-02: `.ai` 커밋 `59e0533` 동기화 감사 결과에 따라 `ready_for_qa` 상태의 실행 담당을 QA Agent로 보정함. 산출물 작성 책임은 Development Agent로 본문에 보존함.
- 2026-07-02: QA Agent가 Valheim skeleton manifest와 문서 반영을 검증하고 `PASS_WITH_RISK`로 `qa_passed` 처리함.
- 2026-07-02: Product Owner 요청에 따라 PM Agent가 QA 결과를 확인하고 `done`으로 완료 확정함.
