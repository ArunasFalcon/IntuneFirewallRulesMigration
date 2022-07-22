# IntuneFirewallRulesMigration
Intune firewall rules migration tool upgraded to PS 7 and the new Graph API cmdlets

# Important

To use these scripts, you must:
- Install and use PowerShell 7 (https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
- Install the modules Microsoft.Graph.Authentication and Az.Accounts
- For the rules export, the script must be run as administrator
- For the rules import, you must manually run Connect-MgGraph to connect to a tenant in the same PowerShell session in which you will be running this script
- For the rules import, the account used to connect to graph API must have sufficient permission to create firewall profiles

The export outputs empty rules. These should be removed before importing.

# Exporting firewall rules

Export-FirewallRules.ps1 -OperationMode Export -includeLocalRules <$true/$false> -RulesFile 'C:\tmp\file-to-dump-the-rules.json'

# Importing firewall rules

Export-FirewallRules.ps1 -OperationMode Import -RulesFile 'C:\tmp\file-with-the-dumped-rules.json' -TargetCloud <usgov/german/china/global>
