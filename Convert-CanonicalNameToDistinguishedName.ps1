function Convert-CanonicalNameToDistinguishedName
{<#
.Synopsis
   Short description
.DESCRIPTION
   Long description

   reference: http://www.itadmintools.com/2011/09/translate-active-directory-name-formats.html
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]] $CanonicalName
    )

    Begin
    {
        write-warning "This function is depricated in favor of the ADTools module version."


        #Name Translator Initialization Types
        $ADS_NAME_INITTYPE_DOMAIN   = 1
        $ADS_NAME_INITTYPE_SERVER   = 2
        $ADS_NAME_INITTYPE_GC       = 3

        #Name Transator Name Types
        $EnumDISTINGUISHEDNAME     = 1
        $EnumCANONICALNAME         = 2
        $EnumNT4NAME               = 3
        $EnumDISPLAYNAME           = 4
        $EnumDOMAINSIMPLE          = 5
        $EnumENTERPRISESIMPLE      = 6
        $EnumGUID                  = 7
        $EnumUNKNOWN               = 8
        $EnumUSERPRINCIPALNAME     = 9
        $EnumCANONICALEX          = 10
        $EnumSERVICEPRINCIPALNAME = 11
        $EnumSIDORSIDHISTORY      = 12

    }

    Process
    {
        foreach ($entry in $CanonicalName)
        {
            $ns=New-Object -ComObject NameTranslate
            [System.__ComObject].InvokeMember(“init”,”InvokeMethod”,$null,$ns,($ADS_NAME_INITTYPE_GC,$null))
            [System.__ComObject].InvokeMember(“Set”,”InvokeMethod”,$null,$ns,($UNKNOWN,$entry))

            [System.__ComObject].InvokeMember(“Get”,”InvokeMethod”,$null,$ns,$EnumDISTINGUISHEDNAME)
        }
    }
    
}
