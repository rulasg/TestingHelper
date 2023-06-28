
<#
.SYNOPSIS
    Writes a dot of the specified color to the console.
.DESCRIPTION    
    Used to mark the execution of assertions on test code for easier troubleshooting. 
    Inserting a dot of a different collor visualy shows the execution of looped assertions.
#>
function Write-AssertionSectionEnd{

    [CmdletBinding()]
    param ()
    Write-AssertionDot -Color Yellow
} Export-ModuleMember -Function Write-AssertionSectionEnd

function Write-AssertionDot {
    [CmdletBinding()]
    param ( 
        [Parameter()] [string] $Color
    )
    Write-Host "." -NoNewline -ForegroundColor $Color
}
