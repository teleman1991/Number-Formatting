# Source the main script functions (assuming they're in the same directory)
$mainScriptPath = Join-Path $PSScriptRoot "Format-PhoneNumbers.ps1"

# Create a function to test phone number formatting
function Test-PhoneNumberFormat {
    param(
        [string]$inputNumber,
        [string]$expectedOutput
    )
    
    $result = Format-PhoneNumber -phoneNumber $inputNumber
    
    if ($result -eq $expectedOutput) {
        Write-Host "✓ PASS: '$inputNumber' -> '$result'" -ForegroundColor Green
        return $true
    } else {
        Write-Host "× FAIL: '$inputNumber' -> '$result' (Expected: '$expectedOutput')" -ForegroundColor Red
        return $false
    }
}

# Array of test cases
$testCases = @(
    @{ Input = "9725555555"; Expected = "+1 (972) 555-5555" },
    @{ Input = "19725555555"; Expected = "+1 (972) 555-5555" },
    @{ Input = "972-555-5555"; Expected = "+1 (972) 555-5555" },
    @{ Input = "(972) 555-5555"; Expected = "+1 (972) 555-5555" },
    @{ Input = "5555555555#9967"; Expected = "+1 (555) 555-5555 #9967" },
    @{ Input = "15555555555#9967"; Expected = "+1 (555) 555-5555 #9967" },
    @{ Input = "(555) 555-5555 #9967"; Expected = "+1 (555) 555-5555 #9967" },
    @{ Input = "555-555-5555#9967"; Expected = "+1 (555) 555-5555 #9967" },
    # Invalid number tests
    @{ Input = "123456"; Expected = "123456" },
    @{ Input = ""; Expected = $null },
    @{ Input = "972555555"; Expected = "972555555" }
)

# Run tests
$totalTests = $testCases.Count
$passedTests = 0

Write-Host "Starting phone number format tests..."
Write-Host "----------------------------------------"

foreach ($test in $testCases) {
    if (Test-PhoneNumberFormat -inputNumber $test.Input -expectedOutput $test.Expected) {
        $passedTests++
    }
}

Write-Host "----------------------------------------"
Write-Host "Test Summary:"
Write-Host "Total Tests: $totalTests"
Write-Host "Passed: $passedTests"
Write-Host "Failed: $($totalTests - $passedTests)"

if ($passedTests -eq $totalTests) {
    Write-Host "All tests passed!" -ForegroundColor Green
} else {
    Write-Host "Some tests failed!" -ForegroundColor Red
}
