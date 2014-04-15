function Write-AsCSV
{
    param([string[]] $List)

    [string] $Result = ([string]::Empty)

    foreach ($Entry in $List)
    {
        $Result += "$Entry, "
    }
    $Result = $Result.TrimEnd(", ")

    Return $Result
}