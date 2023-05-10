
# New Module with V2 structure. Generic files and public/private folders.
# /ModuleName/
# Manifest    - DemoPsModule.psd1
#
# Module      - public
#               - publicFunctions.ps1
#             - private
#               - privateFunctions.ps1
#               - privateFunctions2.ps1
#             - DemoPsModule.psm1
#
# Testing     - DemoPsModuleTest
#               - private
#                 - DemoPsModuleTest.psd1
#                 - DemoPsModuleTest.psm1
#             - test.ps1
#             - .vscode
#               - launch.json
#
# Publish     - publish.ps1
#
# About       - en-US
#               - about_DemoPsModule.help.txt
#
# License     - LICENSE
# ReadMe      - README.md

function New-ModuleV2 {
    <#
    .Synopsis
       Created a Powershell module with V2 format.
    #>
        [CmdletBinding()]
        Param
        (
            # Param1 help description
            [Parameter(Mandatory)][string]$Name,
            [Parameter(Mandatory)][string]$Description,
            [Parameter()][string]$Author,
            [Parameter()][string]$CompanyName,
            [Parameter()][string]$Copyright,
            [Parameter()][string]$Version,
            [Parameter()][string]$Path,
            [Parameter()][switch]$AvoidTestingModule,
            [Parameter()][switch]$AvoidSampleCode
        )    
    
        $ModuleName = $Name
        # set value if $path is null or empty
        $Path = [string]::IsNullOrWhiteSpace($Path) ? '.' : $Path
    
        $modulePath = Join-Path -Path $Path -ChildPath $Name
    
        if(Test-Path($modulePath)){
            throw "Folder already exists"
        } else {
           $null = New-Item -ItemType Directory -Name $modulePath
        }
    
        # PSD1
        $params = @{
            Path = ($modulePath | Join-Path -ChildPath "$ModuleName.psd1") 
            RootModule = "$moduleName.psm1" 

            Description = [string]::IsNullOrWhiteSpace($Description) ? "Description of $ModuleName" : $Description

            ModuleVersion = [string]::IsNullOrWhiteSpace($Version) ? '0.1' : $Version
            Author = [string]::IsNullOrWhiteSpace($Author) ? "Anonymous" : $Author
            CompanyName = [string]::IsNullOrWhiteSpace($CompanyName) ? "CompanyName" : $CompanyName
            Copyright = [string]::IsNullOrWhiteSpace($CompanyName) ? "(c) $((Get-Date).Year) $CompanyName. All rights reserved." :$Copyright 
        }
        New-ModuleManifest @params

        # PSM1
        Import-Template -Path $modulePath -File $params.RootModule -Template "template.module.psm1"

        # Sample code
        if (!$AvoidSampleCode) {
            Import-Template -Path ($modulePath | Join-Path -ChildPath "public") -File "sammplePublicFunction.ps1" -Template "template.module.functions.public.ps1"
            Import-Template -Path ($modulePath | Join-Path -ChildPath "private") -File "sammplePrivateFunction.ps1" -Template "template.module.functions.private.ps1"
        }

        # publish.ps1
        Import-Template -Path $modulePath -File "publich.ps1" -Template "template.publish.ps1"
            
        # Testing module
        if (-Not $AvoidTestingModule)
        {   
            $testingModuleName = $ModuleName + "Test"

            $testingparams = @{
                Path= $modulePath
                Name= $testingModuleName
                Description= "Testing Module for $ModuleName"
                Author= $Author
                CompanyName= $CompanyName
                Copyright= $Copyright
                Version= $Version
                AvoidTestingModule= $true
                AvoidSampleCode= $true
            }
            
            # New-TestingModuleV2 @testingparams
            New-ModuleV2 @testingparams

            # test.ps1
            Import-Template -Path $modulePath -File "test.ps1" -Template "template.test.ps1"
            # launch.json
            Import-Template -Path ($modulePath | Join-Path -ChildPath '.vscode') -File 'launch.json' -Template "template.launch.json"

            # Sample test
            $testingModulePublicPath = $modulePath | Join-Path -ChildPath $testingModuleName -AdditionalChildPath "public"

            Import-Template -Template "template.testmodule.functions.public.ps1" -File "SampleFunctionTests.ps1" -Path $testingModulePublicPath -Replaces @{
                '_MODULE_TESTING_' = $testingModuleName
            }
        }
    
    } Export-ModuleMember -Function New-Module

# function New-ModuleManifestV2{
#     [CmdletBinding()]
#     Param
#     (
#         # Param1 help description
#         [Parameter(Mandatory)][string]$Path,
#         [Parameter(Mandatory)][string]$RootModule,
#         [Parameter(Mandatory)][string]$Author,
#         [Parameter(Mandatory)][string]$Description,
#         [Parameter(Mandatory)][string]$ModuleName,
#         [Parameter(Mandatory)][string]$ModuleVersion,
#         [Parameter()][string]$CompanyName,
#         [Parameter()][string]$Copyright
#     )

#     # Manifest
#     $params = @{
#         Path = ($modulePath | Join-Path -ChildPath "$ModuleName.psd1") 
#         RootModule = "$ModuleName.psm1" 
#         Author = $Author 
#         ModuleVersion = $ModuleVersion 
#         Description = $Description 
#         CompanyName =   $CompanyName
#         Copyright =     $Copyright
#     }

#     New-ModuleManifest @params
# }

# function New-TestingModuleV2{
#     [CmdletBinding()]
#     Param
#     (
#         # Param1 help description
#         [Parameter(Mandatory)][string]$Name,
#         [Parameter(Mandatory)][string]$Description,
#         [Parameter()][string]$Author,
#         [Parameter()][string]$CompanyName,
#         [Parameter()][string]$Copyright,
#         [Parameter()][string]$Version,
#         [Parameter()][string]$Path,
#         [Parameter()][switch]$AvoidTestFile,
#         [Parameter()][String[]]$PublicCode
#     ) 

#     $testingModuleName = $ModuleName + "Test"
#     $testingModulePath = Join-Path -Path $Path -ChildPath $testingModuleName

#     # Sample test
#     # $sampleTest = Get-Content -Path ($PSScriptRoot | Join-Path -ChildPath "sampletest.ps1.template")
#     # $sampleTest = $sampleTest.Replace('_MODULE_TESTING_',$testingModuleName)

#     $params = @{
#         Path = $testingModulePath
#         RootModule = "$testingModuleName.psm1" 
#         ModuleName = $testingModuleName
        
#         Description = "Testing Module for $ModuleName"
#         AvoidTestFile = $true

#         ModuleVersion = $Version 
#         Author = $Author 
#         CompanyName = $CompanyName 
#         Copyright = $Copyright  
#     }
#     # New-ModuleManifestV2 @params
#     New-ModuleManifest @params

#     Import-Template -Path $params.Path -File $params.RootModule -Template "template.module.psm1"
    
#     Import-Template -Template "template.testmodule.functions.public.ps1" -File "SampleFunctionTests.ps1" -Path ($testingModulePath | Join-Path -ChildPath "public") -Replaces @{
#         '_MODULE_TESTING_' = $testingModuleName
#     }

#     Import-Template -Path $Path -File "test.ps1" -Template "template.test.ps1"
#     Import-Template -Path ($Path | Join-Path -ChildPath '.vscode') -File 'launch.json' -Template "template.launch.json"
# }  

function Import-Template ($Path,$File,$Template,$Replaces){

    $null = New-Item -ItemType Directory -Force -Path $Path

    $script = Get-Content -Path ($PSScriptRoot  | Join-Path -ChildPath templates -AdditionalChildPath $Template)

    $Replaces.Keys | ForEach-Object {
        $script = $script.Replace($_, $Replaces.$_)
    }

    $script |  Out-File -FilePath (Join-Path -Path $Path -ChildPath $File)
}