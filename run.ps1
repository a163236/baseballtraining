# Flutter / Git が PATH に無い場合用の起動スクリプト
$flutterBin = "$env:USERPROFILE\flutter\bin"
$gitBin = "C:\Program Files\Git\bin"
if (Test-Path $flutterBin) {
  $env:PATH = "$flutterBin;$gitBin;" + $env:PATH
}

Set-Location $PSScriptRoot

$device = $args[0]
if (-not $device) {
  Write-Host "利用可能なデバイス:"
  flutter devices
  Write-Host ""
  Write-Host "例: .\run.ps1 edge      # ブラウザ (Edge)"
  Write-Host "     .\run.ps1 windows  # Windows デスクトップ (要デベロッパーモード)"
  Write-Host "     .\run.ps1 chrome   # Chrome"
  exit 0
}

flutter run -d $device
