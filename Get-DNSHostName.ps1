
function Get-DNSHostName
{

<#
.SYNOPSIS
	Get hostname for specified IP address
.DESCRIPTION
	Get hostname for specified IP address
.EXAMPLE
	"10.125.226.16","10.125.226.17" | Get-DNSHostName |ft

	This example will get the hostname for both IP addresses.
.EXAMPLE
	Get-DNSHostName "10.125.226.16","10.125.226.17" |ft

	This example will get the hostname for both IP addresses.
.EXAMPLE
	Get-DNSHostName "10.125.226.16" |ft

	This example will get the hostname for an individual IP address
.EXAMPLE
	"10.125.226.16" | Get-DNSHostName |ft

	This example will get the hostnamees for an individual IP address
.PARAMETER IPAddress
	IP address to be resolved.
#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]
		# IP address to be resolved.
		[string[]] $IPAddress
	)
	begin
    {
        Write-Warning "This function depricated in favor of the PSTools module version."
    }
	Process
    {
        foreach ($IP in $IPAddress)
        {
		    $Entry = new-object PSObject -Property @{
		        IPAddress = $IP
		        Hostname  = $([System.Net.Dns]::GetHostEntry($IP).hostname)
		    }
            Write-output $Entry
        }
	}
	end 
    {
    }
}