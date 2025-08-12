param (
    [Parameter(Mandatory=$false)]
    [string]$Group,
    [Parameter(Mandatory=$false)]
    [switch]$Details    
)

$wasPrompted = $false
if (-not $Group) {
    $Group = Read-Host -Prompt 'Type Group'
    $wasPrompted = $true
}

$searcher = [adsisearcher]""
$searcher.Filter = "(&(objectClass=group)(cn=$Group))"
$searchResults = $searcher.FindAll()

$allowedProperties = @("distinguishedname", "member", "memberof")

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
