$parent = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scripts = (Get-ChildItem $parent -Filter "*.ps1").FullName
foreach($script in $scripts){
    Invoke-Expression (Get-Content $script -Raw)
}
$Script:TestConfig = Get-Content "${PSScriptRoot}\TestConfiguration.json" | ConvertFrom-Json