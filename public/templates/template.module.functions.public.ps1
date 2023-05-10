
function Get-PublicString {
    param (
        [Parameter()][string]$Param1
    )

    return ("Public string [{0}]" -f $param1)
} Export-ModuleMember -Function Get-PublicString