
function TestingHelperTest_RemoveTestingFile_Root {

    $tested = Get-TestedModuleHandle

    $filename = "Filename.txt"

    #By Path
    New-TestingFile -Name $filename
    
    Assert-ItemExist -Path $filename
    & $tested {Remove-TestingFile -Path "Filename.txt"}
    Assert-ItemNotExist -Path $filename
    
    #By Name
    New-TestingFile -Name $filename
    
    Assert-ItemExist -Path $filename
    & $tested {Remove-TestingFile -Name "Filename.txt"}
    Assert-ItemNotExist -Path $filename
    
    # Hidden
    $file = New-TestingFile -Name $filename -Hidden -PassThru
    
    # skip if in linux as hidden is not supported
    if (-not $IsLinux) {
        Assert-IsTrue -Condition $file.Attributes.HasFlag([System.IO.FileAttributes]::Hidden)
    }

    Assert-ItemExist -Path $filename
}

function TestingHelperTest_RemoveTestingFile_Folder {

    $filename = "Filename.txt"
    $folder = "folder1"

    #By Path
    $file = New-TestingFile -Name $filename -Path $folder -PassThru
    
    Assert-ItemExist -Path $file
    Remove-TT_TestingFile -Path $file.FullName
    Assert-ItemNotExist -Path $file
    
    #By Name
    $file = New-TestingFile -Name $filename -Path $folder -PassThru
    
    Assert-ItemExist -Path $file
    Remove-TT_TestingFile -Name $filename -Path $folder
    Assert-ItemNotExist -Path $file
    
    # Hidden
    $file = New-TestingFile -Name $filename -Path $folder -Hidden -PassThru
    
    # skip if in linux as hidden is not supported
    if (-not $IsLinux) {
        Assert-IsTrue -Condition $file.Attributes.HasFlag([System.IO.FileAttributes]::Hidden)
    }
    
    Assert-ItemExist -Path $file
}

function TestingHelperTest_GetRooTestingFolderPath {
    [CmdletBinding()] param ()

    $result = & $TESTED_HANDLE {GetRooTestingFolderPath}

    $split = ($result | Split-Path -leafbase) -split "_"
    
    Assert-Count -Expected 4 -Presented $split
    Assert-AreEqual -Expected "Temp:" -Presented (Split-Path -Path $result -Qualifier)
    Assert-AreEqual -Expected ("Posh") -Presented $split[0]
    Assert-AreEqual -Expected ("Testing") -Presented $split[1]
    Assert-AreEqual -Expected (Get-Date -Format yyMMdd) -Presented $split[2]
}

function TestingHelperTest_GetRooTestingFolderPath_NotTheSame {
    [CmdletBinding()] param ()

    $result1 = & $TESTED_HANDLE {GetRooTestingFolderPath}
    $result2 = & $TESTED_HANDLE {GetRooTestingFolderPath}

    Assert-AreNotEqual -Expected $result1 -Presented $result2
}
function TestingHelperTest_RemoveTestingFolder_FolderNotExist{
    [CmdletBinding()] param ()

    Remove-TT_TestingFolder -Path "thisPathDoesNotExist"
    
    Assert-IsNull -Object $result
}

function TestingHelperTest_RemoveTestingFolder_Not_TestRunFolder{

    $tested = Get-TestedModuleHandle

    $t = New-Item -Name "NotStandardName" -ItemType Directory

    Assert-ItemExist -Path $t.FullName
    
    $null = & $tested {Remove-TestingFolder -Path ".\NotStandardName"}

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
