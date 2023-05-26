function Import-TestingModule {
    [CmdletBinding()] 
    param (
        [Parameter(Mandatory, ParameterSetName = "TestingModule")][string] $Name,
        [Parameter(Mandatory, ParameterSetName = "TargetModule" )][string] $TargetModule,
        [Parameter()][string] $TargetModuleVersion,

        [switch] $Force
    )

    if ($Name) {
        $testingModulePathOrName = $Name
    }

    if ($TargetModule) {
  
        # check if module is already loaded
        $module = Get-Module -Name $TargetModule -ErrorAction SilentlyContinue
        if (-not $module) {
            "[Import-TestingModule] TargetModule {0} is not loaded" -f $TargetModule | Write-Verbose
            $module = Import-Module -Name $TargetModule -Force -PassThru
        } else {
            "[Import-TestingModule] TargetModule {0} is already loaded" -f $TargetModule | Write-Warning
        }

        #check TargetModuleVersion
        if ($TargetModuleVersion) {
            if ($module.Version -ne $TargetModuleVersion) {
                # Write-Warning -Message "TargetModule [ $TargetModule ] version [ $($module.Version) ] is not equal to TargetModuleVersion [ $TargetModuleVersion ]"
                "[Import-TestingModule] TargetModule {0} version {1} not matches {2}" -f $TargetModule,$module.Version,$TargetModuleVersion | Write-Warning

                return
            }
        }

        $modulePath = $module.Path
    
        $testingModulePathOrName = Join-Path -Path (Split-Path -Path $modulePath -Parent) -ChildPath (Get-TestingModuleName -TargetModule $TargetModule)

        if (-not (Test-Path -Path $testingModulePathOrName)) {
            Write-Warning -Message "TestingModule for module [ $TargetModule ] not found at [ $testingModulePathOrName ]"
            return
        }
    }
    
    #Import Testing Module
    Import-Module -Name $testingModulePathOrName -Force:$Force -Global
} Export-ModuleMember -Function Import-TestingModule

function Import-TargetModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $Name,
        [Parameter()][string] $Manifest,
        [switch] $Force,
        [switch] $PassThru
    )

    if ($Manifest) {
        Get-Item -Path $manifestFile | Import-Module -force -Force:$Force -Global
        return
    }
    
    Import-Module -Name $Name -Force:$Force -Global -Passthru:$PassThru
} Export-ModuleMember -Function Import-TargetModule