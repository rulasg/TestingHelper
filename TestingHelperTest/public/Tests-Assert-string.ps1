

function TestingHelperTest_StringIsNotNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-TT_StringIsNotNullorEmpty -Presented "Some string"

    $hasThrow = $false
    try {
        Assert-TT_StringIsNotNullorEmpty $null
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_StringIsNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-TT_StringIsNullorEmpty -Presented $Null

    $hasThrow = $false
    try {
        Assert-TT_StringIsNullorEmpty -Presented "some string" 
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_StringIsNotNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-TT_StringIsNotNullorEmpty -Presented "Some text"

    $hasThrow = $false
    try {
        Assert-TT_StringIsNotNullorEmpty -Presented ([string]::Empty)
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}
function TestingHelperTest_StringIsNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    Assert-TT_StringIsNullorEmpty -Presented ([string]::Empty)
    Assert-TT_StringIsNullorEmpty -Presented ""

    $hasThrow = $false
    try {
        Assert-TT_StringIsNullorEmpty "some string"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}