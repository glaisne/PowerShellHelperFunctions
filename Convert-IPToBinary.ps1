function Convert-IPToBinary
{
<#
.Synopsis
   Converts an IP address from a string to it's binary equivalent.
#>
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string] $IPAddress
    )

    Begin { }
    Process
    {
        $binary = ""
        $IPAddress.split(".") | %{$binary=$binary + $([convert]::toString($_,2).padleft(8,"0"))}
        Write-Output $binary
    }
    End { }
}