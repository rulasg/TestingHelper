function TestingHelperTest_ContainsPath_Success{

    $f1 = New-TestingFile -Path "." -PassThru
    $f2 = New-TestingFile -Path "." -PassThru
    $f3 = New-TestingFile -Path Folder1 -PassThru
    $f4 = New-TestingFile -Path Folder2 -PassThru
    $f5 = New-TestingFile -Path "Folder2/Folder2" -PassThru

    $result = Get-ChildItem -Recurse 
    Assert-Count -Expected 8 -Presented $result

    Assert-TT_ContainsPath -Expected $f5.FullName -Presented $result
    Assert-TT_ContainsPath -Expected $f4.FullName -Presented $result
    Assert-TT_ContainsPath -Expected $f3.FullName -Presented $result
    Assert-TT_ContainsPath -Expected $f2.FullName -Presented $result
    Assert-TT_ContainsPath -Expected $f1.FullName -Presented $result
}

function TestingHelperTest_ContainsPath_Fail{

    $f1 = New-TestingFile -Name Included1 -Path "." -PassThru
    $f2 = New-TestingFile -Name Included2 -Path "." -PassThru
    $f3 = New-TestingFile -Name Excluded3 -Path Folder1 -PassThru
    $f4 = New-TestingFile -Name Included4 -Path Folder2 -PassThru
    $f5 = New-TestingFile -Name Included5 -Path "Folder2/Folder2" -PassThru

    $result = Get-ChildItem Include* -Recurse 
    
    Assert-Count -Expected 4 -Presented $result

    $hasThrow = $false
    try {
        Assert-TT_ContainsPath -Expected $f3.FullName -Presented $result
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_NotContainsPath_Success{

    $f1 = New-TestingFile -Name Excluded1 -Path "." -PassThru
    $f2 = New-TestingFile -Name Included2 -Path "." -PassThru
    $f3 = New-TestingFile -Name Excluded3 -Path Folder1 -PassThru
    $f4 = New-TestingFile -Name Included4 -Path Folder2 -PassThru
    $f5 = New-TestingFile -Name Excluded5 -Path "Folder2/Folder2" -PassThru

    $result = Get-ChildItem Included* -Recurse 
    Assert-Count -Expected 2 -Presented $result

    Assert-TT_NotContainsPath -Expected $f1.FullName -Presented $result
    Assert-TT_NotContainsPath -Expected $f3.FullName -Presented $result
    Assert-TT_NotContainsPath -Expected $f5.FullName -Presented $result
}

function TestingHelperTest_NotContainsPath_Fail{

    $f1 = New-TestingFile -Name Included1 -Path "." -PassThru
    $f2 = New-TestingFile -Name Included2 -Path "." -PassThru
    $f3 = New-TestingFile -Name Excluded3 -Path Folder1 -PassThru
    $f4 = New-TestingFile -Name Included4 -Path Folder2 -PassThru
    $f5 = New-TestingFile -Name Included5 -Path "Folder2/Folder2" -PassThru

    $result = Get-ChildItem Include* -Recurse 
    
    Assert-Count -Expected 4 -Presented $result

    $hasThrow = $false
    try {
        Assert-TT_NotContainsPath -Expected $f4.FullName -Presented $result
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

    Assert-TT_FilesAreEqual -Expected  "file1.txt" -Presented "file2.txt"
    Assert-TT_FilesAreNotEqual -Expected  "file1.txt" -Presented "file3.txt"

    $hasThrow = $false
    try {
        Assert-TT_FilesAreEqual -Expected  "file1.txt" -Presented "file2.txt"
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
        Assert-TT_FilesAreEqual -Expected  "file1.txt" -Presented "file3.txt"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

    $hasThrow = $false
    try {
        Assert-TT_FilesAreNotEqual -Expected  "file1.txt" -Presented "file2.txt"
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

    Assert-TT_FileContains -Path "file1.txt" -Pattern "ModuleVersion = '0.1'"
    Assert-TT_FileContains -Path "file1.txt" -Pattern "RootModule = 'ModuleNameTest.psm1'"
    Assert-TT_FileContains -Path "file1.txt" -Pattern "# Script"
}

function TestingHelperTest_ItemExists_Success{

    $l = Get-Location

    Assert-TT_ItemExist -Path $l.Path

}

function TestingHelperTest_ItemExists_Fail{

    $hasThrow = $false
    try {
        Asset-TT_ItemExist -Path "Thispathdoesnotexist"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}