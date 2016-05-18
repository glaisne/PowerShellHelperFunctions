function Split-ADDNPath
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $DistinguishedName,
        [switch] $leaf
    )

    Begin
    {
        write-warning "This function is depricated in favor of the ADTools module version."
    }
    Process
    {
        if ($leaf)
        {
            $DistinguishedName -replace "^..\s*=\s*(.*?),.*", '$1'
        }
        else
        {
            #$DistinguishedName -replace "^(CN|OU)\s*=\s*[^,]*,", ""
            $DistinguishedName -replace "^..\s*=\s*.*?,(\s*..\s*=)", '$1'
        }
    }
    End
    {
    }
}
