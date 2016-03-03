$startDate = $(get-date).AddDays(-1)
$Ticket = "INC11416467"
$GatherOutlookInformation = $true

#######################################
#
#   No editing below
#
#######################################

$Version = "1.0"
$dateString = get-date -f "MMddyyyyHHmmss"

function ZipFiles( $zipfilename, $sourcedir )
{
    [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" ) | out-null

    try
    {
        write-verbose "Trying .NET 4.5 version of file compression"
        $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
        [System.IO.Compression.ZipFile]::CreateFromDirectory( $sourcedir, $zipfilename, $compressionLevel, $false )
    }
    catch
    {
        write-verbose ".NET 4.5 version of compression didn't work."
    }

    if (-Not $(Test-Path $ZipFileName) )
    {
        [System.IO.Compression.ZipFile]::CreateFromDirectory( $sourcedir, $zipfilename )
    }
    
}

function IsAdministrator {
    [Security.Principal.WindowsPrincipal]$id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}


$R = (Get-Random).ToString()

mkdir $env:Temp\$R | out-null

"Script: Get-TicketInfo.ps1 (v$version)`r`nTicket: $Ticket`r`nRuntime: $(Get-Date)`r`nHost: $($env:COMPUTERNAME)`r`nUser: $($env:USERNAME)`r`nIsAdministrator: $(IsAdministrator)" | out-file "$env:Temp\$R\Runtime.log"


# get relative EventLogs

write-host "Gathering information..."

$LogNames = "Application", "System", "OAlerts", "Cisco AnyConnect Secure Mobility Client"

if (IsAdministrator)
{
    $LogNames += "Security"
}

foreach ($log in $LogNames)
{
    Get-EventLog -LogName $log -After $(get-date $startDate) |Export-Clixml $env:Temp\$R\$log.xml -ErrorAction SilentlyContinue
}



if ($GatherOutlookInformation)
{
    write-host "Attempting to gather some information about Outlook..."
    $CanAccessOutlook = $true
    $msg = [string]::Empty

    $OutlookLogFile = "$env:Temp\$R\Outlook.log"

    "Attempting to access Outlook" | out-file $OutlookLogFile -Encoding ascii -Append

    try
    {
        Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
    }
    catch
    {
        $CanAccessOutlook = $False
        $msg += "`r`n > Failed to load assembly 'Microsoft.Office.Interop.Outlook'"
    }

    try
    {
        $olFolders = "Microsoft.Office.Interop.Outlook.olDefaultFolders" -as [type] 
    }
    catch
    {
        $CanAccessOutlook = $False
        $msg += "`r`n > Failed to create olDefaultFolders Object.'"
    }

    try
    {
        $outlook = [Runtime.Interopservices.Marshal]::GetActiveObject('Outlook.Application')
    }
    catch
    {
        $msg += "`r`n > Outlook was not accessable via '[Runtime.Interopservices.Marshal]::GetActiveObject('Outlook.Application')'`r`n`r`n"
        $msg += "Outlook Process list:`r`n"
        get-process Outlook | fl | out-string -stream |? { $_ -ne "" } | % {$msg += "$_`r`n" }

        $msg += "`r`n"

        $msg += "NOTE: if the script is run 'As Administrator' and Outlook is not (or vice-versa. it is possible`r`n"
        $msg += "Outlook will be running, but not accessable.`r`n"
        
        $msg += "`r`n"
    }
    

    if (-Not $outlook)
    {
        $CanAccessOutlook = $False
    }

    if (-Not $CanAccessOutlook)
    {
        "Failed to Access Outlook`r`n$msg`r`n`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
    }
    else
    {
        "Successful connecting to Outlook."  | out-file $OutlookLogFile -Encoding ascii -Append

        $Outlook | fl Name,Version,DefaultProfileName

        $namespace = $outlook.GetNameSpace("MAPI")

        "CurrentUser`r`n================================`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
        $($namespace.currentUser )  | out-file $OutlookLogFile -Encoding ascii -Append
        "Offline = $($namespace.Offline)`r`n" | out-file $OutlookLogFile -Encoding ascii -Append



        $ExchangeConnectionMode = $($namespace.ExchangeConnectionMode)

        switch ($ExchangeConnectionMode)
        {
            '0' 
            {
                $ExchangeConnectionModeString = "(0) NoExchange: Account does not use and Exchange server."
                break
            }
            '100' 
            {
                $ExchangeConnectionModeString = "(100) olOffline : The account is not connected to an Exchange server and is in the classic offline mode. This also occurs when the user selects Work Offline from the File menu.."
                break
            }
            '200' 
            {
                $ExchangeConnectionModeString = "(200) olCachedOffline : The account is using cached Exchange mode and the user has selected Work Offline from the File menu."
                break
            }
            '300' 
            {
                $ExchangeConnectionModeString = "(300) olDisconnected : The account has a disconnected connection to the Exchange server. "
                break
            }
            '400' 
            {
                $ExchangeConnectionModeString = "(400) olCachedDisconnected : The account is using cached Exchange mode with a disconnected connection to the Exchange server. "
                break
            }
            '500' 
            {
                $ExchangeConnectionModeString = "(500) olCachedConnectedHeaders : The account is using cached Exchange mode on a dial-up or slow connection with the Exchange server, such that only headers are downloaded. Full item bodies and attachments remain on the server. The user can also select this state manually regardless of connection speed."
                break
            }
            '600' 
            {
                $ExchangeConnectionModeString = "(600) olCachedConnectedDrizzle : The account is using cached Exchange mode such that headers are downloaded first, followed by the bodies and attachments of full items."
                break
            }
            '700' 
            {
                $ExchangeConnectionModeString = "(700) olCachedConnectedFull : The account is using cached Exchange mode on a Local Area Network or a fast connection with the Exchange server. The user can also select this state manually, disabling auto-detect logic and always downloading full items regardless of connection speed."
                break
            }
            '800' 
            {
                $ExchangeConnectionModeString = "(800) olOnline : The account is connected to an Exchange server and is in the classic online mode. "
                break
            }
            Default 
            {
                $ExchangeConnectionModeString = "Unknown - there must have been an issue determining the connection mode."
            }
        }


        "ExchangeConnectionMode = $ExchangeConnectionModeString`r`n" | out-file $OutlookLogFile -Encoding ascii -Append


        "CurrentProfileName = $($namespace.CurrentProfileName)`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
        "Accounts`r`n================================`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
        $($namespace.Accounts | select class, DisplayName,UserNAme,SmtpAddress,AutodDiscoverConnectionMode, ExchangeConnectionMode, ExchangeMailboxServerVersion) | out-file $OutlookLogFile -Encoding ascii -Append
        "Stores (connected mailboxes)`r`n================================`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
        $($namespace.Stores | select class,DisplayName,IsOpen, ExchangeStoreType, FilePath) | out-file $OutlookLogFile -Encoding ascii -Append
        "AutoDiscoverXml`r`n================================`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
        $($namespace.AutoDiscoverXml) | out-file $OutlookLogFile -Encoding ascii -Append
        "ComAddIns`r`n================================`r`n" | out-file $OutlookLogFile -Encoding ascii -Append
        $($outlook.Application.COMAddIns | select Description) | out-file $OutlookLogFile -Encoding ascii -Append
    }
}



write-host "Creating zip file '$env:Userprofile\Desktop\$Ticket`_$DateString`.zip'"

ZipFiles -zipfilename "$env:Userprofile\Desktop\$Ticket`_$DateString`.zip" -sourcedir "$env:Temp\$R" 

Write-host -fore yellow "`r`n`r`nPlease attach this zip file '$env:Userprofile\Desktop\$Ticket`_$DateString`.zip' to the ticket $Ticket`r`n"

write-host -fore yellow "`r`n`r`nIf you don't see '$env:Userprofile\Desktop\$Ticket`_$DateString`.zip' create a zip file out of the folder '$env:Temp\$R' and attach ti to the ticket $Ticket."
