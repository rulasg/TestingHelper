
Write-Host "Loading DummyModule1 ..." -ForegroundColor DarkCyan


function Get-Description {
    
    [CmdletBinding()]
    param ()
    
    Write-Output "DummyModule1 Description dasd"
}

$InstanceId = New-Guid
function Get-InstanceId{
    return $InstanceId
}