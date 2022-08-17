# IntuneFirewallRulesMigration
Intune firewall rules migration tool upgraded to PS 7 and the new Graph API cmdlets

# Important

To use these scripts, you must:
- Install and use PowerShell 7 (https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
- Install the modules Microsoft.Graph.Authentication and Az.Accounts
- The script must be run as administrator (it uses the appx package which needs admin)
- For the rules import, you must manually run Connect-MgGraph to connect to a tenant in the same PowerShell session in which you will be running this script
- For the rules import, the account used to connect to graph API must have sufficient permission to create firewall profiles. From what I can see there is no built-in role that has the required permission (DeviceManagementConfiguration.ReadWrite.All), therefore I recommend you create a service principal (aka app registration) with this permission and log on as the service principal.

The export outputs empty rules. These should be removed before importing.

# Exporting firewall rules

```
Export-FirewallRules.ps1 -OperationMode Export <-includeLocalRules> -RulesFile 'C:\tmp\file-to-dump-the-rules.json'
```

# Importing firewall rules

```
Export-FirewallRules.ps1 -OperationMode Import -RulesFile 'C:\tmp\file-with-the-dumped-rules.json' -TargetCloud <usgov/german/china/global>
```

# Logging on to graph using a service principal:

```
$tenant = '<tenant id here>'
$appid = '<app id here>'
$secret = '<secret value here>'
$sec = $secret | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $appid,$sec
Connect-AzAccount -Environment <sovereign cloud name or omit this parameter if you are connecting to global cloud> -ServicePrincipal -TenantId $tenant -Credential $credential
$token = (Get-AzAccessToken -ResourceTypeName MSGraph).Token
Connect-MgGraph -Environment <sovereign cloud name or omit this parameter if you are connecting to global cloud> -AccessToken $token
```
