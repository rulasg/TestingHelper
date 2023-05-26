
function TestingHelperTest_ImportTestingModule_TargetModule{
    [CmdletBinding()] param ()

    Get-Module -Name $Dummy1* | Remove-Module -Force
    Assert-IsNull -Object (Get-Module -Name $Dummy1*)

    Import-Module -name $DUMMY_1_PATH -Global 

    Import-TT_TestingModule -TargetModule $Dummy1

    Assert-IsNotNull -Object (Get-Module -Name ($Dummy1 +"Test"))

    $instance1 = Get-DummyModule1TestInstanceId

    Import-TT_TestingModule -TargetModule $Dummy1 -Force

    $instance2 = Get-DummyModule1TestInstanceId

    Assert-AreNotEqual -Expected $instance1 -Presented $instance2
}

function TestingHelperTest_ImportTestingModule_TargetModule_NotMatchingVerion{
    [Cmdletbinding()] param ()

    Get-Module -Name $Dummy1* | Remove-Module -Force

    $dummyModule = Import-Module -name $DUMMY_1_PATH -Global -PassThru
    $wrongVersion = "2.5.1"
    
    Import-TT_TestingModule -TargetModule $Dummy1 -TargetModuleVersion $wrongVersion @WarningParameters
    
    Assert-IsNull -Object (Get-Module -Name ($Dummy1 +"Test"))

    Assert-Count -Expected 2 -Presented $WarningVar
    Assert-AreEqual -Presented $WarningVar[1].Message -Expected `
    ("[Import-TestingModule] TargetModule {0} version {1} not matches {2}" -f $Dummy1,$dummyModule.Version, $wrongVersion) 
}

function TestingHelperTest_ImportTestingModule_TargetModule_AlreadyLoaded{
    [Cmdletbinding()] param ()

    Get-Module -Name $Dummy1* | Remove-Module -Force
    Import-Module -name $DUMMY_1_PATH -Global

    Import-TT_TestingModule -TargetModule $Dummy1 @WarningParameters
    
    Assert-IsNotNull -Object (Get-Module -Name ($Dummy1 +"Test"))

    Assert-Count -Expected 1 -Presented $WarningVar
    Assert-AreEqual -Presented $WarningVar[0].Message -Expected ("[Import-TestingModule] TargetModule {0} is already loaded" -f $Dummy1) 
}

function TestingHelperTest_ImportTestingModule_TestingModule {
    [CmdletBinding()] param ()

    $TestDummy1 = $Dummy1 + "Test"

    Import-Module -name $DUMMY_1_PATH -Global

    $modulePath = (Get-Module -Name $Dummy1).Path
    $TestDummyPath = Join-Path -Path (Split-Path -Path $modulePath -Parent) -ChildPath $TestDummy1
    
    Get-Module -Name $Dummy1* | Remove-Module -Force
    Assert-IsNull -Object (Get-Module -Name $Dummy1*)

    Import-TT_TestingModule -Name $TestDummyPath

    Assert-IsNotNull -Object (Get-Module -Name $TestDummy1)

    $instance1 = Get-DummyModule1TestInstanceId

    Import-TT_TestingModule -Name $TestDummyPath -Force

    $instance2 = Get-DummyModule1TestInstanceId

    Assert-AreNotEqual -Expected $instance1 -Presented $instance2

    Get-Module -Name $Dummy1* | Remove-Module -Force

    Assert-IsNull -Object (Get-Module -Name $TestDummy1*)
}