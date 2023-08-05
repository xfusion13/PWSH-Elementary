param (
    [string] $UserName,
    [string] $Passwd,
    [string] $Server,
    [string] $Groupname,
    [PSCredential] $Credential,
    [switch] $Help
)
function Invoke-HelpMessage{
    Write-Host "`nAdd new domain user and add him to target group.`n"

    Write-Host "-u [-UserName]   New user"
    Write-Host "-p [-Passwd]     Password, generate by default"
    Write-Host "-g [-Groupname]  Group, if needed"
    Write-Host "-c [-Credential] Credential"
    Write-Host "-s [-Server]     Domain Controller IP or FQDN`n"
}

if ($Help){Invoke-HelpMessage; return}
if (!$UserName) {Write-Host "[E] Please enter a username.`r" -ForegroundColor Red; return}

$PathToUtils = ($MyInvocation.MyCommand.Path | Split-Path -parent) + "\utils.psm1"
Import-Module $PathToUtils, "ActiveDirectory" -WarningAction SilentlyContinue

$AddArguments = @{}
if ($Credential){$AddArguments.Credential = $Credential}
if ($Server){$AddArguments.Server = $Server}

$passwd = if ($passwd){$passwd} else {Get-Passwd}
$ssrting = $(ConvertTo-SecureString $passwd -AsPlainText -Force)

$user = New-ADUser -Name $UserName -Accountpassword $ssrting -Enabled $True @AddArguments -PassThru;

if ($user) {
    Write-Host "[!] Success, user created: $($user.SamAccountName) '$passwd'" -ForegroundColor Green;
    if ($groupname){
        $group = Add-ADGroupMember -Identity $groupname -Members $UserName @AddArguments -PassThru;
        if ($group) {Write-Host "[!] Success, target user added to group '$($group.SamAccountName)'" -ForegroundColor Green;}
    }
    
}
Write-Host