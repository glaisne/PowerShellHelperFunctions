
function Get-VMInformation
{

<#
.SYNOPSIS
	Synopsis
.DESCRIPTION
	description
.EXAMPLE
	example
.PARAMETER username
	the username to modify
#>
	[CmdletBinding(SupportsShouldProcess=$true)]
	param(
		[parameter(Mandatory=$true,
			ValueFromPipeline=$true)]
		# Username that will be provisioned a mailbox
		[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl[]] $VM
	)

	Process{

       # $_ |fl *

		$unavailableString = ""

		$OS = $_.Guest.ToString().split(':')[1]
		$Datastore = get-datastore -id $_.DatastoreIdList

		if ($DataStore.GetType().Name -eq "Object[]")
		{
			$DataStore = $DataStore[0].Name
		}
		else
		{
			$DataStore = $DataStore.Name
		}
		$vCenter = $_.uid.split(@('@',':'))[1]

		# Get Hard Disk Information
		$HardDisks = @()
		foreach ($Hd in $_ | get-harddisk -ea 0)
		{
			$HardDisks += $($Hd.filename) | split-path
		}
		$HardDiskCount = $HardDisks.count

		$vmGuest = $_ | Get-VMGuest

        $IPAddresses = ""
        $($vmGuest.IPAddress) |%{$IPAddresses += "$_ " }


		$AllVMsFormatted += New-Object PSObject -property @{
			Name					= $_.name
			OS					= $OS
			"Special Considerations"		= $unavailableString
			Datastore				= $Datastore
			"Backed up?"				= $unavailableString
			"Replication (App - RCIP)"		= $unavailableString
			"Move to 3PAR"				= $unavailableString
			"Creation Date"				= "Todo"
			vCenter					= $vCenter
			STATE					= $_.PowerState
			STATUS					= $unavailableString
			HOST					= $_.vmhost
			"PROVISIONED SPACE"			= "$([math]::round($_.provisionedspacegb, 2)) GB"
			"USED SPACE"				= "$([math]::round($_.usedSpacegb, 2)) GB"
			"HOST CPU - MHZ"			= $unavailableString
			"HOST MEM - MB"				= $unavailableString
			"GUEST MEM - %"				= $unavailableString
			NOTES					= $_.notes
			"ALARM ACTIONS"				= $unavailableString
			"Client Contact"			= $_.CustomFields["Client Contact"]
			"MANAGER-RESPONSIBLE-FOR-THIS-VM"	= $_.customfields["manager responsible"]
			"Server Admin"				= $_.CustomFields["Server Admin"]
			"Server Admin Primary Contact"		= $_.CustomFields["Server Admin Primary Contact"]
			"Service Level"				= $_.CustomFields["Service Level"]
			"maintenance-notification-address"	= $_.CustomFields["maintenance-notification-address"]
	#		"manager-responsible-for-this-vm"	= $_.CustomFields["manager-responsible-for-this-vm"]
			PROJECT					= $_.CustomFields["project"]
			"REQUESTER-ALIAS"			= $_.CustomFields["requester-alias"]
			"VSC-DATE-RENEW"			= $_.CustomFields["vsc-date-renew"]
			"VSC-DATE-START"			= $_.CustomFields["vsc-date-start"]
			"VSC-SIZE"				= $_.CustomFields["vsc-size"]
			"VSC-SLA"				= $_.CustomFields["vsc-sla"]
			"Monitor Type"				= $unavailableString
	#		"Service Level"				= $unavailableString
			"Administered By"			= $unavailableString
			"Patched By"				= $unavailableString
			"Patch Date"				= $unavailableString
			"Patch Frequency"			= $unavailableString
			EPO					= $unavailableString
			"Movement Restrictions"			= $unavailableString
			"Storage Folder"			= $HardDisks
			"Hard Disk Count"			= $HardDiskCount
			MemoryMB				= $_.MemoryMB
			MemoryGB				= $_.MemoryGB
			"Date VM Created"			= "Needs work/mayNot be available"
			"CPU Count"				= $_.NumCpu
			"IP Address"				= $IPAddresses
			"host name"				= $($VMGuest.hostname)
		}

	}

    end
    {
        return $AllVMsFormatted
    }
}