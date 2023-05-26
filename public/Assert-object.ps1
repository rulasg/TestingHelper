function Assert-IsNotNull {
    [CmdletBinding()]
    param (
        $Object,
        $Comment
    )

    Assert-IsFalse -Condition ($null -eq $Object) -Comment ("Object is null -" + $Comment)
}

function Assert-IsNull {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)] $Object,
        $Comment
    )


    Assert-IsTrue -Condition ($null -eq $Object) -Comment ("Object not null -" + $Comment)
}

function Assert-AreEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    Assert-IsTrue -Condition ($Expected -eq $Presented) -Comment ("Object are not Equal : Expected [ $Expected ] and presented [ $Presented ] - " + $Comment)
}

function Assert-AreNotEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsFalse -Condition ($Expected -eq $Presented) -Comment ("Object are Equal : Expecte [ $Expected ] and presented [ $Presented ] - " + $Comment)
}

function Assert-AreEqualContent{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    $hashEx = Get-FileHash -Path $ex
    $hashPr = Get-FileHash -Path $pr

    Assert-AreEqual -Expected $hashEx -Presented $hashPr 
}

function Assert-AreNotEqualContent{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    $hashEx = Get-FileHash -Path $ex
    $hashPr = Get-FileHash -Path $pr

    Assert-AreNotEqual -Expected $hashEx -Presented $hashPr  
}