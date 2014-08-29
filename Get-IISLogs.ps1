function get-IISLogs
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
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
        [string[]] $ComputerName,

		[int] $numberOfDays = 1,

		[string] $DestinationFolder = "$env:temp\IISLogs",

        [string] $Name = "IISLogs",

		[string] $RegEx = $null,

        [System.Management.Automation.PSCredential] $Credential = $null
	)

    write-Verbose "Making sure the Destination folder does not end with '\'"
	if ($DestinationFolder[-1] -eq "\")
	{
		$DestinationFolder.TrimEnd("\")
	}

    $DestFolderContents = Get-ChildItem -path $DestinationFolder -Attributes Directory
        
    if ($DestFolderContents.fullname -contains "$DestinationFolder\$Name")
    {
        Write-Verbose "$DestinationFolder already contains a folder called $name."
        write-Verbose "Determining a new folder to use."

        Foreach ($Number in (1..1000) )
        {
            $CurrentNumber = $("{0:D4}" -f $number)
            if ($DestFolderContents.fullname -NotContains "$DestinationFolder\$Name$CurrentNumber")
            {
                $Name = "$Name$CurrentNumber"
            }
        }
    }


    try
    {
        Write-verbose "Creating a new folder at '$DestinationFolder\$Name'"
        New-item -Path "$DestinationFolder\$Name" -ItemType Directory -ErrorAction Stop
    }
    catch
    {
        Throw "Unable to write to the destination directory $DestinationFolder."
    }


	foreach ($Computer in $ComputerName)
	{
        $SourceDirectory = "\\$Computer\c`$\inetpub\logs\LogFiles\W3SVC1"


        if ( $(Test-Path getiislogs:\) )
        {
            write-verbose "Removing pre-existing getiislogs: drive."
            Get-PSDrive "getiislogs" | Remove-PSDrive -Confirm:$false
        }

        Write-Verbose "Mapping PSDrive 'getiislogs' to '$SourceDirectory'”

        $params = @{
            Name        = “getiislogs”
            PSProvider  = "FileSystem"
            Root        = “$SourceDirectory”
            ErrorAction = "Stop"
        }

        if ($Credential -ne $null)
        {
            $params.Add("Credential", $Credential)
        }

        try
        {
            New-PSDrive @params
        }
        catch
        {
            Write-Error "Unable to map a drive to $SourceDirectory”
            continue
        }

		start-sleep -s 1

		for ($i = 0; $i -lt $numberOfDays; $i++)
		{
            $WorkingDate = $(get-date).addDays(($i * -1))

            Write-Verbose "Getting logs on $computer for $WorkingDate"

			$FormattedDate = "{0:yyMMdd}" -f $WorkingDate
			$SourceFile = "u_ex$FormattedDate`.log"
				
            write-verbose "Copying..."
            write-verbose "Source     : getiislogs:\$SourceFile"
            Write-Verbose "Destination: $DestinationFolder\$Name\u_ex$FormattedDate`.$Computer`.LOG"

            try
            {
                $params = @{
                    Path        = "getiislogs:`\$SourceFile"
                    Destination = "$DestinationFolder\$Name\u_ex$FormattedDate`.$Computer`.LOG"
                    ErrorAction = "Stop"
                }
                        
                Copy-Item @params  
            }
            catch
            {
                $err = $_
                Write-Error "There was an error copying the file getiislogs:`\$SourceFile"
                write-Error $err
                continue
            }
		}
	}

    if ($RegEx -ne $null)
    {

        write-verbose "Parsing files for requested information."

		foreach ($file in Get-ChildItem "$DestinationFolder\$Name\" -Include "u_ex.*\.$Computer\.LOG")
        {            
            $targetFile = "{0}\{1}\{2}.{3}{4}" -f $DestinationFolder, $Name, $($file.baseName), "Parsed", $($File.Extension)

            Write-Verbose "Searching file $($File.FullName) for regular expression '$RegEx'"
            write-verbose "writting matches to $targetFile"

			get-content $($file.FullName) |	select-string $RegEx |out-file $targetFile
		}
    }

}