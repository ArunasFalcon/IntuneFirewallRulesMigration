
param([switch]$includeDisabledRules, [switch]$includeLocalRules, [string]$RulesFile, [ValidateSet("Export","Import")]$OperationMode, [ValidateSet('usgov','german','china','global')]$TargetCloud)

$ErrorActionPreference = 'Stop'

Import-Module Appx -UseWindowsPowerShell

if (-not $RulesFile) { exit 1 }
if (-not $OperationMode) { exit 1 }

if ((-not $TargetCloud) -or ($TargetCloud -eq 'global'))
{
    $region = 'global'
}
else
{
    $region = $TargetCloud
}
$graphEndpointUri = (Get-MgEnvironment | Where-Object { $_.Name -like "*$region*" }).GraphEndpoint
if (-not $graphEndpointUri) { exit 1 }
Write-Host "Regional graph api endpoint: $graphEndpointUri"

<#
  ## check for elevation   
   $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
   $principal = New-Object Security.Principal.WindowsPrincipal $identity
  
   if (!$principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))  {
    Write-Host -ForegroundColor Red "Error:  Must run elevated: run as administrator"
    Write-Host "No commands completed"
    return
   }

#----------------------------------------------------------------------------------------------C:\Users\t-oktess\Documents\powershellproject
if(-not(Test-Path ".\Intune-PowerShell-Management.zip")){
    #Download a zip file which has other required files from the public repo on github
    Invoke-WebRequest -Uri "https://github.com/microsoft/Intune-PowerShell-Management/archive/master.zip" -OutFile ".\Intune-PowerShell-Management.zip"

    #Unblock the files especially since they are download from the internet
    Get-ChildItem ".\Intune-PowerShell-Management.zip" -Recurse -Force | Unblock-File

    #Unzip the files into the current direectory
    Expand-Archive -LiteralPath ".\Intune-PowerShell-Management.zip" -DestinationPath ".\"
}
#----------------------------------------------------------------------------------------------
#>

## check for running from correct folder location

Import-Module ".\FirewallRulesMigration.psm1"
. ".\IntuneFirewallRulesMigration\Private\Strings.ps1"

$EnabledOnly = $true

try
{
    if($includeLocalRules)
    {
        Export-NetFirewallRule -RulesFile $RulesFile -GraphEndpointUri $graphEndpointUri -OperationMode $OperationMode -EnabledOnly:$EnabledOnly -PolicyStoreSource "All"
    }
    else
    {
        Export-NetFirewallRule -RulesFile $RulesFile -GraphEndpointUri $graphEndpointUri -OperationMode $OperationMode -EnabledOnly:$EnabledOnly
    }
}  
catch{
    $errorMessage = $_.ToString()
    Write-Host -ForegroundColor Red $errorMessage
    Write-Host "No commands completed"
}

    
                           