# Import required module
Connect-AzureAD

# Function to format phone numbers
function Format-PhoneNumber {
    param (
        [string]$phoneNumber
    )
    
    if ([string]::IsNullOrWhiteSpace($phoneNumber)) {
        return $null
    }

    # Remove all non-numeric characters except #
    $cleaned = $phoneNumber -replace '[^\d#]', ''
    
    # Check if number has extension
    if ($cleaned -match '#') {
        $parts = $cleaned -split '#'
        $number = $parts[0]
        $extension = $parts[1]
        
        # Ensure we have 10 digits for the main number
        if ($number.Length -eq 10) {
            $number = "+1 ({0}) {1}-{2}" -f $number.Substring(0,3), $number.Substring(3,3), $number.Substring(6,4)
            return "$number #$extension"
        }
        elseif ($number.Length -eq 11 -and $number.StartsWith("1")) {
            $number = "+1 ({0}) {1}-{2}" -f $number.Substring(1,3), $number.Substring(4,3), $number.Substring(7,4)
            return "$number #$extension"
        }
    }
    else {
        # Handle regular phone numbers
        if ($cleaned.Length -eq 10) {
            return "+1 ({0}) {1}-{2}" -f $cleaned.Substring(0,3), $cleaned.Substring(3,3), $cleaned.Substring(6,4)
        }
        elseif ($cleaned.Length -eq 11 -and $cleaned.StartsWith("1")) {
            return "+1 ({0}) {1}-{2}" -f $cleaned.Substring(1,3), $cleaned.Substring(4,3), $cleaned.Substring(7,4)
        }
    }
    
    Write-Warning "Invalid phone number format: $phoneNumber"
    return $phoneNumber
}

# Get all users
try {
    $users = Get-AzureADUser -All $true
    
    foreach ($user in $users) {
        $mobileUpdated = $false
        $businessUpdated = $false
        
        # Format Mobile Phone
        if ($user.Mobile) {
            $formattedMobile = Format-PhoneNumber -phoneNumber $user.Mobile
            if ($formattedMobile -ne $user.Mobile) {
                try {
                    Set-AzureADUser -ObjectId $user.ObjectId -Mobile $formattedMobile
                    $mobileUpdated = $true
                }
                catch {
                    Write-Error "Failed to update mobile number for user: $($user.UserPrincipalName). Error: $_"
                }
            }
        }
        
        # Format Business Phone
        if ($user.TelephoneNumber) {
            $formattedBusiness = Format-PhoneNumber -phoneNumber $user.TelephoneNumber
            if ($formattedBusiness -ne $user.TelephoneNumber) {
                try {
                    Set-AzureADUser -ObjectId $user.ObjectId -TelephoneNumber $formattedBusiness
                    $businessUpdated = $true
                }
                catch {
                    Write-Error "Failed to update business number for user: $($user.UserPrincipalName). Error: $_"
                }
            }
        }
        
        # Log updates
        if ($mobileUpdated -or $businessUpdated) {
            Write-Host "Updated phone numbers for $($user.UserPrincipalName)"
            if ($mobileUpdated) { Write-Host "`tMobile: $($user.Mobile) -> $formattedMobile" }
            if ($businessUpdated) { Write-Host "`tBusiness: $($user.TelephoneNumber) -> $formattedBusiness" }
        }
    }
}
catch {
    Write-Error "Failed to retrieve users from Azure AD. Error: $_"
}

Write-Host "Phone number formatting complete!"