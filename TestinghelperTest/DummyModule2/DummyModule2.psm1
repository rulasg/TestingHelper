
Write-Host "Loading DummyModule2 ..." -ForegroundColor DarkCyan

function Get-Description {

    [CmdletBinding()]
    param ()
    
    Write-Output "DummyModule2 Description"
}

$InstanceId = New-Guid
function Get-InstanceId{
    return $InstanceId
}