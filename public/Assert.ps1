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

function Write-AssertionDot {
    [CmdletBinding()]
    param ( 
        [Parameter()] [string] $Color
    )
    Write-Host "." -NoNewline -ForegroundColor $Color
}

function Write-AssertionSectionEnd{
    Write-AssertionDot -Color Yellow
}