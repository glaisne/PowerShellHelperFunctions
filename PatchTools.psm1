
function Get-InstalledPatches
{
<#
.Synopsis
   List Windows patches installed on the specified computer
.DESCRIPTION
   Using WMI, this function collects the installed Windows  
   patches on a given system and returns the list.
.EXAMPLE
   Get-InstalledPatches -ComputerName "MyComputer"

   This example will list all the installed Windows patches
   on a system.
#>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName = "Localhost"
    )

    Write-Verbose "getting patches installed on $ComputerName"
    Get-WmiObject -Class "win32_quickfixengineering" -ComputerName $ComputerName | Select-Object -Property "Description", "HotfixID" 
}

<#
.Synopsis
   Get patches from two systems and find differences.
.EXAMPLE
   Compare-Patches -Computer1 "FirstComputer" -Computer2 "SecondComputer"

   This example compares the installed Windows patches on the computers
   named "FirstComputer" and "SecondComputer."
#>
function Compare-Patches
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        $Computer1,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   Position=1)]
        $Computer2
    )

    $PatchesOnComputer1 = Get-InstalledPatches $Computer1
    $PatchesOnComputer2 = Get-InstalledPatches $Computer2

    $Results = @()

    foreach ($patch in $PatchesOnComputer1)
    {
        if (-Not $($PatchesComputer2.hotfixid -contains $patch.hotfixid) )
        {
            $PatchesMissingOnComputer2 += $patch.hotfixid

            $Results += New-Object PSObject -Property @{
                Patch = $patch.hotfixid
                MissingOn = $Computer2
            }
        }
    }

    foreach ($patch in $PatchesOnComputer2)
    {
        if (-Not $($PatchesOnComputer1.hotfixid -contains $patch.hotfixid) )
        {
            $PatchesMissingOnComputer1 += $patch.hotfixid

            $Results += New-Object PSObject -Property @{
                Patch = $patch.hotfixid
                MissingOn = $Computer1
            }
        }
    }

    $Results | sort Patch
}