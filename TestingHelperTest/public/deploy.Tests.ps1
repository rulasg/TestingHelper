
$TESTED_MODULE_PATH = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent
$deploy_ps1 = $TESTED_MODULE_PATH | Join-Path -ChildPath 'deploy.ps1'
$manifestPath = $TESTED_MODULE_PATH | Join-Path -ChildPath 'TestingHelper.psd1'

$SCRITPBLOCK_WITHNOEXCEPTION = {
        
    function script:Invoke-DeployModule {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][string]$Name,
            [Parameter(Mandatory=$true)][string]$NuGetApiKey,
            [Parameter(Mandatory=$false)][switch]$Force
        )
        
        "Invoke-DeployModule called with Name: $Name, NuGetApiKey: $NuGetApiKey, Force: $Force" | Write-Information
        
        return 0
    }
}
$EXCEPTION_MESSAGE = 'Some exception message thown  on Invoke-DeployModule injected function'
$SCRITPBLOCK_WITHEXCEPTION = {
        
    function script:Invoke-DeployModule {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][string]$Name,
            [Parameter(Mandatory=$true)][string]$NuGetApiKey,
            [Parameter(Mandatory=$false)][switch]$Force
        )
        
        "Invoke-DeployModule called With THROW with Name: $Name, NuGetApiKey: $NuGetApiKey, Force: $Force" | Write-Information

        throw $EXCEPTION_MESSAGE
    }
}

$DEPLOY_CALL_PARAMS = @{
    ErrorAction = 'SilentlyContinue' 
    ErrorVar = 'errorVar'
    InformationAction = 'SilentlyContinue' 
    InformationVar = 'infoVar'
    DependencyInjection = $SCRITPBLOCK_WITHNOEXCEPTION
}
$DEPLOY_CALL_PARAMS_WITHEXCEPTION = @{
    ErrorAction = 'SilentlyContinue' 
    ErrorVar = 'errorVar'
    InformationAction = 'SilentlyContinue' 
    InformationVar = 'infoVar'
    DependencyInjection = $SCRITPBLOCK_WITHEXCEPTION
}

function TestingHelperTest_Deploy_NoTag_NoKey{

    # Fails due to lack of key as parameter of environment
    
    # Clear key env variable 
    $env:NUGETAPIKEY = $null

    & $deploy_ps1 @DEPLOY_CALL_PARAMS

    # Assert for error
    Assert-IsFalse $? -Comment "Deploy command should fail with Exit <> 0" 
    Assert-AreEqual -Expected 1 -Presented $LASTEXITCODE
    Assert-Count -Expected 1 -Presented $errorVar
    Assert-IsTrue -Condition ($errorVar[0].exception.Message.Contains('$Env:NUGETAPIKEY is not set.') )
} Export-ModuleMember -Function TestingHelperTest_Deploy_NoTag_NoKey

function TestingHelperTest_Deploy_WithKey{

    & $deploy_ps1 -NuGetApiKey "something" @DEPLOY_CALL_PARAMS

    Assert-IsTrue $? -Comment "Deploy command should success with Exit <> 0" 
    Assert-Deploy_PS1_Invoke-DeployModule -Presented $infoVar
} Export-ModuleMember -Function TestingHelperTest_Deploy_WithKey

function TestingHelperTest_Deploy_WithKey_WhatIf{

    & $deploy_ps1 -NuGetApiKey "something" -WhatIf @DEPLOY_CALL_PARAMS 

    Assert-IsTrue $? -Comment "Deploy command should success with Exit <> 0" 

    # Invoke-DeployModule should not be called
    Assert-ContainsNotPattern -Expected "Deploying *" -Presented $infoVar.MessageData
} Export-ModuleMember -Function TestingHelperTest_Deploy_WithKey_WhatIf

function TestingHelperTest_Deploy_WithWrongKey_Injected{

    $hasThrow = $false
    try {
        & $deploy_ps1 -NuGetApiKey "something"  @DEPLOY_CALL_PARAMS_WITHEXCEPTION
    }
    catch {
        # Assert-IsTrue $? -Comment "Deploy command should success with Exit <> 0" 
        Assert-AreEqual -Expected $EXCEPTION_MESSAGE -Presented $_.exception.Message
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow -Comment "Deploy command should fail with Exit <> 0"

    Assert-Deploy_PS1_Invoke-DeployModule -Presented $infoVar
} Export-ModuleMember -Function TestingHelperTest_Deploy_WithWrongKey_Injected

function TestingHelperTest_Deploy_Key_InEnvironment{

    $Env:NUGETAPIKEY = "something"

    & $deploy_ps1 -NuGetApiKey "something" @DEPLOY_CALL_PARAMS
    
    Assert-IsTrue $? -Comment "Deploy command should success with Exit <> 0" 

    Assert-Deploy_PS1_Invoke-DeployModule -Presented $infoVar
} Export-ModuleMember -Function TestingHelperTest_Deploy_Key_InEnvironment

function TestingHelperTest_Deploy_With_VersionTag{

    # Confirm that we extract from the tag the paramers

    Reset-Manifest

    $Env:NUGETAPIKEY = "something"

    $versionTag = '1.0.0-alpha'

    & $deploy_ps1 -VersionTag $versionTag @DEPLOY_CALL_PARAMS

    Assert-Manifest -Version "1.0.0" -Prerelease "alpha" -Comment "Valid version tag [$versionTag]"

    Reset-Manifest
} Export-ModuleMember -Function TestingHelperTest_Deploy_With_VersionTag

function TestingHelperTest_Deploy_With_VersionTag_FormatVersion_Valid{
    
    $Env:NUGETAPIKEY = "something"

    # Valid format
    $valid = @(
        "1.0",
        "1.0.0",
        "1.0.0.0",
        "1.0.0-alpha",
        "1.0.0-kk2",
        "0.1",
        "0.0.1",
        "v1.0.0",
        "r1.0",
        "r1.0.0",
        "Release1.0.0",
        "Release_1.0.0",
        "Version1.0.0",
        "Version_1.0.0"
    )

    $valid | ForEach-Object {
        $versionTag = $_
        $ExpectedVersion = $versionTag.Split('-')[0] -replace '[a-zA-Z_]'
        $ExpectedPrerelease = $versionTag.Split('-')[1] ??[string]::Empty
        
        & $deploy_ps1 -VersionTag $versionTag @DEPLOY_CALL_PARAMS

        Assert-Deploy_PS1_Invoke-DeployModule -Presented $infoVar
        Assert-Manifest -Version $ExpectedVersion -Prerelease $ExpectedPrerelease -Comment "Valid version tag [$versionTag]"

        Reset-Manifest
    }
} Export-ModuleMember -Function TestingHelperTest_Deploy_With_VersionTag_FormatVersion_Valid

function TestingHelperTest_Deploy_With_VersionTag_FormatVersion_NotValid{

    $Env:NUGETAPIKEY = "something"
        
    $NotValid = @(
        "1.1.1.1.1",        # Error: "Version string portion was too short or too long."
        "1",                # Error: "Version string portion was too short or too long."
        "1.a.1"             # Letters will be removed from version before passing
    )

    $NotValid3Parts = @( # Version '{0}' must have exactly 3 parts for a Prerelease string to be used.
        "1-kk",
        "1.0-dev",
        "1.1.1.1-kk",
        "1.1.1.1.1-kk"
    )

    $NotValid + $NotValid3Parts| ForEach-Object {
        $versionTag = $_
 
        & $deploy_ps1 -VersionTag $versionTag @DEPLOY_CALL_PARAMS
        
        Assert-IsFalse -Condition $? -Comment "Deploy command should fail with Exit <> 0"
        # Assert-ContainsPattern -Expected "Cannot process argument transformation on parameter 'ModuleVersion'.*" -Presented $errorVar.exception.Message
        Assert-ContainsPattern -Expected "Failed to update module manifest with version tag*" -Presented $errorVar.exception.Message
        Assert-ContainsPattern -Expected "*$versionTag*" -Presented $errorVar.exception.Message

        Reset-Manifest
    }

}  Export-ModuleMember -Function TestingHelperTest_Deploy_With_VersionTag_FormatVersion_NotValid

function Assert-Deploy_PS1_Invoke-DeployModule{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][object] $Presented
    )
    Assert-ContainsPattern -Expected "Deploying TestingHelper.psm1*" -Presented $Presented.MessageData

}

function Assert-Manifest{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Version,
        [Parameter()][string]$Prerelease,
        [Parameter()][string]$Comment
    )

    $manifest = Import-PowerShellDataFile -Path $manifestPath

    Assert-AreEqual -Expected $version -Presented $manifest.ModuleVersion -Comment "Expected[$version] Presented[$($manifest.ModuleVersion)]] - $Comment"
    
    # If preRelease is not present in the manifest, then we expect null
    if ([string]::IsNullOrWhiteSpace($prerelease)) {
        Assert-IsNull -Object $manifest.PrivateData.PSData.Prerelease
    } else {
        Assert-AreEqual -Expected $prerelease -Presented $manifest.PrivateData.PSData.Prerelease -Comment "Expected[$prerelease] Presented[$($manifest.PrivateData.PSData.Prerelease)]] - $Comment"
    }
}

# Reset manifest to original state from git repo
function Reset-Manifest{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Push-Location . -StackName ResetManifest

    $manifestPath | Split-Path -Parent | Set-Location 

    # Check git status and see if manifest is dirty
    $status = git status --porcelain $manifestPath

    if ($status) {
        # Manifest is dirty, restore it
        if ($PSCmdlet.ShouldProcess($manifestPath, "git restore")) {
            git restore $manifestPath
        }
    }

    Pop-Location -StackName ResetManifest
}
