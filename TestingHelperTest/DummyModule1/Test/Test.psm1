
Write-Host "Loading Test ..." -ForegroundColor DarkYellow

$InstanceId = New-Guid
function Get-InstanceId{
    return $InstanceId
}

function Test_Intro{
    Assert-IsTrue -Condition $true
}

function Test_Description{

    [string] $result = Get-DummyModule1Description

    Assert-AreEqual -Expected "DummyModule1 Description" -Presented $result
    
}