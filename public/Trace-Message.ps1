function Trace-Message {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Position = 1)]
        [string]
        $Message
    )

    Write-Verbose -Message $Message

} Export-ModuleMember -Function Trace-Message