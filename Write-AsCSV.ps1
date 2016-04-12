function Write-AsCSV
{
    param(
        [Parameter(Mandatory=$true,
                   valueFromPipeline=$True,
                   Position=0)]
        [AllowNull()]
            [string[]] $List,
            [char]     $Delimiter = ','
    )

    if ($List -eq $null)
    {
        return $null
    }

    [string] $Result = ([string]::Empty)

    foreach ($Entry in $List)
    {
        $Result += "$Entry$Delimiter "
    }
    $Result = $Result.TrimEnd("$Delimiter ")

    Write-Output $Result
}
