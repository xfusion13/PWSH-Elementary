param (
    [string] $Server,
    [string] $Domain,
    [string] $UserName, 
    [string] $Passwd,
    [int] $Choice,
    [switch] $List,
    [switch] $Flush,
    [switch] $Admin,
    [switch] $Help,
    [switch] $x
)
function Invoke-HelpMessage{
    Write-Host "`nChange default parameters (-Server, -Credential) by `$PSDefaultParameterValues"
    Write-Host "for ActiveDirectory (RSAT) module and some another commandlets."
    Write-Host "Add another modules or cmdlets possible in utils.psm1"
    Write-Host "Also, set global variable `$creds.`n"
    Write-Host "Expected, module ActiveDirectory installed,"
    Write-Host "else you can install with"
    Write-Host "`"Add-WindowsCapability -online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`"`n"
    Write-Host "History presets file: $MemoryFile`n"

    Write-Host "-s [-Server]   Domain Controller IP or FQDN"
    Write-Host "-u [-UserName] Target domain account"
    Write-Host "-p [-Passwd]   Target password"
    Write-Host "-l [-List]     List history all presets used before"
    Write-Host "-c [-Choice]   Select preset used before"
    Write-Host "-f [-Flush]    Flush history all presets used before"
    Write-Host "-a [-Admin]    Mark new preset as most privileged"
    Write-Host "-x [-x]        Add PSDrive Active Directory (AD)"
    Write-Host "-h [-Help]     Print help message`n"
}

function Invoke-ChangePSDefParameters {
    param (
        [Parameter(Position = 0)][string]$FullName, 
        [Parameter(Position = 1)][string]$Passwd,
        [Parameter(Position = 2)][string]$Server
    )
    $DefaultParameterValues = New-PSDefParameters $FullName $Passwd $Server

    $PSDefaultParameterValues.Clear()
    foreach($key in $DefaultParameterValues.Keys){
        $PSDefaultParameterValues.Add($key, $DefaultParameterValues[$key])
    }
    if (!$PSDefaultParameterValues){Write-Host "[E] Default params not updated:" -ForegroundColor Red; return}
        
    Write-Host "[!] Default params updated:" -ForegroundColor Green;
    Write-Host "    - Server:     $Server" -ForegroundColor Green;
    Write-Host "    - Credential: $($creds.username)" -ForegroundColor Green;
    
    if($x) {
        if((Get-PSDrive).Name -contains "AD"){Remove-PSDrive -Name "AD"}
        if(New-PSDrive -PSProvider ActiveDirectory -Name AD -Root "" -Scope Global){
            Write-Host "[!] Global PSDrive ActiveDirectory updated: [AD]" -ForegroundColor Green;
        }
    }
    Write-Host
}

$MemoryFile = ($env:USERPROFILE + "\.psenv.txt")
if($Help) {Invoke-HelpMessage; return}
if (!(Test-Path -Path $MemoryFile)){New-Item -ItemType file -Path $MemoryFile}

if ($List){
    $lines = @(Get-Content -Path $MemoryFile)
    foreach ($line in $lines) {
        $color = if (($line -split ' ')[-1] -eq 'A'){"Red"} else {"Blue"}
        Write-Host $line -ForegroundColor $color
    }
    Write-Host
    return
}
elseif ($Flush){
    Clear-Content -Path $MemoryFile;
    Write-Host "[!] History presets file cleared!`n" -ForegroundColor Yellow;
    return
}

$PathToUtils = ($MyInvocation.MyCommand.Path | Split-Path -parent) + "\utils.psm1"
Import-Module $PathToUtils, "ActiveDirectory" -WarningAction SilentlyContinue

if($PSBoundParameters.ContainsKey('Choice')){
    $MemoryContent = @(Get-Content -Path $MemoryFile)
    if ($MemoryContent.count -gt $Choice){
        $record = $MemoryContent[$Choice] -split ' '
        Invoke-ChangePSDefParameters $record[1] $record[2] $record[3]
    }
    else {
        Write-Host "[Error] Please enter correct value.`n" -ForegroundColor Red;
    }
}
elseif($UserName) {
    $fname  = if (!$domain){$UserName} else {$($Domain+"\"+$UserName)};
    Invoke-ChangePSDefParameters $fname $Passwd $Server
    $record = $fname + ' ' + $Passwd + ' ' + $Server + ' '
    if ($Admin) {$record += " A"};
    Invoke-SaveCreds -Path $MemoryFile -Record $record;
}
else {
    Write-Host "[Error] Please enter a target username." -ForegroundColor Red;
}