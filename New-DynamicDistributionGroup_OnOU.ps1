# Title: Creat a Dynamic Distribution Group based on an Organizational Unit and UserMailbox type.
# Author: aigolang
# Date: 2024-02-19

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
$newDDGName = "DDG7"
$saveToOU = "OU=IT,DC=test1,DC=lab"
$fromOU = "OU=IT,DC=test1,DC=lab"
$fromOUValue = "test1.lab/IT"
## Customize <<<

# Get all mailboxes based on a specific OU
$mbList = Get-Mailbox -OrganizationalUnit $fromOU -ResultSize Unlimited | Where {$_.OrganizationalUnit -eq $fromOUValue}

# Initialize the filter with the first mailbox
$recipientFilter = "(Alias -eq '$($mbList[0])')"  

# Append the rest of the mailbox alias or UserPrincipalName to the filter
for ($i = 1; $i -lt $mbxList.Count; $i++) {
    $recipientFilter += " -or (Alias -eq '$($mbList[$i])')"
}

# Check the members before creating a DDG.
$testMembers = Get-Recipient -RecipientPreviewFilter $recipientFilter
$testMembers
Write-Host "Get-Recipient with the RecipientFilter count: $($testMembers.Count)" -ForegroundColor Cyan

# Create a DDG based on the RecipientFilter object
New-DynamicDistributionGroup -Name $newDDGName -Alias $newDDGName -OrganizationalUnit $saveToOU -RecipientFilter $recipientFilter 

Get-DynamicDistributionGroupMember -Identity DDG7
