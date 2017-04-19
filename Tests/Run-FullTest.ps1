$VerbosePreference = 'Continue'
$Tests  = @(Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude "*FullTest*", "TestInitialize*" -ErrorAction SilentlyContinue)

foreach ($test in $Tests) {
    try {
        . ($test.FullName)
    } catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}