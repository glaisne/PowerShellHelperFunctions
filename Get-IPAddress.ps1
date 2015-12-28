function Get-IPAddress
{

<#
.SYNOPSIS
	Get IP addresses for specified hostnames
.DESCRIPTION
	Get IP addresses for specified hostnames
.EXAMPLE
	"server1","server2" | Get-IPAddress |ft

	This example will get the IP addresses for both hostnames.
.EXAMPLE
	Get-IPAddress "server1","server2" |ft

	This example will get the IP addresses for both hostnames.
.EXAMPLE
	Get-IPAddress "www.bing.com" |ft

	This example will get the IP address(es) for an individual hostname
.EXAMPLE
	"www.bing.com" | Get-IPAddress |ft

	This example will get the IP address(es) for an individual hostname
.PARAMETER username
	the username to modify
#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[string[]] $Hostname
	)
	begin{
  	}
	Process{
        foreach ($h in $Hostname)
        {
            new-object PSObject -Property @{
			    Hostname  = $h
			    IPAddress = $([System.Net.Dns]::GetHostByName($h).addresslist)
            }
        }
	}
	end {
	}
}