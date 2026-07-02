# Project Task Board Summary

작성일: 2026-07-02
프로젝트: Steam Game Server Manager

## 1. 목적

이 문서는 `.ai_project/tasks/`의 Task Queue를 요약하는 보드다.

실제 실행 지시와 상태 source of truth는 각 Task 파일이다. 이 문서는 현재 초점, 차단 항목, 최근 활동을 빠르게 확인하기 위해 사용한다.

## 2. Current Focus

| 우선순위 | Task ID | 상태 | 제목 | 담당 Agent | Lock | 다음 조치 |
|---|---|---|---|---|---|---|
| 1 | 없음 | - | 등록된 승인 대기/진행 중 Task 없음 | - | 없음 | 다음 작업 선정 |

## 3. Queue Summary

| 상태 | 개수 | 비고 |
|---|---:|---|
| proposed | 0 | |
| approved | 0 | |
| in_progress | 0 | |
| ready_for_qa | 0 | |
| qa_in_progress | 0 | |
| qa_passed | 0 | |
| rework_requested | 0 | |
| blocked | 0 | |
| done | 12 | T-20260701-001 ~ T-20260701-009, T-20260702-001 ~ T-20260702-003 |

## 4. Planned Queue

| 순서 | Task ID | 제목 | 담당 Agent | 의존성 |
|---:|---|---|---|---|
| 1 | T-20260701-001 | GSM-R0 방향 전환 문서화 검토 | PM Agent | 없음 |
| 2 | T-20260701-002 | GSM-R1 Adapter 아키텍처 문서 작성 | Development Agent | T-20260701-001 |
| 3 | T-20260701-003 | GSM-R2 Core Keeper Adapter manifest 도입 | Development Agent | T-20260701-002 |
| 4 | T-20260701-004 | GSM-R3 Config/Path Core 분리 | Development Agent | T-20260701-003 |
| 5 | T-20260701-005 | GSM-R4 SteamCMD Core 분리 | Development Agent | T-20260701-004 |
| 6 | T-20260701-006 | GSM-R5 Server/Backup/Scheduler Core 분리 | Development Agent | T-20260701-005 |
| 7 | T-20260701-007 | GSM-R6 Core Keeper 월드 import Adapter 격리 | Development Agent | T-20260701-006 |
| 8 | T-20260701-008 | GSM-R7 테스트와 Windows Runbook 재정렬 | Development Agent | T-20260701-007 |
| 9 | T-20260701-009 | GSM-R8 두 번째 게임 Skeleton Adapter 추가 | QA Agent | T-20260701-008 |
| 10 | T-20260702-001 | GSM-R2 AdapterManager PowerShell import 검증 | Development Agent | T-20260701-003 |
| 11 | T-20260702-002 | Steam Game Server Manager 네이밍 정리 | PM Agent | T-20260701-003 |
| 12 | T-20260702-003 | Task QA 라우팅 메타데이터 정리 | PM Agent | T-20260701-003 |

## 5. Blockers

| Task ID | 차단 사유 | 필요한 결정/조치 | 담당 | 의존성 |
|---|---|---|---|---|
| 없음 |  |  |  |  |

## 6. Active Locks

| Task ID | locked_by | locked_at | lock_session | 조치 |
|---|---|---|---|---|
| 없음 |  |  |  |  |

## 7. Recent Activity

| 날짜 | Agent | 내용 | 결과 |
|---|---|---|---|
| 2026-07-01 | AI Ops Agent | 프로젝트 AI 운영 구조 초기화 | `.ai_project/` 생성 |
| 2026-07-01 | AI Ops Agent | 기존 문서 source of truth와 병합/삭제 후보 정리 | `source_of_truth.md`, `ops_migration_plan.md`에 기록 |
| 2026-07-01 | PM Agent | 제품 방향을 Steam Game Server Manager로 전환하는 계획 수립 | 개발 계획, 리팩터링 계획, 마이그레이션 전략, Task Queue 갱신 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-001 진행 승인 | 상태를 `approved`로 변경 |
| 2026-07-02 | PM Agent | T-20260701-001 문서 검토 완료 | PM 보고서 작성 후 `done` 처리 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-002 진행 승인 | 상태를 `approved`로 변경 |
| 2026-07-02 | Development Agent | T-20260701-002 Adapter 아키텍처 문서 작성 완료 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-002 문서 계약 검증 | manifest 필드 불일치로 `rework_requested` 처리 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-002 재작업 진행 승인 | 상태를 `approved`로 변경 |
| 2026-07-02 | Development Agent | T-20260701-002 manifest 계약 불일치 수정 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-002 재검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-002 완료 확정 및 T-20260701-003 진행 승인 | T-20260701-002 `done`, T-20260701-003 `approved` |
| 2026-07-02 | Development Agent | T-20260701-003 Core Keeper Adapter manifest 도입 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-003 정적 검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | PM Agent | T-20260701-003 완료 확정 및 후속 리스크 Task 등록 | T-20260701-003 `done`, T-20260701-004 `approved` |
| 2026-07-02 | Development Agent | T-20260701-004 Config/Path Core 분리 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-004 정적 검증 | Core Keeper 전용 경로 상수 잔존으로 `rework_requested` 처리 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-004 재작업 진행 승인 | 상태를 `approved`로 변경 |
| 2026-07-02 | Development Agent | T-20260701-004 Core PathManager 전용 경로 제거 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-004 재검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | PM Agent | T-20260701-004 완료 확정 및 T-20260701-005 진행 승인 | T-20260701-004 `done`, T-20260701-005 `approved` |
| 2026-07-02 | Development Agent | T-20260701-005 SteamCMD Core 분리 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-005 정적 검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | PM Agent | T-20260701-005 완료 확정 및 T-20260701-006 진행 승인 | T-20260701-005 `done`, T-20260701-006 `approved` |
| 2026-07-02 | Development Agent | T-20260701-006 Server/Backup/Scheduler Core 분리 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-006 정적 검증 | wrapper import 누락으로 `rework_requested` 처리 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-006 재작업 진행 승인 | 상태를 `approved`로 변경 |
| 2026-07-02 | Development Agent | T-20260701-006 wrapper import 누락 수정 | 정적 재검증 후 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-006 재검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | PM Agent | T-20260701-006 완료 확정 및 T-20260701-007 진행 승인 | T-20260701-006 `done`, T-20260701-007 `approved` |
| 2026-07-02 | Development Agent | T-20260701-007 작업 착수 | 상태를 `in_progress`로 변경하고 lock 획득 |
| 2026-07-02 | Development Agent | T-20260701-007 Core Keeper 월드 import Adapter 격리 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-007 정적 검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-007 완료 확정 및 T-20260701-008 진행 승인 | T-20260701-007 `done`, T-20260701-008 `approved` |
| 2026-07-02 | Development Agent | T-20260701-008 작업 착수 | 상태를 `in_progress`로 변경하고 lock 획득 |
| 2026-07-02 | Development Agent | T-20260701-008 테스트/Windows Runbook 재정렬 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-008 문서 명령 계약 검증 | `New-GameServerSteamCmdAppUpdateArguments -Game` 불일치로 `rework_requested` 처리 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-008 재작업 진행 승인 | 상태를 `approved`로 변경하고 문서 명령 수정 범위 명시 |
| 2026-07-02 | Development Agent | T-20260701-008 재작업 착수 | 상태를 `in_progress`로 변경하고 lock 획득 |
| 2026-07-02 | Development Agent | T-20260701-008 문서 명령 계약 불일치 수정 | 정적 재검증 후 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260701-008 재검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-008 완료 확정 및 T-20260702-002 진행 승인 | T-20260701-008 `done`, T-20260702-002 `approved` |
| 2026-07-02 | PM Agent | T-20260702-002 네이밍 정리 착수 | 상태를 `in_progress`로 변경하고 lock 획득 |
| 2026-07-02 | PM Agent | T-20260702-002 네이밍 정리 완료 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260702-002 네이밍 정리 검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260702-002 완료 확정 및 T-20260702-003 진행 승인 | T-20260702-002 `done`, T-20260702-003 `approved` |
| 2026-07-02 | PM Agent | T-20260702-003 작업 착수 | 상태를 `in_progress`로 변경하고 lock 획득 |
| 2026-07-02 | PM Agent | T-20260702-003 QA 라우팅 메타데이터 기준 정리 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260702-003 QA 라우팅 메타데이터 검증 | `PASS`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260702-003 완료 확정 및 T-20260702-001 진행 승인 | T-20260702-003 `done`, T-20260702-001 `approved` |
| 2026-07-02 | Development Agent | T-20260702-001 AdapterManager PowerShell 검증 리스크 확인 | PowerShell 부재를 보고하고 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | QA Agent | T-20260702-001 AdapterManager PowerShell 검증 리스크 QA | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260702-001 완료 확정 및 T-20260701-009 준비 | T-20260702-001 `done`, T-20260701-009 후보 게임 선택 필요 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-009 진행 승인 | 두 번째 skeleton Adapter 후보를 `Valheim`으로 확정하고 상태를 `approved`로 변경 |
| 2026-07-02 | Development Agent | T-20260701-009 작업 착수 | 상태를 `in_progress`로 변경하고 lock 획득 |
| 2026-07-02 | Development Agent | T-20260701-009 Valheim skeleton Adapter 추가 | 상태를 `ready_for_qa`로 변경 |
| 2026-07-02 | PM Agent | `.ai` 59e0533 동기화 반영 | T-20260701-009 `ready_for_qa` 실행 담당을 QA Agent로 보정 |
| 2026-07-02 | QA Agent | T-20260701-009 Valheim skeleton Adapter 검증 | `PASS_WITH_RISK`, 상태를 `qa_passed`로 변경 |
| 2026-07-02 | Product Owner / PM Agent | T-20260701-009 완료 확정 | T-20260701-009 `done`, GSM-R0~GSM-R8 전환 Queue 완료 |

## 8. 다음 작업 안내

사용자에게 다음 진행 작업을 말할 때는 `.ai` 커밋 `59e0533` 기준으로 아래 항목을 함께 적는다.

| 항목 | 설명 |
|---|---|
| Task ID | 실행할 Task ID와 제목 |
| 상태 | 현재 Task 상태 |
| 담당 Agent | PM Agent / Development Agent / QA Agent / AI Ops Agent |
| 담당 근거 | `target_agent`, 상태, required capability 기준 |
| 열 세션 | 사용자가 열어야 할 Agent 세션 |
| 사용자 요청 | 해당 Agent에게 전달할 요청 문장 |

현재 기준 다음 작업:

| Task ID | 상태 | 담당 Agent | 담당 근거 | 열 세션 | 사용자 요청 |
|---|---|---|---|---|---|
| 없음 | - | PM Agent | GSM-R0~GSM-R8 Queue 완료, 후속 Task 미등록 | PM Agent 세션 | `현재 완료된 GSM-R 전환 결과를 기준으로 다음 개발 Task를 선정해줘.` |
