function Convert-IPToBinary
{
<#
.Synopsis
   Converts an IP address string to it's binary string equivalent.
.DESCRIPTION
   Takes a IPAddress as a string and returns the same IP address
   as a binary string with no decimal points.
.Parameter IPAddress
   The IP address which will be converted to a binary string.
.EXAMPLE
   Convert-IPToBinary -IPAddress "10.11.12.13"

   This example will return

   Binary                           IPAddress
   ------                           ---------
   00001010000010110000110000001101 10.11.12.13
#>
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
        [string[]] $IPAddress
    )

    Begin { }
    Process
    {
        foreach ($IP in $IPAddress)
        {
            $Binary = ""
            $IPAddress.split(".") | %{$Binary = $Binary + $([convert]::toString($_,2).padleft(8,"0"))}
            $Result = new-object PSObject -Property @{
                IPAddress = $IP
                Binary    = $Binary
            }
            Write-Output $Result
        }
    }
    End { }
}