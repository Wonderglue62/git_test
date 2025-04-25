# Import the Active Directory module 
Import-Module ActiveDirectory

# Path to the input CSV file
$inputCsvPath = "C:\temp\getad.csv"

# Path to the output CSV file
$outputCsvPath = "C:\temp\gotad.csv"

# Read the input CSV file
$accounts = Import-Csv -Path $inputCsvPath

# Create an array to store the output data
$outputData = @()

# Iterate over each account in the input CSV
foreach ($account in $accounts) {
    $displayName = $account.displayName

    # Verify that the displayName is not null or empty
    if ([string]::IsNullOrEmpty($displayName)) {
        Write-Host "displayName is missing for an entry in the CSV file"
        continue
    }

    try {
        # Get the user information from Active Directory using -Filter with properly quoted string
        $user = Get-ADUser -Filter "Display Name -eq '$displayName'" -Properties samAccountName | Select samAccountName

        if ($user) {
            # Create a custom object with the SAM account name and email address
            $outputObject = [PSCustomObject]@{
                displayName = $displayName
                samAccountName = $samAccountName
            }

            # Add the custom object to the output data array
            $outputData += $outputObject
        } else {
            Write-Host "User not found: $displayName"
        }
    } catch {
        # Output the error message
        Write-Host "Error retrieving user: $displayName"
        Write-Host "Error details: $_"
    }
}

# Export the output data to a new CSV file
$outputData | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Usernames have been exported to $outputCsvPath"
