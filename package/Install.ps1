[CmdletBinding()]
param([string]$ClientPath, [switch]$Uninstall)
$ErrorActionPreference = 'Stop'
if (Get-Process WoW -ErrorAction SilentlyContinue) { throw 'Fully close WoW before installing or uninstalling.' }
if ([string]::IsNullOrWhiteSpace($ClientPath)) { $ClientPath = Read-Host 'Full path to the folder containing WoW.exe' }
$clientRoot = (Resolve-Path -LiteralPath $ClientPath).Path
$dllName = 'EnchantVisualsDiagnostic.dll'
$iniName = 'EnchantVisualsDiagnostic.ini'
$goodHash = '0F21B57F3F7F9D763FC69FCA37431ECA42499E7DA71C154EB7B08C288752D87E'
# Recognize previous releases by content, independently of their file names.
$previousHashes = @('70D6B81BF77393925BDEAB9C3813679FC36EE29A9F3460303039E95D245AE4D5', '265EF069B9827339E3BBF6DC611E85CF3900DBB242F785C5746EB97EAEB926C7')
$dllPath = Join-Path $clientRoot $dllName
$iniPath = Join-Path $clientRoot $iniName
$loaderPath = Join-Path $clientRoot 'dlls.txt'
$utf8 = [Text.UTF8Encoding]::new($false, $true)
if ((Test-Path -LiteralPath $dllPath) -and (Get-FileHash -LiteralPath $dllPath -Algorithm SHA256).Hash -ne $goodHash) { throw "Unrecognized DLL at $dllPath; no files changed." }
if (-not $Uninstall) {
    if ((Get-FileHash -LiteralPath (Join-Path $clientRoot 'WoW.exe') -Algorithm SHA256).Hash -ne '183CD1128BCB9FA7D1BC7B3EAAA3AB384F71FDAADFA1BE3AD8D458E93587D4BD') { throw 'Unsupported client executable; no files changed.' }
    if ((Get-FileHash -LiteralPath (Join-Path $PSScriptRoot $dllName) -Algorithm SHA256).Hash -ne $goodHash) { throw 'Package DLL checksum mismatch; no files changed.' }
}
$originalBytes = [IO.File]::ReadAllBytes($loaderPath)
$text = $utf8.GetString($originalBytes)
$previous = @()
foreach ($file in Get-ChildItem -LiteralPath $clientRoot -Filter '*.dll' -File) {
    if ($file.Name -ieq $dllName) { continue }
    if ((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -in $previousHashes) { $previous += $file.FullName }
}
$ownedNames = @($dllName) + @($previous | ForEach-Object { [IO.Path]::GetFileName($_) })
foreach ($name in $ownedNames) { $text = [regex]::Replace($text, ('(?im)^[ \t]*' + [regex]::Escape($name) + '[ \t]*\r?\n?'), '') }
$configBytes = $null
if (Test-Path -LiteralPath $iniPath) { $configBytes = [IO.File]::ReadAllBytes($iniPath) }
if ($null -eq $configBytes) {
    foreach ($path in $previous) {
        $candidate = [IO.Path]::ChangeExtension($path, '.ini')
        if (Test-Path -LiteralPath $candidate) { $configBytes = [IO.File]::ReadAllBytes($candidate); break }
    }
}
if ($null -eq $configBytes) { $configBytes = $utf8.GetBytes("[Diagnostic]`r`nEnableHooks=1`r`n") }
$backup = Join-Path $PSScriptRoot ('backups\' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($backup) | Out-Null
$ownedPaths = @($dllPath, $iniPath) + $previous + @($previous | ForEach-Object { [IO.Path]::ChangeExtension($_, '.ini') })
foreach ($path in (@($loaderPath) + $ownedPaths | Select-Object -Unique)) {
    if (Test-Path -LiteralPath $path) { Copy-Item -LiteralPath $path -Destination $backup }
}
if ($Uninstall) {
    [IO.File]::WriteAllBytes($loaderPath, $utf8.GetBytes($text))
    foreach ($path in $ownedPaths | Select-Object -Unique) { if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path } }
    Write-Output "Enchant Visuals uninstalled. Backups: $backup"
} else {
    if (-not (Test-Path -LiteralPath $dllPath)) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot $dllName) -Destination $dllPath }
    [IO.File]::WriteAllBytes($iniPath, $configBytes)
    if ($text.Length -gt 0 -and -not $text.EndsWith("`n")) { $text += "`r`n" }
    $text += "$dllName`r`n"
    [IO.File]::WriteAllBytes($loaderPath, $utf8.GetBytes($text))
    foreach ($path in $previous) {
        Remove-Item -LiteralPath $path
        $oldIni = [IO.Path]::ChangeExtension($path, '.ini')
        if (Test-Path -LiteralPath $oldIni) { Remove-Item -LiteralPath $oldIni }
    }
    Write-Output "Enchant Visuals 1.0.1 installed. Existing configuration preserved. Backups: $backup"
}
