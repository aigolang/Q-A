# Title: Creat a Dynamic Distribution Group based on an Organizational Unit and UserMailbox type.
# Author: aigolang
# Date: 2024-02-19
# Note:
# 1 We need to use OrganizationalUnit ID for the variable “$saveToOU” and “$basedOU”, DO NOT use the OU identity format like “test1.lab/IT” or “OU=IT,DC=test1,DC=lab”.
# 2 To get members of the DDG, we need to use 2 parameter “-RecipientPreviewFilter” and “-OrganizationalUnit”, like:
## Get-Recipient -RecipientPreviewFilter $DDG.RecipientFilter -OrganizationalUnit ($DDG.RecipientContainer)
# 3 In the sample cmdlet “New-DynamicDistributionGroup”, we can see that the “RecipientFilter” is using “(RecipientTypeDetails -eq 'UserMailbox')”, which is just getting UserMailbox in the $basedOU, you can update the conditions as your requirements.

Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn 

function Get-DynamicDistributionGroupMember {
    param(
    [Parameter(Mandatory=$true)]
    $Identity
    )
    $group = Get-DynamicDistributionGroup -Identity $Identity
    Get-Recipient -RecipientPreviewFilter $group.RecipientFilter -OrganizationalUnit ($group.RecipientContainer) 
} 

## Customize >>>
$DDG_BasedOU1 = "DDG_BasedOU1"
$saveToOU = "6728939xxxxxx"
$basedOU = "2d5b765xxxxxx"
## We can use Get-OrganizationalUnit to get the OU GUID.
## Customize <<<

# Create DDG based on OU, all members should be the UserMailbox type in the specific OU.
New-DynamicDistributionGroup -Name $DDG_BasedOU1 -Alias $DDG_BasedOU1 -OrganizationalUnit $saveToOU -RecipientFilter {((Alias -ne $null) -and `
    ((RecipientTypeDetails -eq 'UserMailbox'))-and (-not(Name -like 'SystemMailbox{*')) -and `
    (-not(Name -like 'CAS_{*')) -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and `
    (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'PublicFolderMailbox')) -and `
    (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'AuditLogMailbox')) -and `
    (-not(RecipientTypeDetailsValue -eq 'AuxAuditLogMailbox')) -and (-not(RecipientTypeDetailsValue -eq 'SupervisoryReviewPolicyMailbox')))} `
    -RecipientContainer $basedOU

$DDG = Get-DynamicDistributionGroup -Identity $DDG_BasedOU1
Get-Recipient -RecipientPreviewFilter $DDG.RecipientFilter -OrganizationalUnit ($DDG.RecipientContainer)
