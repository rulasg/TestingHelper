function TestingHelperTest_Count_Success{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="Third"

    Assert-TT_Count -Expected 3 -Presented $array

}

function TestingHelperTest_Count_Fail{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="Third"

    $hasThrow = $false
    try {
        Assert-TT_Count -Expected 2 -Presented $array
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_CountTimes_Success{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="first"

    Assert-TT_CountTimes -Expected 2 -Presented $array -Pattern "first"

}

function TestingHelperTest_CountTimes_Fail{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="first"

    $hasThrow = $false
    try {
        Assert-TT_CountTimes -Expected 1 -Presented $array -Pattern "first"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_CountTimes_PresentedNull{
    [CmdletBinding()] param ()
    $array = @()
    $array+="first"
    $array+="Second"
    $array+="first"

    Assert-TT_CountTimes -Expected 0 -Presented $null -Pattern "three"

    $hasThrow = $false
    try {
        Assert-TT_CountTimes -Expected 2 -Presented $null -Pattern "first"
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_Contains_Success{
    $array = @(
        "value1","Value2","Value3"
    )

    Assert-TT_Contains -Expected "Value2" -Presented $array
}

function TestingHelperTest_Contains_Fail{

    $array = @(
        "value1","Value2","Value3"
    )

    $hasThrow = $false
    try {
        # value2 is lower case
        Assert-TT_Contains -Expected "value2" -Presented $array
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_NotContains_Success{
    $array = @(
        "value1","Value2","Value3"
    )

    # value2 is lower case
    Assert-TT_NotContains -Expected "value2" -Presented $array
}

function TestingHelperTest_NotContains_Fail{

    $array = @(
        "value1","Value2","Value3"
    )

    $hasThrow = $false
    try {
        Assert-TT_NotContains -Expected "Value2" -Presented $array
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_ContainsXOR_Success{

    $array1 = @("value1","Value2","Value3")
    $array2 = @("Value4","Value5","Value6","Value7")

    Assert-TT_ContainedXOR -Expected "Value2" -PresentedA $array1 -PresentedB $array2
    Assert-TT_ContainedXOR -Expected "Value6" -PresentedA $array1 -PresentedB $array2
    
    "Value6" | Assert-TT_ContainedXOR -PresentedA $array1 -PresentedB $array2
    
    ("Value3","Value4") | Assert-TT_ContainedXOR -PresentedA $array1 -PresentedB $array2
}

function TestingHelperTest_ContainsXOR_Fail{

    $array1 = @("value1","Value2","Value3")
    $array2 = @("Value4","Value5","Value6","Value7")

    $hasThrow = $false
    try {
        Assert-TT_ContainedXOR -Expected "value2" -PresentedA $array1 -PresentedB $array2
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_CollectionIsNotNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-TT_CollectionIsNotNullorEmpty -Presented @("Something")

    $hasThrow = $false
    try {
        Assert-TT_CollectionIsNotNullorEmpty $null
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_CollectionIsNullOrEmpty_Null{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-TT_CollectionIsNullorEmpty -Presented $Null

    $hasThrow = $false
    try {
        Assert-TT_CollectionIsNullorEmpty -Presented @("something")
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_CollectionIsNotNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    # Positive Null
    Assert-TT_CollectionIsNotNullorEmpty -Presented @("value")

    $hasThrow = $false
    try {
            Assert-TT_CollectionIsNotNull -Presented @{}
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_CollectionIsNullOrEmpty_Empty{
    [CmdletBinding()] param ()

    Assert-TT_CollectionIsNullorEmpty -Presented @()

    $hasThrow = $false
    try {
        Assert-TT_CollectionIsNullorEmpty @("something")
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}