

<###################################
Setup
####################################>

$RootDirectory = "C:\Scripts\ScheduledScripts\UpdateVMs"
$vSphereServerListFile = "vCenterServerList.txt"
$CSVResultsFileName = "VMs.csv"
$ExcelResultsFileName = "VM.xlsx"

$vSphereServers = gc "$RootDirectory\$vSphereServerListFile"


<###################################
End Setup
###################################>

remove-item "$RootDirectory\$CSVResultsFileName" -force
remove-item "$RootDirectory\$ExcelResultsFileName" -force


. "$RootDirectory\get-VMInformation.ps1"
. "$RootDirectory\Export-Xls.ps1"


If (-not (Get-Command Connect-VIServer)) {
	Write-Error "This script must run from a PowerCLI shell."
	return	
}

foreach ($Server  in $vSphereServers)
{
	Connect-VIServer $Server -force
}


$AllVMs = get-vm

$AllVMsFormatted = $null
$AllVMsFormatted = @()

$AllVMsInformation = $AllVMs | Get-VMInformation


$AllVMsInformation |select name,"CPU Count",memoryMB,"PROVISIONED SPACE",*disk*,*storage*,"IP Address","Host Name",STATE,*manager*,*admin*,*client*,host,*note* | Export-Xls "$RootDirectory\$ExcelResultsFileName" -Worksheet $(get-date -f "MM.dd.yyyy").ToString()

#$Excel = New-Object -comobject Excel.Application
#
#$Excel.Visible = $true
#
#$workBook = $Excel.Workbooks.Open("$RootDirectory\$CSVResultsFileName", 1)
#
#$workBook.SaveAs("$RootDirectory\$ExcelResultsFileName")
#$workBook.Close($false)
#$Excel.Quit()
#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)

remove-psdrive -Name "T" -PSProvider FileSystem -Force
#new-psdrive -name T -psprovider filesystem -root "\\share.bu.edu@SSL\DavWWWRoot\sites\ist\org\syseng\docs" #\docs\Asset Inventory
new-psdrive -name T -psprovider filesystem -root "\\share.bu.edu@SSL\sites\ist\org\syseng\docs" #\docs\Asset Inventory

Move-Item "$RootDirectory\$ExcelResultsFileName" "T:\Asset Inventory\" -force
dir 'T:\Asset Inventory\vm.xlsx' |ft mode,creationTime,lastwriteTime,length,name -auto|out-string -stream |?{$_ -ne ""}| out-file "$RootDirectory\dir.txt"

remove-psdrive -Name "T" -PSProvider FileSystem -Force
