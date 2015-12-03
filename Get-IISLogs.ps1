function Get-IISLogs
{

<#
.SYNOPSIS
	Downloads IIS logs from one, or more, computers to a folder. It will also parse the file if specified.
.DESCRIPTION
	Downloads IIS log files from one, or more, computers to a folder. If the RegEx parameter is set, it 
    will parse the file for the given regular expression and put only those lines into a "parsed" file.

    The script will download the files and give the files a new name which includes the computername.
    The new file will be u_ex<date>.<ComputerName>.LOG. If the RegEx value is defined, the additiona file
    will be named u_ex<date>.<ComputerName>.Parsed.LOG
.EXAMPLE
	Get-IISLogs -ComputerName IIS01 -NumberOfDays 2 -DestinationFolder C:\MyLogs -SearchName 2DaysOfLogs

    This example will download 2 days worth of IIS logs from the computer named IIS01 and place all the 
    files in C:\MyLogs\2DaysOfLogs
.PARAMETER ComputerName
	Identifies the computer to download IIS logs from
.PARAMETER NuberOfDays
    Specifies the number of days of logs to download based on the IIS log file name, not by actual date
    created or modified. The default setting for this parameter is 1.
.PARAMETER
    DestinationFolder specifies the target folder where the folder, identified by 'SearchName' is created.
    The The IIS log files will go inside the "SearchName" folder and the "SearchName" folder will go in the 
    Destinationfolder.

    So, <DestinationFolder>\<SearchName>\<IISLogfiles>
#>
	[CmdletBinding()]
	param(
        [Parameter(Mandatory=$true)]
        [string[]] $ComputerName,

        [int] $NumberOfDays = 1,

        [string] $DestinationFolder = "$env:temp\IISLogs",

        [string] $SearchName = "IISLogs",

        [string] $RegEx = $null,

        [System.Management.Automation.PSCredential] $Credential = $null
	)

	write-Verbose "Making sure the Destination folder does not end with '\'"
	if ($DestinationFolder[-1] -eq '\')
	{
		$DestinationFolder.TrimEnd('\')
	}

	$DestFolderContents = Get-ChildItem -path $DestinationFolder -Attributes Directory
        
	if ($DestFolderContents.fullname -contains "$DestinationFolder\$SearchName")
	{
		Write-Verbose "$DestinationFolder already contains a folder called $SearchName`."
		Write-Verbose "Determining a new folder to use."
		
		Foreach ($Number in (1..1000) )
		{
			$CurrentNumber = $("{0:D4}" -f $number)
			if ($DestFolderContents.fullname -NotContains "$DestinationFolder\$SearchName$CurrentNumber")
			{
				$SearchName = "$SearchName$CurrentNumber"
			}
		}
	}


	Write-Verbose "Creating a new folder at '$DestinationFolder\$SearchName'"
	try
	{
		New-Item -Path "$DestinationFolder\$SearchName" -ItemType Directory -ErrorAction Stop
	}
	catch
	{
		Write-Error "Unable to write to the destination directory $DestinationFolder."
	}


    foreach ($Computer in $ComputerName)
    {
        $SourceDirectory = "\\$Computer\c`$\inetpub\logs\LogFiles\W3SVC1"


        if ( $(Test-Path getiislogs:\) )
        {
            Write-Verbose "Removing pre-existing getiislogs: drive."
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
            New-PSDrive @params -ErrorAction Stop
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
				
            Write-Verbose "Copying..."
            Write-Verbose "Source     : getiislogs:\$SourceFile"
            Write-Verbose "Destination: $DestinationFolder\$SearchName\u_ex$FormattedDate`.$Computer`.LOG"

            $params = @{
                Path        = "getiislogs:`\$SourceFile"
                Destination = "$DestinationFolder\$SearchName\u_ex$FormattedDate`.$Computer`.LOG"
                ErrorAction = "Stop"
            }

            try
            {
                Copy-Item @params -ErrorAction Stop
            }
            catch
            {
                $err = $_
                Write-Error "There was an error copying the file getiislogs:`\$SourceFile"
                Write-Error $err
                continue
            }
        }
    }

    if ($RegEx -ne $null)
    {
        write-verbose "Parsing files for requested information."

        foreach ($file in Get-ChildItem "$DestinationFolder\$SearchName\" -Include "u_ex.*\.$Computer\.LOG")
        {            
            $targetFile = "{0}\{1}\{2}.{3}{4}" -f $DestinationFolder, $SearchName, $($file.baseName), "Parsed", $($File.Extension)

            Write-Verbose "Searching file $($File.FullName) for regular expression '$RegEx'"
            write-verbose "writting matches to $targetFile"

            get-content $($file.FullName) |	select-string $RegEx |out-file $targetFile
        }
    }

}

