
function Get-PrivateString {
    param (
        [Parameter()][string]$Param1
    )

    return ("Private string [{0}]" -f $param1)
} 