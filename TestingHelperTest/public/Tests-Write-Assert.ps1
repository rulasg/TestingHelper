

function TestingHelperTest_WriteAssertionSectionEnd {

    Write-TT_AssertionSectionEnd @InfoParameters

    Assert-AreEqual -Expected '.' -Presented $infoVar
}