. "$PSScriptRoot\ConvertTo-IntuneFirewallRule.ps1"
. "$PSScriptRoot\Get-SampleFirewallData.ps1"
. "$PSScriptRoot\..\Private\Strings.ps1"

function Export-NetFirewallRule {
    <#
    .SYNOPSIS
    Exports network firewall rules found on this host into Intune firewall rules.

    .DESCRIPTION
    Export-NetFirewallRule will export all network firewall rules found on the host and convert them into an
    intermediate IntuneFirewallRule object

    .EXAMPLE
    Export-NetFirewallRule
    Export-NetFirewallRule -PolicyStoreSource GroupPolicy
    Export-NetFirewallRule -PolicyStoreSource All
    Export-NetFirewallRule -splitConflictingAttributes -sendExportTelemetry

    .NOTES
    Export-NetFirewallRule is a wrapper for the cmdlet call to Get-NetFirewallRule piped to ConvertTo-IntuneFirewallRule.

    If -splitConflictingAttributes is toggled, then firewall rules with multiple attributes of filePath, serviceName,
    or packageFamilyName will automatically be processed and split instead of prompting users to split the firewall rule

    If -sendExportTelemetry is toggled, then error messages encountered will automatically be sent to Microsoft and the
    tool will continue processing net firewall rules.

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallrule?view=win10-ps#description

    .OUTPUTS
    IntuneFirewallRule[]

    A stream of exported firewall rules represented via the intermediate IntuneFirewallRule class
    #>
    [CmdletBinding()]
    Param(
        # Defines the policy store source to pull net firewall rules from.
        [ValidateSet("GroupPolicy", "All")]
        [string] $PolicyStoreSource = "GroupPolicy",
        # If this switch is toggled, only the firewall rules that are currently enabled are imported 
        [boolean]
        $EnabledOnly =$True,
        # This determines if we are running a test version or a full importation. The default value is full. The test version imports only 20 rules
        [ValidateSet("Full","Test")]
        [String]
        $Mode = "Full",
        [switch] $doNotsplitConflictingAttributes,
        # If this flag is toggled, then telemetry is automatically sent to Microsoft.
        [switch] $sendExportTelemetry,
        # If this flag is toogled, then firewall rules would be imported to Device Configuration else it would be import to Endpoint Security
        [Switch]
        $DeviceConfiguration,
        [string]
        $RulesFile,
        [ValidateSet("Export","Import")]$OperationMode,
        [string]$GraphEndpointUri

         
    )

        $sendExportTelemetry = $False

        
            # The default behavior for Get-NetFirewallRule is to retrieve all WDFWAS firewall rules
            #Get-FirewallData -Enabled:$EnabledOnly -Mode:$Mode -PolicyStoreSource:$PolicyStoreSource
            #$rules = Get-Content -Path $RulesFile | ConvertFrom-Json

        if ($OperationMode -eq 'Export')
        {
            $localfwdata = Get-FirewallData -Enabled:$EnabledOnly -Mode:$Mode -PolicyStoreSource:$PolicyStoreSource
            $count = $localfwdata.length
            Write-Host "Found $count rules"
            if (-not $count) { exit 1 }
            $intunefwrules = $localfwdata | ConvertTo-IntuneFirewallRule `
                -doNotsplitConflictingAttributes:$doNotsplitConflictingAttributes `
                -sendConvertTelemetry:$sendExportTelemetry `
                -DeviceConfiguration:$DeviceConfiguration
            $intunefwrules| ConvertTo-Json -Depth 20 | Set-Content -Path $RulesFile -Encoding utf8
        }
        else
        {
            return $(Get-Content -Path $RulesFile | ConvertFrom-Json | Send-IntuneFirewallRulesPolicy `
            -sendIntuneFirewallTelemetry:$sendExportTelemetry `
            -DeviceConfiguration:$DeviceConfiguration `
            -GraphEndpointUri $GraphEndpointUri
            )
        }
        
}