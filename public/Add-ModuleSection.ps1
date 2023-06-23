function Add-ModuleLicense{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory)][string]$Path,
        [Parameter()][switch]$Force
    )

    process{
        Import-Template -Path $Path -File "LICENSE" -Template "template.LICENSE.txt" -Force:$Force
    }
} Export-ModuleMember -Function Add-ModuleLicense