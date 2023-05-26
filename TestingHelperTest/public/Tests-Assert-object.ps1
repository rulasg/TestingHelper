
function TestingHelperTest_IsNotNull{
    [CmdletBinding()] param ()

    $object = [DateTime]::Now
    Assert-TT_IsNotNull -Object $object

    $hasThrow = $false
    try {
            Assert-TT_IsNotNull $null
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_IsNull{
    [CmdletBinding()] param ()

    $object = [DateTime]::Now
    Assert-TT_IsNull -Object $null

    $hasThrow = $false
    try {
        Assert-TT_IsNull $object
    }
    catch {
        $hasThrow = $true
    }

    Assert-IsTrue -Condition $hasThrow
}
function TestingHelperTest_AreEqual{

    $o1 = "stringobject"
    $o2 = $o1

    Assert-TT_AreEqual -Expected $o1 -Presented $o2
    Assert-TT_AreEqual -Expected "string text" -Presented "string text" 


    $hasThrow = $false
    try {
        Assert-TT_AreEqual -Expected "string text 1" -Presented "string text 2" 
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow

}

function TestingHelperTest_AreNotEqual{

    $o1 = "stringobject1"
    $o2 = "string object 2"

    Assert-TT_AreNotEqual -Expected "string text 1 " -Presented "string text 2" 
    Assert-TT_ArenotEqual -Expected $o1 -Presented $o2

    
    $hasThrow = $false
    try {
        Assert-TT_AreNotEqual -Expected "string text" -Presented "string text" 
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}

function TestingHelperTest_AreEqual_Fail{
    
    $o1 = "value object 1"
    $o2 = "value object 2"

    $hasThrow = $false
    try {
        Assert-TT_AreEqual -Expected $o1 -Presented $o2
    }
    catch {
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow
}
