# https://swfz.hatenablog.com/entry/2021/05/19/200001

param(
    [string]$Prompt = 'message',
    [string]$Title  = 'notification',
    $CallBack = ''
)

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

function Show-NotifyIcon {
    param(
        [string]$Prompt = 'm',
        [string]$Title  = 'n',
        [scriptblock]$CallBack = {}
    )

    [Windows.Forms.NotifyIcon]$notifyIcon =
        New-Object -TypeName Windows.Forms.NotifyIcon -Property @{
            BalloonTipIcon  = [Windows.Forms.ToolTipIcon]::Info
            BalloonTipText  = $Prompt
            BalloonTipTitle = $Title
            Icon    = [Drawing.SystemIcons]::Information
            Text    = $Title
            Visible = $true
        }

    $notifyIcon.add_BalloonTipClicked( $CallBack )

    [int]$timeout = 3 # sec

    [DateTimeOffset]$finishTime =
        [DateTimeOffset]::UtcNow.AddSeconds( $timeout )

    $notifyIcon.ShowBalloonTip( $timeout )

    while ( [DateTimeOffset]::UtcNow -lt $finishTime ) {
        Start-Sleep -Milliseconds 1
    }
    $notifyIcon.Dispose()
}

$parameters = $MyInvocation.BoundParameters
$parameters.CallBack = [scriptblock]::Create( $CallBack )
Show-NotifyIcon @parameters
