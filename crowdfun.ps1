# Forzar la ejecución del script en modo administrativo
if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    exit
}

# Función para reiniciar en modo a prueba de fallos (Safe Mode)
function Restart-SafeMode {
    bcdedit /set {current} safeboot minimal
    Write-Host "Reiniciando en modo a prueba de fallos..."
    shutdown /r /t 0
}

# Función para reiniciar de forma normal
function Restart-Normal {
    bcdedit /deletevalue {current} safeboot
    Write-Host "Reiniciando de forma normal..."
    shutdown /r /t 0
}

# Cambiar a la carpeta C:\Windows\System32\drivers\CrowdStrike
$folderPath = "C:\Windows\System32\drivers\CrowdStrike"
if (-Not (Test-Path $folderPath)) {
    $folderPath = "$env:WINDIR\System32\drivers\CrowdStrike"
}

if (Test-Path $folderPath) {
    Set-Location $folderPath
    
    # Buscar y eliminar el archivo "C-00000291*.sys"
    $files = Get-ChildItem -Path $folderPath -Filter "C-00000291*.sys"
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
        Write-Host "Archivo eliminado: $($file.FullName)"
    }
}

# Preguntar al usuario si desea reiniciar en modo a prueba de fallos
$restartSafeMode = Read-Host "¿Desea reiniciar en modo a prueba de fallos? (s/n)"
if ($restartSafeMode -eq "s") {
    Restart-SafeMode
} else {
    Write-Host "No se reiniciará en modo a prueba de fallos."
    Write-Host "Eliminación de archivos completada. Puede reiniciar manualmente en modo normal."
}

# Después de completar las tareas, reiniciar de forma normal
$restartNormal = Read-Host "¿Desea reiniciar de forma normal ahora? (s/n)"
if ($restartNormal -eq "s") {
    Restart-Normal
} else {
    Write-Host "Puede reiniciar manualmente más tarde."
}
