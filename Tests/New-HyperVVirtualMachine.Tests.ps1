$parent = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$parent\Scripts\$sut"
. "$parent\Scripts\Remove-HyperVVirtualMachine.ps1"
$TestConfig = Get-Content .\testData.json | ConvertFrom-Json
$PSDefaultParameterValues = @{
    "New-HyperVVirtualMachine:VMNames" = $TestConfig.VMNames.VMName
    "New-HyperVVirtualMachine:VHDXSourcePath" = $TestConfig.VHDXSourcePath
    "Remove-HyperVVirtualMachine:VMNames" = $TestConfig.VMNames.VMName
}

Describe "New-HyperVVirtualMachine" {
    Context "Run function nomally" {
        It "shold return null for creating VMs successfully" {
            Remove-HyperVVirtualMachine
            New-HyperVVirtualMachine | Should BeNullOrEmpty
        }
           It "Throw" {
        {throw "error message"} | Should Throw "error message"
    }
        It "should get specific vhdx file" {
            $VHDXDir = (Get-VMHost).VirtualHardDiskPath
            $VHDXFiles = (Get-ChildItem $VHDXDir).Name
            foreach ($VMName in $TestConfig.VMNames.VMName) {
                [Regex]::Match($VHDXFiles, $VMName).Success | Should Be $true   
            }
        }
        It "should get specific virtual machine" {
            foreach ($VMName in $TestConfig.VMNames.VMName) {            
                (Get-VM).Name -contains $VMName | Should Be $true
            }
        }
        It "should return exception value" {
            New-HyperVVirtualMachine | Should Be 1
        }
        Remove-HyperVVirtualMachine
    }
}