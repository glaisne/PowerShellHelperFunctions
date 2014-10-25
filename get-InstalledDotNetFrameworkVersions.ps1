<<<<<<< HEAD
﻿function get-InstalledDotNetFrameworkVersions
{
<#
.DESCRIPTION
	Retruns the version numbers of all currently installed .NET framework versions
#>
<# This function comes from PowerShell.com's "Checking for .NET Framework Version with Powershell"
    http://powershell.com/cs/blogs/tips/archive/2010/07/16/checking-for-net-framework-version-with-powershell.aspx
#>
    dir C:\Windows\Microsoft.NET\Framework\v* -name
=======
﻿function get-InstalledDotNetFrameworkVersions
{
<#
.DESCRIPTION
	Retruns the version numbers of all currently installed .NET framework versions
#>
<# This function comes from PowerShell.com's "Checking for .NET Framework Version with Powershell"
    http://powershell.com/cs/blogs/tips/archive/2010/07/16/checking-for-net-framework-version-with-powershell.aspx
#>
    dir C:\Windows\Microsoft.NET\Framework\v* -name
>>>>>>> 02e0cbbfd9bf973bcfa6e6c93d821c6ce179ecb0
}