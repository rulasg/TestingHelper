using Module .\TestingHelperTestHelper.psm1

Write-Host "Loading TestingHelperTest ..." -ForegroundColor DarkYellow

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

function TestingHelperTest_FileContains{
    $content =
@'

This is text that will be part of this file
We add different lines
and compare within the file

# Script module or binary module file associated with this manifest.
RootModule = 'ModuleNameTest.psm1'

# Version number of this module.
ModuleVersion = '0.1'

for some content
$Value
'@
    $content | Out-File -FilePath "file1.txt"

    Assert-FileContains -Path "file1.txt" -Pattern "ModuleVersion = '0.1'"
    Assert-FileContains -Path "file1.txt" -Pattern "RootModule = 'ModuleNameTest.psm1'"
    Assert-FileContains -Path "file1.txt" -Pattern "# Script"
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

function TestingHelperTest_CountTimes_Success{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="first"

    Assert-CountTimes -Expected 2 -Presented $array -Pattern "first"

}
function TestingHelperTest_CountTimes_Fail{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="first"

    $hasThrow = $false
    try {
        Assert-CountTimes -Expected 1 -Presented $array -Pattern "first"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_CountTimes_PresentedNull{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="first"

    Assert-CountTimes -Expected 0 -Presented $null -Pattern "three"

    $hasThrow = $false
    try {
        Assert-CountTimes -Expected 2 -Presented $null -Pattern "first"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}
function TestingHelperTest_Contains_Success{
    $array = @(
        "value1","Value2","Value3"
    )

    Assert-Contains -Expected "Value2" -Presented $array
}

function TestingHelperTest_Contains_Fail{

    $array = @(
        "value1","Value2","Value3"
    )

    $hasThrow = $false
    try {
        # value2 is lower case
        Assert-Contains -Expected "value2" -Presented $array
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_NotContains_Success{
    $array = @(
        "value1","Value2","Value3"
    )

    # value2 is lower case
    Assert-NotContains -Expected "value2" -Presented $array
}

function TestingHelperTest_NotContains_Fail{

    $array = @(
        "value1","Value2","Value3"
    )

    $hasThrow = $false
    try {
        Assert-NotContains -Expected "Value2" -Presented $array
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_ContainsXOR_Success{

    $array1 = @("value1","Value2","Value3")
    $array2 = @("Value4","Value5","Value6","Value7")

    Assert-ContainedXOR -Expected "Value2" -PresentedA $array1 -PresentedB $array2
    Assert-ContainedXOR -Expected "Value6" -PresentedA $array1 -PresentedB $array2
    
    "Value6" | Assert-ContainedXOR -PresentedA $array1 -PresentedB $array2
    
    ("Value3","Value4") | Assert-ContainedXOR -PresentedA $array1 -PresentedB $array2
}

function TestingHelperTest_ContainsXOR_Fail{

    $array1 = @("value1","Value2","Value3")
    $array2 = @("Value4","Value5","Value6","Value7")

    $hasThrow = $false
    try {
        Assert-ContainedXOR -Expected "value2" -PresentedA $array1 -PresentedB $array2
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_StringIsNotNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-StringIsNotNullorEmpty -Presented "Some string"

    $hasThrow = $false
    try {
        Assert-StringIsNotNullorEmpty $null
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_StringIsNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-StringIsNullorEmpty -Presented $Null

    $hasThrow = $false
    try {
        Assert-StringIsNullorEmpty -Presented "some string" 
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_StringIsNotNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-StringIsNotNullorEmpty -Presented "Some text"

    $hasThrow = $false
    try {
            Assert-IsNotNull -Presented [string]::Empty
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}
function TestingHelperTest_StringIsNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    Assert-StringIsNullorEmpty -Presented ([string]::Empty)
    Assert-StringIsNullorEmpty -Presented ""

    $hasThrow = $false
    try {
        Assert-StringIsNullorEmpty "some string"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_CollectionIsNotNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-CollectionIsNotNullorEmpty -Presented @("Something")

    $hasThrow = $false
    try {
        Assert-CollectionIsNotNullorEmpty $null
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_CollectionIsNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-CollectionIsNullorEmpty -Presented $Null

    $hasThrow = $false
    try {
        Assert-CollectionIsNullorEmpty -Presented @("something")
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_CollectionIsNotNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-CollectionIsNotNullorEmpty -Presented @("value")

    $hasThrow = $false
    try {
            Assert-CollectionIsNotNull -Presented @{}
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}
function TestingHelperTest_CollectionIsNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    Assert-CollectionIsNullorEmpty -Presented @()

    $hasThrow = $false
    try {
        Assert-CollectionIsNullorEmpty @("something")
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

######################################

function TestingHelperTest_RemoveTestingFile_Root {

    $filename = "Filename.txt"

    #By Path
    New-TestingFile -Name $filename
    
    Assert-ItemExist -Path $filename
    Remove-TestingFile -Path $filename
    Assert-ItemNotExist -Path $filename
    
    #By Name
    New-TestingFile -Name $filename
    
    Assert-ItemExist -Path $filename
    Remove-TestingFile -Name $filename
    Assert-ItemNotExist -Path $filename
    
    # Hidden
    $file = New-TestingFile -Name $filename -Hidden -PassThru
    
    # skip if in linux as hidden is not supported
    if (-not $IsLinux) {
        Assert-IsTrue -Condition $file.Attributes.HasFlag([System.IO.FileAttributes]::Hidden)
    }

    Assert-ItemExist -Path $filename
    Remove-TestingFile -Path $filename
    Assert-ItemNotExist -Path $filename
}

function TestingHelperTest_RemoveTestingFile_Folder {

    $filename = "Filename.txt"
    $folder = "folder1"

    #By Path
    $file = New-TestingFile -Name $filename -Path $folder -PassThru
    
    Assert-ItemExist -Path $file
    Remove-TestingFile -Path $file.FullName
    Assert-ItemNotExist -Path $file
    
    #By Name
    $file = New-TestingFile -Name $filename -Path $folder -PassThru
    
    Assert-ItemExist -Path $file
    Remove-TestingFile -Name $filename -Path $folder
    Assert-ItemNotExist -Path $file
    
    # Hidden
    $file = New-TestingFile -Name $filename -Path $folder -Hidden -PassThru
    
    # skip if in linux as hidden is not supported
    if (-not $IsLinux) {
        Assert-IsTrue -Condition $file.Attributes.HasFlag([System.IO.FileAttributes]::Hidden)
    }
    
    Assert-ItemExist -Path $file
    Remove-TestingFile -Name $filename -Path $folder
    Assert-ItemNotExist -Path $file
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

    Assert-ItemExist -Path $t

    $t | Remove-Item
    
    Assert-itemNotExist -Path $t
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

function TestingHelperTest_NewModule{
    New-Module -Name "ModuleName" -Description "description of the Module"

    $psdPath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath  ModuleName.psd1
    $psmPath = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath  ModuleName.psm1

    Assert-ItemExist -Path $psdPath
    Assert-ItemExist -Path $psmPath

    Assert-FileContains -Path $psdPath -Pattern "RootModule = 'ModuleName.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPath -Pattern "ModuleVersion = '0.1'" -Comment "Version"
    
    Assert-FileContains -Path $psmPath -Pattern "NAME  : ModuleName.psm1*" -Comment ".Notes Name"
    Assert-FileContains -Path $psmPath -Pattern "description of the Module" -Comment "Description"

    # Test module
    $ps1PathTest = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest.ps1
    $psdPathTest = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest , ModuleNameTest.psd1
    $psmPathTest = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ModuleNameTest , ModuleNameTest.psm1

    Assert-ItemExist -Path $ps1PathTest
    Assert-ItemExist -Path $psdPathTest
    Assert-ItemExist -Path $psmPathTest

    Assert-FileContains -Path $psdPathTest -Pattern "RootModule = 'ModuleNameTest.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPathTest -Pattern "ModuleVersion = '0.1'"
    
    Assert-FileContains -Path $psmPathTest -Pattern "function ModuleNameTest_Sample()" -Comment "Function header"
    Assert-FileContains -Path $psmPathTest -Pattern "Export-ModuleMember -Function ModuleNameTest_*" -Comment "Export"

    #vscode/Launch.json
    $launchFile = Join-Path -Path . -ChildPath ModuleName -AdditionalChildPath ".vscode" , "launch.json"

    Assert-ItemExist -Path $launchFile -Comment "launch.json exists"
    $json = Get-Content -Path $launchFile | ConvertFrom-Json

    Assert-IsTrue -Condition ($json.configurations.Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations.Script -eq '${workspaceFolder}/ModuleNameTest.ps1')
    Assert-IsTrue -Condition ($json.configurations.cwd -eq '${workspaceFolder}')
    Assert-IsTrue -Condition ($json.configurations.type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations.name -like '*ModuleName.ps1')


}

function TestingHelperTest_NewTestingModule{
    New-TestingModule -ModuleName "ModuleName" -Path .

    $psdPathTest = Join-Path -Path . -ChildPath ModuleNameTest -AdditionalChildPath  ModuleNameTest.psd1
    $psmPathTest = Join-Path -Path . -ChildPath ModuleNameTest -AdditionalChildPath  ModuleNameTest.psm1

    Assert-ItemExist -Path "ModuleNameTest.ps1"
    Assert-ItemExist -Path $psdPathTest
    Assert-ItemExist -Path $psmPathTest

    Assert-FileContains -Path $psdPathTest -Pattern "RootModule = 'ModuleNameTest.psm1'" -Comment "RootModule"
    Assert-FileContains -Path $psdPathTest -Pattern "ModuleVersion = '0.1'"
    
    Assert-FileContains -Path $psmPathTest -Pattern "function ModuleNameTest_Sample()" -Comment "Function header"
    Assert-FileContains -Path $psmPathTest -Pattern "Export-ModuleMember -Function ModuleNameTest_*" -Comment "Export"
}

function TestingHelperTest_NewTestingVsCodeLaunchJson{
    New-TestingVsCodeLaunchJson -Path . -ModuleName "ModuleName"

    $launchFile = Join-Path -Path . -ChildPath ".vscode" -AdditionalChildPath "launch.json"

    Assert-ItemExist -Path $launchFile -Comment "launch.json exists"
    $json = Get-Content -Path $launchFile | ConvertFrom-Json

    Assert-IsTrue -Condition ($json.configurations.Request -eq "launch")
    Assert-IsTrue -Condition ($json.configurations.Script -eq '${workspaceFolder}/ModuleNameTest.ps1')
    Assert-IsTrue -Condition ($json.configurations.cwd -eq '${workspaceFolder}')
    Assert-IsTrue -Condition ($json.configurations.type -eq 'PowerShell')
    Assert-IsTrue -Condition ($json.configurations.name -like '*ModuleName.ps1')
}
