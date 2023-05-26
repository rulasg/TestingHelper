function TestingHelperTest_Assert{
    [CmdletBinding()]
    param ()

    $tested = Get-TestedModuleHandle

    & $tested {

        Assert -Condition $true 
        Assert -Condition $true -Expected $true
        Assert -Condition $false -Expected $false
    }

    $hasThrow = $false
    try {
        & $tested {
            Assert -Condition $false
        }
    } catch { 
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

    $hasThrow = $false
    try {
        & $tested {
            Assert -Condition $true -Expected $false
        }
    } catch { 
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}