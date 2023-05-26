function Assert-AreEqualPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    Assert-AreEqual -Expected $ex -Presented $pr -Comment ("Path not equal - " + $Comment)
}

function Assert-AreNotEqualPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    Assert-AreNotEqual -Expected $ex -Presented $pr -Comment ("Path equal - " + $Comment)
}

function Assert-ContainsPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ $Presented | Convert-Path} else {$Presented}

    Assert-Contains -Expected $ex -Presented $pr -Comment ("Path not contained - " + $Comment)
}

function Assert-NotContainsPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ $Presented | Convert-Path} else {$Presented}

    Assert-NotContains -Expected $ex -Presented $pr -Comment ("Path not contained - " + $Comment)
}

function Assert-ItemExist {
    param(
        [string] $Path
    )
    Assert-IsNotNull -Object $Path -Comment "[Assert-ItemExist] Path is empty"
    Assert-IsTrue -Condition ($Path | Test-Path)
}

function Assert-ItemNotExist {
    param(
        [string] $Path
        )
        
    Assert-IsNotNull -Object $Path -Comment "[Assert-ItemNotExist] Path is empty"
    Assert-IsFalse -Condition ($Path | Test-Path)
}

function Assert-FileContains{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Object] $Path,
        [Parameter(Mandatory)][Object] $Pattern,
        [Parameter()] [string] $Comment

    )

    $SEL = Select-String -Path $Path -Pattern $Pattern

    Assert-IsTrue -Condition ($null -ne $SEL) -Comment ("Files contains - " + $Comment)
}

function Assert-FilesAreEqual{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = $Expected | Get-FileHash
    $pr = $Presented | Get-FileHash

    Assert-AreEqual -Expected $ex.Hash -Presented $pr.Hash -Comment ("Files not equal - " + $Comment)
}

function Assert-FilesAreNotEqual{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = $Expected | Get-FileHash
    $pr = $Presented | Get-FileHash

    Assert-AreNotEqual -Expected $ex.Hash -Presented $pr.Hash -Comment ("Files equal - " + $Comment)
}