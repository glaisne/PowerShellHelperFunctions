
function Get-InstalledPatches
{
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
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

    #Return
    $Results | sort Patch
}