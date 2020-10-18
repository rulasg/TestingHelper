
Write-Host "Loading DummyModule1Test ..." -ForegroundColor DarkCyan

$InstanceId = New-Guid
function Get-InstanceId{
    return $InstanceId
}

function DummyModule1Test_Intro{
    Assert-IsTrue -Condition $true
}

function DummyModule1Test_Description{

    [string] $result = Get-DummyModule1Description

    Assert-AreEqual -Expected "DummyModule1 Description" -Presented $result
    
}