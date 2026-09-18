$ErrorActionPreference='Stop'
$source=Join-Path (Split-Path -Parent $PSScriptRoot) 'package\Install.ps1'
$scriptText=[IO.File]::ReadAllText($source)
$currentHash=[regex]::Match($scriptText, "\`$goodHash = '([A-F0-9]+)'").Groups[1].Value
if ($currentHash.Length -ne 64) { throw 'Missing release checksum.' }
$root=Join-Path ([IO.Path]::GetTempPath()) ('enchant-installer-test-'+[guid]::NewGuid().ToString('N'))
$package=Join-Path $root 'package'; $client=Join-Path $root 'client'
[IO.Directory]::CreateDirectory($package) | Out-Null
[IO.Directory]::CreateDirectory($client) | Out-Null
Copy-Item -LiteralPath $source -Destination (Join-Path $package 'Install.ps1')
[IO.File]::WriteAllText((Join-Path $package 'EnchantVisualsDiagnostic.dll'),'current')
[IO.File]::WriteAllText((Join-Path $client 'WoW.exe'),'supported')
[IO.File]::WriteAllText((Join-Path $client 'PreviousVisuals.dll'),'previous')
[IO.File]::WriteAllText((Join-Path $client 'Unrelated.dll'),'unrelated')
[IO.File]::WriteAllText((Join-Path $client 'PreviousVisuals.ini'),"[Diagnostic]`r`nEnableHooks=0`r`n")
[IO.File]::WriteAllText((Join-Path $client 'dlls.txt'),"Unrelated.dll`r`nPreviousVisuals.dll`r`n")
# These mocks apply only to files in the disposable fixture.
function Get-Process { param($Name,$ErrorAction) return $null }
function Get-FileHash {
    param($LiteralPath,$Algorithm)
    $value=[IO.File]::ReadAllText($LiteralPath)
    $hash=switch ($value) {
        'supported' { '183CD1128BCB9FA7D1BC7B3EAAA3AB384F71FDAADFA1BE3AD8D458E93587D4BD' }
        'current' { $currentHash }
        'previous' { '70D6B81BF77393925BDEAB9C3813679FC36EE29A9F3460303039E95D245AE4D5' }
        default { '0000000000000000000000000000000000000000000000000000000000000000' }
    }
    return [pscustomobject]@{Hash=$hash}
}
$installer=Join-Path $package 'Install.ps1'
& $installer -ClientPath $client
if (Test-Path -LiteralPath (Join-Path $client 'PreviousVisuals.dll')) { throw 'Previous library remains.' }
if ([IO.File]::ReadAllText((Join-Path $client 'EnchantVisualsDiagnostic.ini')) -notmatch 'EnableHooks=0') { throw 'Configuration was reset.' }
if ([IO.File]::ReadAllText((Join-Path $client 'Unrelated.dll')) -ne 'unrelated') { throw 'Unrelated mod changed.' }
$loader=[IO.File]::ReadAllText((Join-Path $client 'dlls.txt'))
if ($loader -cne "Unrelated.dll`r`nEnchantVisualsDiagnostic.dll`r`n") { throw 'Incorrect loader entries.' }
& $installer -ClientPath $client
if ([IO.File]::ReadAllText((Join-Path $client 'dlls.txt')) -cne $loader) { throw 'Reinstallation duplicated loader entries.' }
$backup=@(Get-ChildItem -LiteralPath (Join-Path $package 'backups') -Recurse -Filter 'PreviousVisuals.dll')
if ($backup.Count -ne 1) { throw 'Missing previous-library backup.' }
& $installer -ClientPath $client -Uninstall
if (Test-Path -LiteralPath (Join-Path $client 'EnchantVisualsDiagnostic.dll')) { throw 'Uninstall left the library.' }
if ([IO.File]::ReadAllText((Join-Path $client 'dlls.txt')) -cne "Unrelated.dll`r`n") { throw 'Uninstall changed unrelated entries.' }
[IO.File]::WriteAllText((Join-Path $client 'WoW.exe'),'unsupported')
$refused=$false
try { & $installer -ClientPath $client } catch { $refused=$_.Exception.Message -like '*Unsupported client*' }
if (-not $refused) { throw 'Unsupported client accepted.' }
[IO.File]::WriteAllText((Join-Path $client 'EnchantVisualsDiagnostic.dll'),'unrelated')
$refused=$false
try { & $installer -ClientPath $client -Uninstall } catch { $refused=$_.Exception.Message -like '*Unrecognized DLL*' }
if (-not $refused) { throw 'Unrecognized library accepted.' }
Write-Output 'PASS: upgrade, configuration preservation, backups, unrelated mods, repeated installation, uninstall and checksum rejection.'
