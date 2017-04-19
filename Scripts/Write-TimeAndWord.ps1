function Write-TimeAndWord ([string] $word) {
    $date1 = Get-Date
    if($word -eq "Hello"){ $date2 = Get-Date }
    $word + " at " + $date1 | Out-Host
}