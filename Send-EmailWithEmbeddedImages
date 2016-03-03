function Send-Email
{
<#
.Synopsis
   Sends an email message.
.DESCRIPTION
   Sends an email message.
.EXAMPLE
   Send-email -to @('gene.laisne@dtz.com','Matthew.Hallenborg@dtz.com') -from 'gene.laisne@dtz.com' -Subject 'Let me know if you get this.' -Body 'Let me know if you get this.' -SmtpServer 'domrelay.na.ugllimited.com' -Attachment @('C:\data\Transcripts_20141110083748.txt','C:\data\Transcripts_20141208081451.txt') -LogFile 'c:\temp\logfile.log'

   this example will send email to 2 users and include 2 attacment files.
#>

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String[]] $To,
        [Parameter(Mandatory=$true,
                   Position=1)]
        [String] $From,
        [Parameter(Position=2)]
        [String] $Subject,
        [Parameter(Position=3)]
        [String] $Body,
        [switch] $IsBodyHtml,
        [string[]] $Cc,
        [string[]] $Bcc,
        [String] $SmtpServer,
        [String[]] $Attachment,
        [switch] $EnableSsl ,
        [String] $LogFile,
        [string[]] $EmbeddedImage
    )

    if ($PSBoundParameters.ContainsKey('Logfile'))
    {
        $LogEvents = $true
    }
    else
    {
        $LogEvents = $false
    }

    function LogEvent($LogLine)
    {
        $dateString = "$([datetime]::Now.ToShortDateString()) $([datetime]::now.ToLongTimeString())"
        "[$dateString] $LogLine" | Out-File -FilePath $LogFile -Encoding ascii -Append
    }

    $msg = new-object Net.Mail.MailMessage
    $smtp = new-object Net.Mail.SmtpClient($smtpServer)


    #
    #    To
    #

    foreach ($entry in $To)
    {
        $msg.To.Add($entry)
    }


    #
    #    CC
    #

    if ($PSBoundParameters.ContainsKey('Cc'))
    {
        foreach ($entry in $Cc)
        {
            $msg.CC.Add($entry)
        }
    }


    #
    #    Bcc
    #
    
    if ($PSBoundParameters.ContainsKey('Bcc'))
    {
        foreach ($entry in $Bcc)
        {
            $msg.Bcc.Add($entry)
        }
    }


    #
    #    Attach attachments
    #

    if ($PSBoundParameters.ContainsKey('Attachment'))
    {
        foreach ($att in $Attachment)
        {
            if (-Not $(test-path $att) -and $LogEvents)
            {
                if ($LogEvents)
                {
                    LogEvent -LogLine "Unable to add attachement file ($att): File not found"
                }
            }
            else
            {
                Try
                {
                    $NewAttachment = new-object Net.Mail.Attachment($att)
                    $msg.Attachments.Add($NewAttachment)
                }
                Catch [System.Management.Automation.RuntimeException]
                {
                    $Err = $_
                    if ($LogEvents)
                    {
                        LogEvent -LogLine "Unable to add attachement file ($att): $($Err.Exception.Message)"
                    }
                    Write-Error "$($Err.Exception.Message)`nException: $($Err.Exception.GetType().FullName)"
                }
                Catch
                {
                    $Err = $_
                    if ($LogEvents)
                    {
                        LogEvent -LogLine "Unable to add attachement file ($att): $($Err.Exception.Message)"
                    }
                    write-Error $Err.Exception.Message
                }

            }
        }
    }

    #ImbeddedImages
    Foreach($Imagefile in $EmbeddedImage)
    {
        if ($Imagefile -eq $null)
        {
            Continue
        }

        Try
        {
            $NewAttachment = new-object Net.Mail.Attachment($Imagefile)
            $NewAttachment.ContentDisposition.Inline = $True
            $NewAttachment.ContentDisposition.DispositionType = "Inline"
            $NewAttachment.ContentType.MediaType = "image/jpg"
            $NewAttachment.ContentId = $Imagefile #.ToString()

            $msg.Attachments.Add($NewAttachment)
        }
        Catch [System.Management.Automation.RuntimeException]
        {
            $Err = $_
            if ($LogEvents)
            {
                LogEvent -LogLine "Unable to add Embedded image ($Imagefile): $($Err.Exception.Message)"
            }
            Write-Error "$($Err.Exception.Message)`nException: $($Err.Exception.GetType().FullName)"
        }
        Catch
        {
            $Err = $_
            if ($LogEvents)
            {
                LogEvent -LogLine "Unable to add Embedded image ($Imagefile): $($Err.Exception.Message)"
            }
            write-Error $Err.Exception.Message
        }
 
 <#
        $attachment = New-Object System.Net.Mail.Attachment –ArgumentList $Imagefile #.ToString() #convert file-system object type to string
        $attachment.ContentDisposition.Inline = $True
        $attachment.ContentDisposition.DispositionType = "Inline"
        $attachment.ContentType.MediaType = "image/jpg"
        $attachment.ContentId = $Imagefile #.ToString()
        $msg.Attachments.Add($attachment)
 #>
    }


    if ($IsBodyHtml)
    {
        $msg.IsBodyHtml = $true
    }

    $msg.Subject = $Subject
    $msg.Body = $Body
    $Msg.From = $From

    if ($EnableSsl)
    {
        $smtp.EnableSsl = $True
    }

    $EAP = $ErrorActionPreference
    try
    {
        $ErrorActionPreference = 'Stop'
        $smtp.Send($msg)
    }
    catch [System.Management.Automation.RuntimeException]
    {
        $err = $_
        if ($LogEvents)
        {
            LogEvent -LogLine "Unable to send email. Error: ($($Err.Exception.GetType().FullName)) $($Err.Exception.Message)"
        }
        else
        {
            write-error "Unable to send email. Error: ($($Err.Exception.GetType().FullName)) $($Err.Exception.Message)"
        }
    }
    catch
    {
        $err = $_
        if ($LogEvents)
        {
            LogEvent -LogLine "Unable to send email. Error: $($Err.Exception.Message)"
        }
        else
        {
            write-error "Unable to send email. Error: ($($Err.Exception.GetType().FullName)) $($Err.Exception.Message)"
        }
    }

    $ErrorActionPreference = $EAP
    
}
