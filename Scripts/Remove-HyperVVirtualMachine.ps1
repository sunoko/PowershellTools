function Remove-HyperVVirtualMachine {
<#
.SYNOPSIS
Delete virtual machine and vhdx file.

.EXAMPLE
Remove-HyperVVirtualMachine -VMNames $VMNames

.NOTES
Should run local administrator user.
#>       
    [CmdletBinding()]     
    Param
    (
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]$VMNames,  

        [Parameter(Mandatory=$false)]
        [String]$VHDXDir = (Get-VMHost).VirtualHardDiskPath        
    )
    Import-Module Hyper-V
    foreach ($VMName in $VMNames) {
        Stop-VM $VMName -Force -ErrorAction SilentlyContinue
        Remove-VM $VMName -Force -ErrorAction SilentlyContinue
        Remove-Item (Join-Path $VHDXDir "$($VMName).vhdx") -ErrorAction SilentlyContinue
    }
}