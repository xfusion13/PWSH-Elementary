function Invoke-SaveCreds {
    param(
        [string]$Path, 
        [string]$Record
    )
    if(!(Select-String -Path $Path -Pattern $Record -SimpleMatch -Quiet)){
        (Get-Content -Path $Path).Count.ToString() + " " + $Record >> $Path
    }
}

function Invoke-ChangeCreds {
    param (
        [string]$FullName, 
        [string]$Passwd
    )
    $sec = if ($Passwd){ConvertTo-SecureString $Passwd -AsPlainText -Force} else {New-Object System.Security.SecureString};
    $global:creds = New-Object System.Management.Automation.PSCredential ($FullName, $sec);
    if ($creds){Write-Host "[!] Global variable `$creds updated: [$($creds.username):$Passwd]" -ForegroundColor Green;}
    return $creds
}

function New-PSDefParameters {
    param (
        [Parameter(Position = 0, HelpMessage="Domain Controller")][string]$FullName, 
        [Parameter(Position = 1)][string]$Passwd,
        [Parameter(Position = 2)][string]$Server
    )

    $Modules = @("ActiveDirectory")
    $Cmdlets = @("New-PSDrive", "Get-ObjectAcl", "Get-DomainObject")

    $DefaultParameterValues = @{}
    $crd = Invoke-ChangeCreds -FullName $FullName -Passwd $Passwd;
    if (!$crd){return} # output
    foreach ($Module in $Modules){
        foreach ($CommandName in (Get-Command -Module $Module).Name) {
            $DefaultParameterValues.Add("$($CommandName):Server", $Server)
            $DefaultParameterValues.Add("$($CommandName):Credential", $crd)
        }
    }
    foreach ($Cmdlet in $Cmdlets) {
        $DefaultParameterValues.Add("$($Cmdlet):Server", $Server)
        $DefaultParameterValues.Add("$($Cmdlet):Credential", $crd)
    }
    return $DefaultParameterValues

}

function Get-Passwd {
    $uppercase = "ABCDEFGHKLMNOPRSTUVWXYZ".tochararray()
    $lowercase = "abcdefghiklmnoprstuvwxyz".tochararray()
    $number    = "0123456789".tochararray()
    $special   = "$%&/()=?}{@#*+!-".tochararray()

    $password =  ($uppercase | Get-Random -count 2) -join ''
    $password += ($lowercase | Get-Random -count 5) -join ''
    $password += ($number    | Get-Random -count 3) -join ''
    $password += ($special   | Get-Random -count 2) -join ''

    return (($password.tochararray() | Get-Random -Count 12) -join '')
}

Export-ModuleMember -Function *