

function Get-ModulePath{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$RootPath
    )

    # | path/name | null  | Name        |
    # | --------- | ----- | ----------- |
    # | null      | Error | ./Name      |
    # | Path      | '.'   | Path/Name   |

    if ([string]::IsNullOrWhiteSpace($Path) -and [string]::IsNullOrWhiteSpace($Name)) {
        write-Error "Path and Name cannot be null or empty at the same time."
        return $null
    } 

    #check if path is null
    $path = [string]::IsNullOrWhiteSpace($Path) ? (Get-Location | Convert-Path) : $Path
    $ret = $path | Join-Path -ChildPath $Name
    return $ret 
}

function Get-ModuleName{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Path
    )

    # null if path is null
    if([string]::IsNullOrWhiteSpace($Path)){
        return $null
    }

    $name = $Path | Split-Path -LeafBase

    return $name
}

function Get-TestModulePath{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Path
    )

    $testModulePath = $path | Join-Path -ChildPath ("Test")

    return $testModulePath
}

function Get-TestModuleName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)] [string] $Path
    )

    $name = "Test"

    return $name
} 

function New-ModuleFolder{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Path
    )

    process {

        try {
            #test if path exists
            if(!($Path | Test-Path)){
                if ($PSCmdlet.ShouldProcess($Path, "New-Item -ItemType Directory")) {
                    $null = New-Item -ItemType Directory -Path $Path
                }
                # Converting to Provider path
                return $Path | Convert-Path
            }

            # Folder exists. Check if the psd1 file exists
            $psd1Path = ($Path | Join-Path -ChildPath "$($Path | Split-Path -LeafBase).psd1")
            if($psd1Path | Test-Path){
                Write-Error -Message "Module already exists."
                return $null
            }

            return $Path | Convert-Path

        }
        catch {
            Write-Error -Message "Failed to add path."
            return $null
        }
    }
}

