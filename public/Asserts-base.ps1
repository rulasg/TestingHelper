function Assert-NotImplemented {

    throw "NOT_IMPLEMENTED"
} Export-ModuleMember -Function Assert-NotImplemented

function Assert-SkipTest{
    throw "SKIP_TEST"
} Export-ModuleMember -Function Assert-SkipTest

function Assert-IsTrue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)] [bool] $Condition,
        [Parameter()][string] $Comment
    )
    Assert -Condition $Condition -Expected $true -Comment:$Comment
} Export-ModuleMember -Function Assert-IsTrue

function Assert-IsFalse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)] [bool] $Condition,
        [Parameter()][string] $Comment
    )
    Assert -Condition $Condition -Expected $false -Comment:$Comment
} Export-ModuleMember -Function Assert-IsFalse

