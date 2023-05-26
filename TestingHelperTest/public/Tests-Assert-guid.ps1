function TestingHelperTest_IsGuid_Success {
    [CmdletBinding()] param ()

     Assert-TT_IsGuid -Presented (New-Guid).ToString()
}
function TestingHelperTest_IsGuid_Fail {
    [CmdletBinding()] param ()

    $hasThrow = $false
    try {
        Asset-TT_IsGuid -Presented "NotAValidGuid"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}