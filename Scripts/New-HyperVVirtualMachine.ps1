function New-HyperVVirtualMachine {
<#
.SYNOPSIS
Create virtual machine on Hyper-V using template vhdx file.

.EXAMPLE
New-HyperVVirtualMachine -VMNames $VMNames -VHDXSourcePath $VHDXSourcePath

.NOTES
Should be prepared template vhdx file.
Should run local administrator user.
#>    
    [CmdletBinding()]     
    Param
    (
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [String[]]$VMNames,

        [Parameter(Mandatory=$false)]
        [String]$VHDXDir = (Get-VMHost).VirtualHardDiskPath,

        [Parameter(Mandatory=$true)]
        [String]$VHDXSourcePath,        
        
        [Parameter(Mandatory=$false)]
        [int]$ProcessorCount = 2,

        [Parameter(Mandatory=$false)]
        [int]$Generation = 1,

        [Parameter(Mandatory=$false)]
        [Int64]$ServerMaximumMemoryMB = 4096MB,

        [Parameter(Mandatory=$false)]
        [Int64]$ServerMinimumMemoryMB = 512MB,

        [Parameter(Mandatory=$false)]
        [Int64]$MemoryStartupBytes = 512MB,

        [Parameter(Mandatory=$false)]
        [Int64]$VHDXDiskSizeBytes = 127GB,        

        [Parameter(Mandatory=$false)]
        [String]$SwitchType = "Internal",

        [Parameter(Mandatory=$false)]
        [String]$SwitchName = "InternalSwitch"
    )
    Begin
    {
        Import-Module Hyper-V
        if(!(Test-Path -Path $VHDXDir)) { New-Item $VHDXDir -ItemType Directory | Out-Null }
        if ((Get-VMSwitch).SwitchType -notcontains $SwitchType -and (Get-VMSwitch).Name -notcontains $SwitchName) {
            New-VMSwitch -Name $SwitchName -SwitchType $SwitchType | Out-Null
        }

        $VMSettings = @{
          "ProcessorCount" = $ProcessorCount
          "MemoryMinimumBytes" = $ServerMinimumMemoryMB
          "MemoryMaximumBytes" = $ServerMaximumMemoryMB
          "DynamicMemory" = $true
          "Passthru" = $true
        }
    }
    Process
    {
        foreach($VMName in $VMNames) {
            try {
                $VHDXPath = (New-VHD -Path "$($VHDXDir)\$($VMName).vhdx" `
                                     -ParentPath $VHDXSourcePath `
                                     -SizeBytes $VHDXDiskSizeBytes `
                                     -ErrorAction Stop).Path
            }
            catch {
                Write-Verbose $_
                return 1
            }
            $VMParams = @{
                "Name" = [String]$VMName
                "Generation" = $Generation
                "MemoryStartupBytes" = $MemoryStartupBytes
                "SwitchName" = $SwitchName
                "VHDPath" = $VHDXPath
            }
            Write-Verbose "Creating VM : $($VMName)"
            New-VM @VMParams | Set-VM @VMSettings | Start-VM
            Write-Verbose "$($VMName) created successfully"
        }
        Write-Verbose "VM created successfully"        
    }
    End {}
}