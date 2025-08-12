#
# Andreas Larsson 2024
#
# Basic script to search AD for a user on via current maching.
# The string entered is matched against properties sAMAccountName or userprincipalname.
#
# Usage:
# Supply the username via argument or enter it in the prompt.
# Add the "-details" flag to show ALL properties.
#
# Example uses in a powershell window:
#
# ./ad-user-show-details.ps1 someusername
# ./ad-user-show-details.ps1 someemail
#
# or
#
# ./ad-user-show-details.ps1 someusername -details
#


param (
    [Parameter(Mandatory=$false)]
    [string]$User,
    [Parameter(Mandatory=$false)]
    [switch]$Details
)

$wasPrompted = $false
if (-not $User) {
    $User = Read-Host -Prompt 'Type Username'
    $wasPrompted = $true
}

$searcher = [adsisearcher]""
$searcher.Filter = "(|(&(objectClass=user)(sAMAccountName=$User))(&(objectClass=user)(userprincipalname=$User)))"
$searchResults = $searcher.FindAll()

$allowedProperties = @("distinguishedname", "department", "displayname", "mail", "memberof", "samaccontname")

foreach ($result in $searchResults) {
    $sortedPropertyNames = $result.Properties.PropertyNames | Sort-Object
    foreach ($propertyName in $sortedPropertyNames) {
        if ($Details -or $propertyName -in $allowedProperties) {
           $propertyValue = $result.Properties[$propertyName]
           if ($propertyValue -is [System.Collections.ICollection] -and $propertyValue.Count -gt 1) {
                $itemCount = $propertyValue.Count
                Write-Host "$propertyName (Total: $itemCount)"
                foreach ($value in $propertyValue) {
                    Write-Host "  - $value"
                }
           } else {
              $singleValue = $propertyValue[0]
              Write-Host "$propertyName : $singleValue"
           }
        }
    }
}

if ($wasPrompted) {
    pause
}
