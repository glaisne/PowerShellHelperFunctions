function Write-AsCSV
{
    param(
        [Parameter(Mandatory=$true,
                   valueFromPipeline=$True,
                   Position=0)]
            [string[]] $List
    )

    [string] $Result = ([string]::Empty)

    foreach ($Entry in $List)
    {
        $Result += "$Entry, "
    }
    $Result = $Result.TrimEnd(", ")

    Return $Result
}
