
function TestingHelperTest_TraceMessage{

    $text = "random text"

    # Check that the verbose stream has the message
    $result = Trace-TT_Message -Message $text -verbose 4>&1
    
    Assert-Contains -Expected $text -Presented $result
}