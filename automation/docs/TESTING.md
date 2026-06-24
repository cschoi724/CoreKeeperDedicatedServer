# 테스트 기준

## 기본 검증 명령

현재 구현 파일이 없으므로 검증 명령은 확정되지 않았다.

구현 후 후보:

```powershell
# PowerShell 문법 검사 후보
Get-ChildItem .\scripts\*.ps1 | ForEach-Object {
  $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$null)
}
```

```powershell
# PSScriptAnalyzer 도입 시 후보
Invoke-ScriptAnalyzer -Path .\scripts -Recurse
```

## Windows 실기 검증 항목

- 저장소 clone 후 README 절차만으로 시작 가능한지
- SteamCMD 설치 또는 경로 확인이 동작하는지
- App ID `1963720` 설치/업데이트가 동작하는지
- 첫 실행 후 Dedicated Server 데이터 경로가 생성되는지
- 기본 빈 월드가 생성되는지
- 기존 월드 import 후 올바른 월드가 열리는지
- Game ID가 확인 가능한지
- Task Scheduler 자동 시작 등록/해제/활성화/비활성화가 동작하는지
- 특정 시간 재시작 예약이 등록되는지
- Steam 전용 SDR(Game ID) 접속 흐름이 문서와 일치하는지

## 검증 기록

- 날짜: 2026-06-24
- 명령: 없음
- 결과: 문서만 생성, 실행 검증 없음
- 비고: 실제 서버 실행 환경은 Windows 노트북

## 알려진 이슈

- macOS에서는 Windows PowerShell/Task Scheduler/SteamCMD 실행 검증을 하지 않는다.
- Core Keeper Dedicated Server 최신 실행 인자는 구현 전 Windows에서 재확인해야 한다.
- Windows 실기 검증은 집 Windows 노트북에서 새 Codex 세션으로 진행한다.
