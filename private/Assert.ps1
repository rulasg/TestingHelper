function Test-Assert {
    [CmdletBinding()]
    [Alias("Assert")]
    param (
        [Parameter(Mandatory)] [bool] $Condition,
        [Parameter()][bool] $Expected = $true,
        [Parameter()][string]$Comment = "No Comment"
    )
    
    Write-Verbose -Message "Assert -Condition $Condition -Expected $Expected - $Comment"
    if ($Condition -ne $Expected) {
        throw "Assertion - Found [ $Condition ] Expected [ $Expected ] - $Comment"
    }
    else {
        Write-AssertionDot -Color DarkMagenta
    }
}