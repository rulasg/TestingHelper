function Assert-Count {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [int] $Expected,
        [Parameter()] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    if (!$Presented) {
        Assert-IsTrue -Condition ($Expected -eq 0) -Comment ("Presented is null expected [{0}]- {1}" -f $Expected, $Comment)
    } else {
        Assert-IsTrue -Condition ($Presented.Count -eq $Expected) -Comment ("Count Expected [{0}] and Presented [{1}] - {2}" -f $Expected,$Presented.Count, $Comment)

    }
}

function Assert-CountTimes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [int] $Expected,
        [Parameter(Mandatory)] [string] $Pattern,
        [Parameter()] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

        if (!$Presented) {
        Assert-IsTrue -Condition ($Expected -eq 0) -Comment ("Presented is null expected [{0}]- {1}" -f $Expected, $Comment)
    } else {
        $iterations = $Presented | Where-Object {$_ -eq $pattern}
        Assert-IsTrue -Condition ($iterations.Count -eq $Expected) -Comment ("Count Expected [{0}] and Presented [{1}] - {2}" -f $Expected,$iterations.Count, $Comment)
    }
}

function Assert-Contains{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter()] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    Test-Assert -Condition (!([string]::IsNullOrEmpty($Expected)) -and ($Presented.Contains($Expected))) -Comment  ("[Assert-Contains] Expected[{0}] present on {1}" -f $Expected, $Presented)

}

function Assert-NotContains{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter()] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert -Condition ([string]::IsNullOrEmpty($Expected)) -Expected $false -Comment "[Assert-Contains] Expected can not be empty"

    Assert-IsTrue -Condition (!($Presented.Contains($Expected))) -Comment  ("[Assert-Contains] Expected[{0}] present on {1}" -f $Expected, $Presented)
}

function Assert-ContainedXOR{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [string] $Expected,
        [Parameter(Mandatory)] [string[]] $PresentedA,
        [Parameter(Mandatory)] [string[]] $PresentedB,
        [Parameter()] [string] $Comment
    )

    process {
        $ga = $PresentedA.contains($Expected)
        $gb = $PresentedB.contains($Expected)
        
        Assert-IsTrue -Condition ( $ga -xor $gb) -Comment ("Assert-ContainedXOR [{0}]" -f ($Expected))
    }
}

function Assert-CollectionIsNotNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][object] $Presented,
        [Parameter()] [string] $Comment
    )

    Test-Assert -Condition (($null -ne $presented) -and ($presented.Count -gt 0)) -Comment:$Comment
}

function Assert-CollectionIsNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][object] $Presented,
        [Parameter()] [string] $Comment
    )

    Test-Assert -Condition (($null -eq $presented) -or ($presented.Count -eq 0)) -Comment:$Comment
}