Param(
    [switch]$Release
)

$ErrorActionPreference = 'Stop'

function Get-FirstEmulatorId {
  $lines = flutter emulators
  # Tabela: "Id • Name • Manufacturer • Platform" seguido por linhas com IDs
  foreach ($l in $lines) {
    if ($l -match '^\s*$') { continue }
    if ($l -match '^Id\s+•') { continue }
    if ($l -match '^To run an emulator') { break }
    # Pega o primeiro token não-espacado como ID
    if ($l -match '^(\S+)\s+•') { return $Matches[1] }
  }
  return $null
}

function Get-FirstAndroidDeviceId {
  $lines = flutter devices --device-timeout 60
  foreach ($l in $lines) {
    # Ex.: "sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 15 (API 35) (emulator)"
    if ($l -match '•\s+(emulator-\d+)\s+•') { return $Matches[1] }
    # Fallback para IDs de dispositivos físicos
    if ($l -match '•\s+([A-Za-z0-9_-]+)\s+•') { return $Matches[1] }
  }
  return $null
}

Write-Host '>> Checando dispositivos e emuladores Android...'

# Tenta lançar um emulador, se disponível
$emuId = Get-FirstEmulatorId
if ($emuId) {
  Write-Host ">> Iniciando emulador: $emuId"
  flutter emulators --launch "$emuId" | Out-Host
} else {
  Write-Warning 'Nenhum emulador configurado. Tentando abrir o Device Manager...'
  $studioCandidates = @(
    "$env:ProgramFiles\Android\Android Studio\bin\studio64.exe",
    "$env:ProgramFiles(x86)\Android\Android Studio\bin\studio64.exe"
  )
  $openedStudio = $false
  foreach ($p in $studioCandidates) {
    if (Test-Path $p) {
      Write-Host ">> Abrindo Android Studio Device Manager: $p"
      Start-Process -FilePath $p -ArgumentList "--device-manager" | Out-Null
      $openedStudio = $true
      break
    }
  }
  if (-not $openedStudio) {
    Write-Warning 'Não localizei o Android Studio automaticamente. Abra-o manualmente e crie um AVD.'
  }
}

# Aguarda um dispositivo aparecer no ADB
Write-Host '>> Aguardando dispositivo/emulador ficar online...'
for ($i = 0; $i -lt 60; $i++) {
  try {
    $adb = (& adb devices) -join "\n"
  } catch {
    $adb = ''
  }
  if ($adb -match 'emulator-|device') { break }
  Start-Sleep -Seconds 2
}

# Executa o app no Android
$devId = Get-FirstAndroidDeviceId
if (-not $devId) {
  Write-Warning 'Nenhum dispositivo Android foi detectado. Executando flutter doctor para diagnóstico...'
  flutter doctor -v | Out-Host
  Write-Warning 'Verifique o ADB/AVD e tente novamente.'
  exit 1
}

if ($Release) {
  Write-Host ">> Rodando em modo release no Android (dispositivo: $devId)"
  flutter run -d "$devId" --release | Out-Host
} else {
  Write-Host ">> Rodando em modo debug no Android (dispositivo: $devId)"
  flutter run -d "$devId" | Out-Host
}