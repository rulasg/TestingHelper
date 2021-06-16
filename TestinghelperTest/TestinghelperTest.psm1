using Module .\TestingHelperTestHelper.psm1

Write-Host "Loading TestingHelperTest ..." -ForegroundColor DarkCyan

# N3ed to match the value of variable of same name of TestHelper
Set-Variable -Name TestRunFolderName -Value "TestRunFolder"
Set-Variable -Name RootTestingFolder -Value "Temp:/P"

$moduleRootPath = $MyInvocation.MyCommand.Path | Split-Path -Parent
if (-not $env:PSModulePath.Contains($moduleRootPath)) {
    Add-PSModulePath -Path $moduleRootPath
}

$Dummy1 = "DummyModule1"

function TestingHelperTest_Assert
{
    [CmdletBinding()]
    param ()

    Write-Verbose -Message "TestingHelperTest_Assert..."

    Assert -Condition $true 
    Assert -Condition $true -Expected $true
    Assert -Condition $false -Expected $false

    $hasThrow = $false
    try {
        Assert -Condition $false
    } catch { 
        Write-Verbose -Message "Did throw"
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
    
    $hasThrow = $false
    try {
        Assert -Condition $true -Expected $false
    } catch { 
        Write-Verbose -Message "Did throw"
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_IsFalse
{
    [CmdletBinding()] param ()

    Assert-IsFalse -Condition $false
    $hasThrow = $false
    try {
        Assert-Isfalse -Condition $true
    } catch { 
        Write-Verbose -Message "Did throw"
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_IsTrue
{
    [CmdletBinding()] param ()

    Assert-IsTrue -Condition $true
    $hasThrow = $false
    try {
        Assert-IsTrue -Condition $false
    } catch { 
        Write-Verbose -Message "Did throw"
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_IsNotNull
{
    [CmdletBinding()] param ()

    $object = [DateTime]::Now
    Assert-IsNotNull -Object $object

    $hasThrow = $false
    try {
            Assert-IsNotNull $null
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_IsNull
{
    [CmdletBinding()] param ()

    $object = [DateTime]::Now
    Assert-IsNull -Object $null

    $hasThrow = $false
    try {
            Assert-IsNull $object
    }
    catch {
        $hasThrow = $true
    }

    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_AreEqual{

    $o1 = "stringobject"
    $o2 = $o1

    Assert-AreEqual -Expected $o1 -Presented $o2
    Assert-AreEqual -Expected "string text" -Presented "string text" 


    $hasThrow = $false
    try {
        Assert-AreEqual -Expected "string text 1" -Presented "string text 2" 
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_AreNotEqual{

    $o1 = "stringobject1"
    $o2 = "string object 2"

    Assert-AreNotEqual -Expected "string text 1 " -Presented "string text 2" 
    Assert-ArenotEqual -Expected $o1 -Presented $o2

    
    $hasThrow = $false
    try {
        Assert-AreNotEqual -Expected "string text" -Presented "string text" 
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_AreEqual_Fail{
    
    $o1 = "value object 1"
    $o2 = "value object 2"

    $hasThrow = $false
    try {
            Assert-AreEqual -Expected $o1 -Presented $o2
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_FilesAreEqual{
    
    "content of the file rajksljkjralksr" | Out-File -FilePath "file1.txt"
    "content of the file rajksljkjralksr" | Out-File -FilePath "file2.txt"
    "Other   of the file rajksljkjralksr" | Out-File -FilePath "file3.txt"

    Assert-FilesAreEqual -Expected  "file1.txt" -Presented "file2.txt"
    Assert-FilesAreNotEqual -Expected  "file1.txt" -Presented "file3.txt"

    $hasThrow = $false
    try {
        Assert-FilesAreEqual -Expected  "file1.txt" -Presented "file2.txt"

    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_FilesAreEqual{
    "content of the file rajksljkjralksr" | Out-File -FilePath "file1.txt"
    "content of the file rajksljkjralksr" | Out-File -FilePath "file2.txt"
    "Other   of the file rajksljkjralksr" | Out-File -FilePath "file3.txt"

    $hasThrow = $false
    try {
        Assert-FilesAreEqual -Expected  "file1.txt" -Presented "file3.txt"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

    $hasThrow = $false
    try {
        Assert-FilesAreNotEqual -Expected  "file1.txt" -Presented "file2.txt"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}
function TestingHelperTest_ItemExists_Success{

    $l = Get-Location

    Assert-ItemExist -Path $l.Path

}

function TestingHelperTest_ItemExists_Fail{

    $hasThrow = $false
    try {
            Asset-ItemExist -Path "Thispathdoesnotexist"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}


function TestingHelperTest_IsGuid_Success {
    [CmdletBinding()] param ()

     Assert-IsGuid -Presented (New-Guid).ToString()
}
function TestingHelperTest_IsGuid_Fail {
    [CmdletBinding()] param ()

    $hasThrow = $false
    try {
        Asset-IsGuid -Presented "NotAValidGuid"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_Count_Success{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="Third"

    Assert-Count -Expected 3 -Presented $array

}
function TestingHelperTest_Count_Fail{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="Third"

    $hasThrow = $false
    try {
        Assert-Count -Expected 2 -Presented $array
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_GetRooTestingFolderPath {
    [CmdletBinding()] param ()

    $f = Import-Module  -Name TestingHelper -PassThru
    $result = & $f {GetRooTestingFolderPath}

    Assert-AreEqual -Expected "Temp:" -Presented (Split-Path -Path $result -Qualifier)
}
function TestingHelperTest_RemoveTestingFolder_FolderNotExist{

        Assert-IsNull( Remove-TestingFolder -Path "thisPathDoesNotExist")
}

function TestingHelperTest_RemoveTestingFolder_Not_TestRunFolder{

    $t = New-Item -Name "NotStandardName" -ItemType Directory

    Assert-ItemExist -Path $t.FullName

    Remove-TestingFolder -Path ".\NotStandardName"

    Assert-ItemExist -Path $t.Name

    $t | Remove-Item
    
    Assert-itemNotExist -Path $t.Path
}

function TestingHelperTest_RemoveTestingFolder_Recurse{
    [CmdletBinding()] param ()

    $TestRoot = Join-Path -Path (Get-Location) -ChildPath (New-Guid).Guid
    $runfolder = Join-Path -Path $TestRoot -ChildPath "TestRunFolder"
    New-TestingFolder -Path $runfolder
    $rootFolder = $runfolder | Resolve-Path
    
    $folder = $rootFolder

    1..4 | ForEach-Object{
        $folder = Join-Path -Path $folder -ChildPath "TestRunFolder"
        New-TestingFolder -Path $folder
        "Text to write on teting file" | Out-File -Path (Join-Path -Path $folder -ChildPath ("file"+ $_  + ".txt") )
    }

    Assert-AreEqual -Expected 4 -Presented ((Get-ChildItem -Path $tf -Filter file*.txt -Recurse -File).Count)

    Remove-TestingFolder -Path $runfolder
    Assert-ItemNotExist -Path $runfolder

    Remove-Item -Path $TestRoot
    Assert-ItemNotExist -Path $TestRoot
}

function TestingHelperTest_ImportTestingModule_TargetModule{
    [CmdletBinding()] param ()

    Get-Module -Name $Dummy1* | Remove-Module -Force
    Assert-IsNull -Object (Get-Module -Name $Dummy1*)

    Import-TestingModule -TargetModule $Dummy1

    Assert-IsNotNull -Object (Get-Module -Name ($Dummy1 +"Test"))

    $instance1 = Get-DummyModule1TestInstanceId

    Import-TestingModule -TargetModule $Dummy1 -Force

    $instance2 = Get-DummyModule1TestInstanceId

    Assert-AreNotEqual -Expected $instance1 -Presented $instance2
}

function TestingHelperTest_ImportTestingModule_TestingModule {
    [CmdletBinding()] param ()

    $TestDummy1 = Get-TestingModuleName -TargetModule $Dummy1

    Import-Module -Name $Dummy1
    $modulePath = (Get-Module -Name $Dummy1).Path
    $TestDummyPath = Join-Path -Path (Split-Path -Path $modulePath -Parent) -ChildPath $TestDummy1
    
    Get-Module -Name $Dummy1* | Remove-Module -Force
    Assert-IsNull -Object (Get-Module -Name $Dummy1*)

    Import-TestingModule -Name $TestDummyPath

    Assert-IsNotNull -Object (Get-Module -Name $TestDummy1)

    $instance1 = Get-DummyModule1TestInstanceId

    Import-TestingModule -Name $TestDummyPath -Force

    $instance2 = Get-DummyModule1TestInstanceId

    Assert-AreNotEqual -Expected $instance1 -Presented $instance2

    Get-Module -Name $Dummy1* | Remove-Module -Force

    Assert-IsNull -Object (Get-Module -Name $TestDummy1*)
}

function TestingHelperTest_ImportTargetModule{
    [CmdletBinding()] param ()

    Get-Module -Name $Dummy1* | Remove-Module -Force
    Assert-IsNull -Object (Get-Module -Name $Dummy1*)

    Import-TargetModule -Name $Dummy1
    Assert-IsNotNull -Object (Get-Module -Name $Dummy1)

    $instance1 = Get-DummyModule1InstanceId
    Import-TargetModule -Name $Dummy1
    $instance2 = Get-DummyModule1InstanceId
    Assert-AreEqual -Expected $instance1 -Presented $instance2

    Import-TargetModule -Name $Dummy1 -Force
    $instance3 = Get-DummyModule1InstanceId

    Assert-AreNotEqual -Expected $instance1 -Presented $instance3

    Get-Module -Name $Dummy1* | Remove-Module -Force
    Assert-IsNull -Object (Get-Module -Name $Dummy1*)
}


