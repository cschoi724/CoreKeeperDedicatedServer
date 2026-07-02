# Workflow Overrides

작성일: 2026-07-01
프로젝트: Steam Game Server Manager

## 1. 목적

이 문서는 현재 프로젝트에서 `.ai/workflows/`와 다르게 운영해야 하는 예외를 기록한다.

기본값은 override 없음이다.

## 2. Overrides

| Workflow | Override | 이유 | 승인 |
|---|---|---|---|
| 없음 | 없음 | `.ai` 커밋 `59e0533` 감사 결과, 기존 `target_agent` 재정의 override가 `.ai/task_queue.md` 실행 권한 hard stop과 충돌함을 확인했다. 현재 프로젝트는 `.ai/task_queue.md` 기준을 따른다. | Product Owner 요청, `.ai` 59e0533 동기화 |

## 3. 원칙

- override는 프로젝트 특수성이 명확할 때만 추가한다.
- override가 `.ai/` 운영 원칙과 충돌하면 `.ai/`를 우선한다.
- 반복되는 override는 템플릿 개선 후보로 PM Agent가 제안한다.

## 4. Task QA 라우팅 메타데이터 기준

이 기준은 `.ai/task_queue.md`와 `.ai` 커밋 `59e0533`을 따른다. 기존 완료 Task의 과거 이력은 대량 수정하지 않고, 현재 진행 중이거나 후속 Task부터 적용한다.

### 4.1 `target_agent` 의미

`target_agent`는 현재 상태에서 Task를 실행할 권한이 있는 Agent를 뜻한다.

| Task 상태 | `target_agent` 예시 | 의미 |
|---|---|---|
| `approved`, `in_progress` | Development Agent 또는 PM Agent | 산출물 작성/수정 실행 담당 |
| `ready_for_qa`, `qa_in_progress` | QA Agent | QA 실행 담당 |
| `qa_passed`, `done`, `rework_requested` | PM Agent 또는 재작업 실행 Agent | 완료 확정, 재작업 승인, 후속 라우팅 담당 |

산출물의 원 작성 책임은 Task 본문, 완료 기록, `report_to` 경로, dev report에 남긴다. `target_agent`로 산출물 책임과 현재 실행 권한을 동시에 표현하지 않는다.

### 4.2 상태별 메타데이터 처리

| 상태 | `target_agent` | `locked_by` | Task Board 담당 Agent | Task Board Lock | 다음 조치 |
|---|---|---|---|---|---|
| `proposed` | 산출물 작성 후보 Agent | 비움 | PM Agent 또는 산출물 후보 Agent | 없음 | 승인 대기 또는 선행 조건 |
| `approved` | 산출물 작성 Agent | 비움 | 산출물 작성 Agent | 없음 | 담당 Agent가 lock 획득 후 진행 |
| `in_progress` | 산출물 작성 Agent | 실제 작업 Agent | 실제 작업 Agent | lock session 기록 | 작업 중 |
| `ready_for_qa` | QA Agent | 비움 | QA Agent | 없음 | QA 확인 |
| `qa_in_progress` | QA Agent | QA Agent | QA Agent | QA lock session 기록 | QA 검증 중 |
| `qa_passed` | PM Agent | 비움 | PM Agent 또는 Product Owner / PM Agent | 없음 | 완료 확정 또는 후속 승인 |
| `rework_requested` | 재작업 실행 Agent | 비움 | 재작업 실행 Agent | 없음 | 재작업 승인 대기 |
| `done` | PM Agent | 비움 | 없음 또는 PM Agent | 없음 | 완료 |

### 4.3 QA 보고와 재작업 라우팅

- QA Agent는 검증 결과를 `qa_to` 경로에 기록한다.
- QA 결과가 `FAIL`이면 Task 상태는 `rework_requested`로 전환한다.
- Product Owner 또는 PM Agent가 재작업을 승인하면 상태를 `approved`로 되돌린다.
- PM Agent는 재작업 승인 시 `target_agent`를 실제 재작업 실행 Agent로 설정한다.
- 재작업 범위가 기존 산출물 작성 Agent와 다르면 PM Agent가 Task에 별도 “재작업 범위”와 실행 Agent를 명시한다.
- QA 과정에서 발견한 후속 리스크는 기존 Task를 억지로 확장하지 않고 별도 proposed Task로 분리한다.

### 4.4 보드 표기 기준

Task Board의 Current Focus와 Active Locks는 “현재 실제로 움직일 사람”을 보여준다.

- `ready_for_qa`: 담당 Agent는 QA Agent로 표시하고 다음 조치를 `QA 확인`으로 둔다.
- `qa_in_progress`: 담당 Agent는 QA Agent로 표시하고 Lock에 QA Agent lock session을 기록한다.
- `qa_passed`: 담당 Agent는 PM Agent 또는 Product Owner / PM Agent로 표시하고 다음 조치를 `완료 확정` 또는 `후속 Task 승인`으로 둔다.
- `rework_requested`: 담당 Agent는 PM Agent가 지정한 재작업 실행 Agent로 표시하고 다음 조치를 `재작업 승인 대기`로 둔다.

### 4.5 새 Task 작성 규칙

PM Agent가 새 Task를 만들 때는 다음을 따른다.

- `target_agent`에는 현재 상태에서 실행할 Agent를 적는다.
- `report_to`는 산출물 책임 Agent의 보고서 경로를 적는다.
- `qa_to`는 QA Agent 검증 보고서 경로를 적는다.
- `ready_for_qa`로 전환할 때는 `target_agent: QA Agent`와 QA capability를 사용한다.
- QA 전용 운영 Task가 필요하면 `type: qa` 또는 `type: ops`로 분리하고 목적을 명시한다.

## 4.6 다음 작업 안내 기준

PM Agent가 다음 작업을 안내할 때는 `.ai` 커밋 `59e0533` 기준에 맞춰 아래 항목을 함께 표시한다.

- Task ID
- 상태
- 담당 Agent
- 담당 근거
- 열 세션
- 사용자 요청 문장

## 5. 변경 이력

| 날짜 | 변경 내용 |
|---|---|
| 2026-07-01 | Workflow override 문서 초기화 |
| 2026-07-02 | T-20260702-003 기준으로 Task QA 라우팅 메타데이터 처리 규칙 추가 |
| 2026-07-02 | `.ai` 커밋 `59e0533` 동기화 감사 결과에 따라 `target_agent` 재정의 override를 폐기하고 `.ai/task_queue.md` 기준으로 복구 |
