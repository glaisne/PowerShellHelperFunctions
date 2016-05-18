function Set-RandomPassword
{
<#
.Synopsis
   Sets a defulat password.
.DESCRIPTION
   Sets a randomly generated password.
.EXAMPLE
   Set-RandomPassword -distinguishedName 'cn=bob.smith,ou=users,dc=contoso,dc=com'

   Sets the password for Bob Smith to a randomly generated password.
.EXAMPLE
   $localDC = 'usa-aur-dc-01.dtzglobal.com'
   get-aduser -filter {userprincipalname -eq 'Bob.Smith@dtz.com'} |% {Set-RandomPassword -distinguishedName $_.DistinguishedName -Server $LocalDC}

   Sets the password for Bob Smith to a randomly generated password.
#>
    [CmdletBinding(SupportsShouldProcess=$True)]
    Param
    (
        [Parameter(ValueFromPipeline=$true)]
        [string[]] $distinguishedName,
        [int]  $PasswordLength
    )

    Begin
    {
        write-warning "This function is depricated in favor of the ADTools module version."
    }

    Process
    {

        foreach ($dn in $distinguishedName)
        {
            $YesToAll = $False
            $NoToAll  = $false

            if ($ConfirmPreference -eq 'None')
            {
                Write-Verbose "-Confirm was set to `$False."
                $YesToAll = $True
            }

            try
            {
                $User = Get-ADUser -Identity $DistinguishedName -Properties givenname, surname  -ErrorAction Stop
            }
            catch
            {
                Write-Error "Unable to access user $DistinguishedName"
                Continue
            }

            $password = $(Get-RandomPassword -PasswordLength $PasswordLength )

            # -whatif                    Target  Action
            if ( $PSCmdlet.ShouldProcess("$dn", "Set-ADAccountPassword to $Password" ) )
            {
                # -confirm                    Query                                Caption (Action)                                                       YesToAll        NoToAll
                if ( $PSCmdlet.ShouldContinue("Are you sure you want to do this?", "Change $($User.givenname) $($User.surname)'s password to $Password.", [ref]$YesToAll, [ref]$NoToAll ) )
                {
                    Set-ADAccountPassword -reset -NewPassword $(ConvertTo-SecureString -AsPlainText $password -Force) -Identity $distinguishedName
                }
            }
        }
    }
}

