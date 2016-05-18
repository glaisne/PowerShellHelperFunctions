function Get-RandomPassword
{
    Param
    (
        [Parameter(ValueFromPipeline=$true)]
        [int] $PasswordLength
    )
        write-warning "This function is depricated in favor of the ADTools module version."

    $passwordSource = "#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~".ToCharArray()

    $passwordString = [string]::Empty

    Get-Random -count $PasswordLength -InputObject $passwordSource | % { $passwordString += $_}

    $passwordString
}
