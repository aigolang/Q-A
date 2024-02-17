### Issue
"One or more errors occurred." when running a MG cmdlet, like Get-MgUser or Get-MgSubscribedSKU.

``` PowerShell {.line-numbers}
PS C:\> Get-MgUser
Get-MgUser: One or more errors occurred.
At line:1 char:1
+Get-MgUser+~~~~~~~~~~
    +CategoryInfo          : NotSpecified: (:)[Get-MgUser_List],AggregateException
    +FullyQualifiedErrorId : System.AggregateException,Microsoft.Graph.PowerShell.Cmdlets.GetMgUser_List
```

### Resolution
The root of the issue is we’ve installed two versions of Microsoft Graph Authentication PowerShell SDK module, and these modules are conflict. You can check it on your machine using Get-Module cmdlet.

##### Step1:
```PowerShell
PS C:\> Get-Module | select Name, Version, ModuleType

Name                            Version ModuleType
----                            ------- ----------
Microsoft.Graph.Authentication  2.6.1       Script
Microsoft.Graph.Authentication  2.5.0       Script
Microsoft.PowerShell.Management 3.1.0.0   Manifest
Microsoft.PowerShell.Utility    3.1.0.0   Manifest
PackageManagement               1.4.8.1     Script
PowerShellGet                   2.2.5       Script
PSReadLine                      2.0.0       Script
```
When we check the imported modules in the current session. <font color=#DC143C>We saw two versions of the module Microsoft.Graph.Authentication are imported.</font>

##### Step2:
We need to remove all installed versions of the module then install the latest one. 
But uninstalling the Microsoft Graph module is a little bit complicated, because the Microsoft.Graph.Authentication module is the dependency of other Microsoft.Graph modules. We need to uninstall Microsoft.Graph modules except Microsoft.Graph.Authentication module.

<b>We need to use this script to re-install the Microsoft.Graph modules.</b>

```PowerShell {.line-numbers}
# Save this script as a file name "Reinstall-MsGraphModules_v1.ps1".
#Required running with elevated right.
if (-not([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
   Write-Warning "You need to have Administrator rights to run this script!`nPlease re-run this script as an Administrator in an elevated powershell prompt!"
   break
}

#Uninstall Microsoft.Graph modules except Microsoft.Graph.Authentication
$Modules = Get-Module Microsoft.Graph* -ListAvailable | 
Where-Object {$_.Name -ne "Microsoft.Graph.Authentication"} | Select-Object Name -Unique

Foreach ($Module in $Modules){
  $ModuleName = $Module.Name
  $Versions = Get-Module $ModuleName -ListAvailable
  Foreach ($Version in $Versions){
    $ModuleVersion = $Version.Version
    Write-Host "Uninstall-Module $ModuleName $ModuleVersion" -ForegroundColor Cyan
    Uninstall-Module $ModuleName -RequiredVersion $ModuleVersion -ErrorAction SilentlyContinue
  }
}

#Fix installed modules
$InstalledModules = Get-InstalledModule Microsoft.Graph* | 
Where-Object {$_.Name -ne "Microsoft.Graph.Authentication"} | Select-Object Name -Unique

Foreach ($InstalledModule in $InstalledModules){
  $InstalledModuleName = $InstalledModule.Name
  $InstalledVersions = Get-Module $InstalledModuleName -ListAvailable
  Foreach ($InstalledVersion in $InstalledVersions){
    $InstalledModuleVersion = $InstalledVersion.Version
    Write-Host "Uninstall-Module $InstalledModuleName $InstalledModuleVersion" -ForegroundColor Cyan
    Uninstall-Module $InstalledModuleName -RequiredVersion $InstalledModuleVersion -ErrorAction SilentlyContinue
  }
}

#Uninstall Microsoft.Graph.Authentication
$ModuleName = "Microsoft.Graph.Authentication"
$Versions = Get-Module $ModuleName -ListAvailable

Foreach ($Version in $Versions){
  $ModuleVersion = $Version.Version
  Write-Host "Uninstall-Module $ModuleName $ModuleVersion" -ForegroundColor Cyan
  Uninstall-Module $ModuleName -RequiredVersion $ModuleVersion
}

Write-Host "`nInstalling the Microsoft Graph PowerShell module..." -ForegroundColor Yellow
Install-Module Microsoft.Graph -Force
#Install-Module Microsoft.Graph.Beta -Force
Write-Host "Reinstall Microsoft.Graph modules Done." -ForegroundColor Green
```
