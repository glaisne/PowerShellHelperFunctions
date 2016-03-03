# Taken from:
# http://poshcode.org/1591
# Modified since.
###########################################################################
# Get-OLEDBData
# --------------------------------------------
# Description: This function is used to retrieve data via an OLEDB data
#              connection.
#
# Inputs: $connectstring  - Connection String.
#         $sql            - SQL statement to be executed to retrieve data.
# 
# Usage: Get-OLEDBData <connction string> <SQL statement>
#
#Connection String for Excel 2007:
#"Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$filepath`";Extended Properties=`"Excel 12.0 Xml;HDR=YES`";"
#Connection String for Excel 2003:
#"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=`"$filepath`";Extended Properties=`"Excel 8.0;HDR=Yes;IMEX=1`";"
#Excel query
#'select * from [sheet1$]'
#Informix
#"password=$password;User ID=$userName;Data Source=$dbName@$serverName;Persist Security Info=true;Provider=Ifxoledbc.2"
#Oracle
#"password=$password;User ID=$userName;Data Source=$serverName;Provider=OraOLEDB.Oracle"
#SQL Server
#"Server=$serverName;Trusted_connection=yes;database=$dbname;Provider=SQLNCLI;"
###########################################################################
function Get-OLEDBData 
{
<#
.Synopsis
   This function will make a query an OLEDB data source and return the results.
#>
    [CmdletBinding()]
    Param
    (
        # Connection String for the data source
        [Parameter(Mandatory=$true, Position=0)]
        [string] $connectstring,

        # Query to run against data source
        [Parameter(Mandatory=$true, Position=1)]
        [string] $sql
    )


    $OLEDBConn = New-Object System.Data.OleDb.OleDbConnection($connectstring)

    Write-Verbose "About to open the Excel spreadsheet ($filepath)."
    Write-Verbose "* It is possible, the spreadsheet is not accessable using OLEDB."
    Write-verbose "* If there is an error saying: "
    Write-Verbose "*      ""...The 'Microsoft.ACE.OLEDB.12.0' provider is not registered on the local machine."""
    Write-verbose "* you may need to install the 2010 version of Office (or higher) or, "
    Write-Verbose "* install the 'Microsoft Access Database Engine 2010 Redistributable'"
    Write-Verbose "* from Microsoft (http://www.microsoft.com/en-us/download/details.aspx?id=13255)."
    Write-Verbose "* If this script is running against Office 2007, you may need to install the "
    Write-Verbose "* '2007 Office System Driver: Data Connectivity Components'"
    Write-Verbose "* (http://www.microsoft.com/en-us/download/details.aspx?id=23734). "
    Write-Verbose "* And, you may need to run PowerShell as 32-bit, not 64."
    switch ($([System.IntPtr]::Size))
    {
        4 {Write-Verbose "* This Shell is running in 32-bit mode."}
        8 {Write-Verbose "* This Shell is running in 64-bit mode."}
    }

    $EAP = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    Try
    {
        $OLEDBConn.open()
        $readcmd = New-Object system.Data.OleDb.OleDbCommand($sql,$OLEDBConn)
        $readcmd.CommandTimeout = '300'
        $da = New-Object system.Data.OleDb.OleDbDataAdapter($readcmd)
        $dt = New-Object system.Data.datatable
        [void]$da.fill($dt)
        $OLEDBConn.close()

        $OLEDBConn = $null
        $da        = $null
    }
    Catch [System.Management.Automation.RuntimeException]
    {
        $err = $_
        $ErrorActionPreference = $EAP
        throw "Exception: $($err.Exception.GetType().FullName)`:`n$($err.Exception.Message)`n"
    }
    Catch
    {
        $err = $_
        $ErrorActionPreference = $EAP
        throw "Unexpected error:`n$($Err.toString())"
    }

    Write-Output $dt
}
