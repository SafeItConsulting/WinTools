function ExetoText
{
<#
.SYNOPSIS
Nishang script to convert an executable to text file.

.DESCRIPTION
This script converts and an executable to a text file.

.PARAMETER EXE
The path of the executable to be converted.

.PARAMETER FileName
Path of the text file to which executable will be converted.

.EXAMPLE
PS > ExetoText C:\binaries\evil.exe C:\test\evil.txt

.LINK
http://www.exploit-monday.com/2011/09/dropping-executables-with-powershell.html
https://github.com/samratashok/nishang
#>
    [CmdletBinding()] Param(
        [Parameter(Position = 0, Mandatory = $True)]
        [String]
        $EXE, 
        
        [Parameter(Position = 1, Mandatory = $False)]
        [String]
        $Filename = "$pwd\ConvertedText.txt"
    )
    [byte[]] $hexdump = get-content -encoding byte -path "$EXE"
    [System.IO.File]::WriteAllLines($Filename, ([string]$hexdump))
    Write-Output "Converted file written to $Filename"
}


