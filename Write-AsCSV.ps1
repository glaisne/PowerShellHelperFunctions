function Write-AsCSV
{
    param(
        [Parameter(Mandatory=$true,
                   valueFromPipeline=$True,
                   Position=0)]
            [string[]] $List,
            [char]     $Delimiter = ','
    )

    [string] $Result = ([string]::Empty)

    foreach ($Entry in $List)
    {
        $Result += "$Entry$Delimiter "
    }
    $Result = $Result.TrimEnd("$Delimiter ")

    Write-Output $Result
}
