param (
    [string] $Server,
    [PSCredential] $Credential,
    [string] $Folder = $(Get-Location),
    [switch] $Help
)
function Invoke-HelpMessage{
    Write-Host "`nCollect some information (Users, Computers, Policies) about target domain"
    Write-Host "and export to csv file for further export to Excel.`n"

    Write-Host "-s [-Server]     Domain Controller IP or FQDN"
    Write-Host "-c [-Credential] Credential"
    Write-Host "-f [-Folder]     Loot folder`n"
}

if($Help) {Invoke-HelpMessage; return}

$upath = $($Folder + "\users.csv")
$mpath = $($Folder + "\machines.csv")
$ppath = $($Folder + "\policy.csv")

$AddArguments = @{}
if ($Credential){$AddArguments.Credential = $Credential}
if ($Server){$AddArguments.Server = $Server}

$userinfo = Get-ADUser -Filter * -Properties * @AddArguments `
| Select-Object `
Enabled, adminCount,SamAccountName, EmailAddress, Department, Description, DisplayName, objectSid, DistinguishedName,`
DoesNotRequirePreAuth, PasswordNotRequired, PasswordExpired, whenCreated,AccountExpirationDate,PasswordLastSet, LastLogonDate,`
AccountNotDelegated, AllowReversiblePasswordEncryption,AuthenticationPolicy, AuthenticationPolicySilo, PrimaryGroup

if ($userinfo) {
    $userinfo | Export-CSV $upath -NoTypeInformation -Encoding UTF8;
    Write-Host "[!] Success, domain users accounts collected." -ForegroundColor Green;
    Write-Host "    - saved to $upath" -ForegroundColor Green;
}

$compinfo =  Get-ADComputer -Filter * -Properties * @AddArguments `
| Select-Object `
Enabled, adminCount, SamAccountName, DNSHostName, IPv4Address, OperatingSystem, OperatingSystemVersion, Description,`
objectSid, DistinguishedName,`DoesNotRequirePreAuth, PasswordNotRequired, whenCreated, PasswordLastSet, LastLogonDate,`
AccountNotDelegated, AuthenticationPolicy, AuthenticationPolicySilo, PrimaryGroup `

if ($compinfo) {
    $compinfo | Export-CSV $mpath -NoTypeInformation -Encoding UTF8;
    Write-Host "[!] Success, domain machines accounts collected." -ForegroundColor Green;
    Write-Host "    - saved to $mpath" -ForegroundColor Green;
}

$policyinfo = Get-ADDefaultDomainPasswordPolicy @AddArguments `
| Select-Object `
Name, LockoutThreshold, LockoutDuration, LockoutObservationWindow, ComplexityEnabled, MinPasswordLength, MinPasswordAge, MaxPasswordAge, 
PasswordHistoryCount, ReversibleEncryptionEnabled, DistinguishedName, AppliesTo

$finepolicyinfo = Get-ADFineGrainedPasswordPolicy -Filter * @AddArguments `
| Select-Object `
Name, LockoutThreshold, LockoutDuration, LockoutObservationWindow, ComplexityEnabled, MinPasswordLength, MinPasswordAge, MaxPasswordAge, 
PasswordHistoryCount, ReversibleEncryptionEnabled, DistinguishedName, AppliesTo

if($policyinfo){
    $policyinfo.Name = "DefaultDomainPolicy"
    $policyinfo, $finepolicyinfo | Export-CSV $ppath -NoTypeInformation -Encoding UTF8;
    Write-Host "[!] Success, domain policy collected." -ForegroundColor Green;
    Write-Host "    - saved to $ppath" -ForegroundColor Green;
}
Write-Host