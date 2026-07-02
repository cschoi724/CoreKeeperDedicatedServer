---
id: T-20260701-007
title: GSM-R6 Core Keeper 월드 import Adapter 격리
status: done
type: feature
priority: P2
priority_reason: 가장 강한 Core Keeper 종속 로직을 Adapter로 격리해야 Core 범용성이 확보됨
target_agent: Development Agent
required_capabilities:
  - implementation
  - developer_verification
depends_on:
  - T-20260701-006
allowed_paths:
  - automation/src/Games/CoreKeeper/
  - automation/src/CoreKeeper.World.psm1
  - automation/scripts/import-world.ps1
  - automation/docs/
source_of_truth:
  - automation/docs/DEVELOPMENT_PLAN.md
  - automation/docs/REFACTORING_PLAN.md
  - automation/docs/MIGRATION_STRATEGY.md
created_by: PM Agent
approved_by: Product Owner
locked_by:
locked_at:
lock_session:
lock_timeout_minutes: 240
created_at: 2026-07-01
updated_at: 2026-07-02
report_to: .ai_project/reports/T-20260701-007_dev-report.md
qa_to: .ai_project/qa/T-20260701-007_qa-report.md
---

## 작업 범위

- `Games/CoreKeeper/CoreKeeper.Adapter.psm1`에 월드 import 함수 구현
- `.world.gzip` 검증과 `ServerConfig.json` world index 수정 로직 이동
- `import-world.ps1`가 Adapter의 import 지원 여부를 확인하고 위임하도록 변경
- Adapter가 지원하지 않는 게임에서는 명확한 unsupported 메시지 출력

## 제외 범위

- 다른 게임의 월드 import 구현
- Core Keeper worldinfos 자동 생성 추측 구현
- 안전 종료 자동화

## 완료 조건

- Core 모듈에 `.world.gzip`과 `ServerConfig.json` 수정 규칙이 남지 않는다.
- Core Keeper import 명령은 기존 흐름과 동일하게 사용할 수 있다.
- import 전 백업 강제 정책이 유지된다.

## 검증 기준

```powershell
.\scripts\import-world.ps1 -Game corekeeper -WorldFile "D:\Incoming\0.world.gzip" -WorldIndex 0 -WhatIf
```

## QA 확인 항목

- import 전 백업이 유지되는지
- 덮어쓰기 확인 정책이 유지되는지
- 원본 월드 파일을 수정하지 않는지

## 완료 기록

- 2026-07-02: Development Agent가 `Games/CoreKeeper/CoreKeeper.Adapter.psm1`로 `.world.gzip` 검증, 서버 중지 확인, `ServerConfig.json` world index 패치, import 흐름을 이동함.
- 2026-07-02: `CoreKeeper.World.psm1`를 Adapter manifest `features.worldImport` 확인 후 `Import-GameServerWorld`에 위임하는 compatibility wrapper로 전환함.
- 2026-07-02: `import-world.ps1`에 `-Game corekeeper` 기본값과 `-WhatIf` 전달을 추가함.
- 2026-07-02: macOS 환경에 PowerShell이 없어 원 검증 명령은 수행하지 못했고, 정적 구조/규칙 위치/공백 검증으로 대체함.
- 2026-07-02: QA Agent가 정적 검증을 수행하고 `PASS_WITH_RISK`로 `qa_passed` 처리함. Windows/PowerShell 환경의 원 검증 명령 실행은 잔여 리스크로 남김.
- 2026-07-02: Product Owner 지시에 따라 PM Agent가 완료 확정하고 `done` 처리함.
