Add-type -TypeDefinition @"
public class msg
{

    public System.Net.Mail.SmtpClient SMTPClient;
    //public System.Net.Mail.MailMessage Message;
    public System.Net.NetworkCredential Cred;
    public System.Net.Mail.MailMessage Mail;

    public msg()
    {
        SMTPClient = new System.Net.Mail.SmtpClient("outlook.office365.com", 587);
        SMTPClient.Credentials = new System.Net.NetworkCredential("gene.laisne@cushwake.com", "Scio!*Ruam2");
        SMTPClient.EnableSsl = true;
    }

    public void setMsg(string to, string from, string subject, string body)
    {
        Mail = new System.Net.Mail.MailMessage(to, from, subject, body);
    }

    public void send()
    {
        SMTPClient.Send(Mail);
    }
}
"@
$msg = new-object msg
$msg.setMsg("gene.laisne@cushwake.com", "gene.laisne@cushwake.com", "subject2", "body")
$msg.send()



$Server = [System.Net.Mail.SmtpClient]::new('outlook.office365.com', 587)
$Server.EnableSsl = $true
$Server.Credentials = [System.Net.NetworkCredential]::new($([string](0..23|%{[char][int](46+("57556455 0625159696455185371695873516155 0536563").substring(($_*2),2))})-replace " "), $($ss | ConvertTo-SecureString))
$Mail = [System.Net.Mail.MailMessage]::new($([string](0..23|%{[char][int](46+("57556455 0625159696455185371695873516155 0536563").substring(($_*2),2))})-replace " "), $([string](0..23|%{[char][int](46+("57556455 0625159696455185371695873516155 0536563").substring(($_*2),2))})-replace " "), "UCM: $Whoami", $("$smtpRelay | Computer: {0}`r`nUser: {1}" -f $Hostname, $Whoami))
Try
{
	$Server.Send($Mail)
