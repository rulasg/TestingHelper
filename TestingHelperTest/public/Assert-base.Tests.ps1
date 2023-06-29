function TestingHelperTest_IsFalse{
    [CmdletBinding()] param ()

    Assert-TT_IsFalse -Condition $false
    $hasThrow = $false
    try {
        Assert-TT_Isfalse -Condition $true
    } catch { 
        Write-Verbose -Message "Did throw"
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_IsTrue{
    [CmdletBinding()] param ()

    Assert-TT_IsTrue -Condition $true
    $hasThrow = $false
    try {
        Assert-TT_IsTrue -Condition $false
    } catch { 
        Write-Verbose -Message "Did throw"
        $hasthrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}