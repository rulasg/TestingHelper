
# function Get-ModulePath{
#     [CmdletBinding()]
#     param(
#         [Parameter()][string]$Name,
#         [Parameter()][string]$Path
#     )

#     # Asumes current as the default path
#     $path = [string]::IsNullOrWhiteSpace($Path) ? (Get-Location | Convert-Path) : $Path

#     # Use dot local path
#     $modulePath = [string]::IsNullOrWhiteSpace($Name) ? $path : ($path | Join-Path -ChildPath $Name)

#     return $modulePath
# }

# function Get-ModulePath{
#     [CmdletBinding()]
#     param(
#         [Parameter()][string]$Name,
#         [Parameter()][string]$Path
#     )

#     # | path/name | null  | Name        |
#     # | --------- | ----- | ----------- |
#     # | null      | Error | Name        |
#     # | Path      | Path  | Path + Name |

#     if ([string]::IsNullOrWhiteSpace($Path) -and [string]::IsNullOrWhiteSpace($Name)) {
#         write-Error "Path and Name cannot be null or empty at the same time."
#         return $null
#     } 

#     $modulePath = [string]::IsNullOrWhiteSpace($Path) ? (Get-Location | Convert-Path) : $Path

#     $ret =  ([string]::IsNullOrWhiteSpace($Name)) ? $modulePath : ($modulePath | Join-Path -ChildPath $Name)

#     return $ret
# }

# function Get-ModulePath{
#     [CmdletBinding()]
#     param(
#         [Parameter()][string]$Name,
#         [Parameter()][string]$Path
#     )

#     # | path/name | null  | Name        |
#     # | --------- | ----- | ----------- |
#     # | null      | Error | Name        |
#     # | Path      | Path  | Path        |

#     if ([string]::IsNullOrWhiteSpace($Path) -and [string]::IsNullOrWhiteSpace($Name)) {
#         write-Error "Path and Name cannot be null or empty at the same time."
#         return $null
#     } 

#     $ret = [string]::IsNullOrWhiteSpace($Path) ? $Name : $Path

#     return $ret
# }

function Get-ModulePath{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path,
        [Parameter()][switch]$AppendName
    )

    # | path/name | null  | Name        |
    # | --------- | ----- | ----------- |
    # | null      | Error | Name        |
    # | Path      | Path  | Path        |

    if ([string]::IsNullOrWhiteSpace($Path) -and [string]::IsNullOrWhiteSpace($Name)) {
        write-Error "Path and Name cannot be null or empty at the same time."
        return $null
    } 

    $ret =  ([string]::IsNullOrWhiteSpace($Path) ? $Name : `
            ([string]::IsNullOrWhiteSpace($Name) ? $Path : `
            ( !$AppendName                       ? $Path :  `
            ($Path | Join-Path -ChildPath $Name))))


    return $ret
}

function Get-TestModulePath{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$Path
    )

    $modulepath = Get-ModulePath -Name $Name -Path $Path
    $moduleName = Get-ModuleName -Name $Name -ModulePath $Path

    $testModuleName = Get-TestModuleName -Name $moduleName
    $tesModulePath = $modulepath | Join-Path -ChildPath $testModuleName

    return $tesModulePath
}

function Get-ModuleName{
    [CmdletBinding()]
    param(
        [Parameter()][string]$Name,
        [Parameter()][string]$ModulePath
    )

    #Return Name if provided
    if(![string]::IsNullOrWhiteSpace($Name)){
        return $Name
    }

    # extract name from path
    $retName = Get-ModulePath -Name $Name -Path $ModulePath | Split-Path -Leaf

    return $retName
}

function Get-TestModuleName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)] [string] $Name
    )
    
    return ($Name + "Test") 
} 

function Add-Folder{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Path
    )

    process {

        try {
            #test if path exists
            if($Path | Test-Path){
                Write-Error "Path already exists."
                return $false
            } else {
                if ($PSCmdlet.ShouldProcess($Path, "New-Item -ItemType Directory")) {
                    $null = New-Item -ItemType Directory -Path $Path
                }
                
                return $true
            }
        } 
        catch {
            Write-Error -Message "Failed to add path."
            return $false
        }
    }

}

