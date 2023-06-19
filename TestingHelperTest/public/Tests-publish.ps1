
$publish_ps1 = $PSScriptRoot | Split-path -Parent | split-path -Parent | Join-Path -ChildPath 'publish.ps1'
$manifestPath = $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Join-Path -ChildPath 'TestingHelper.psd1'

$SCRITPBLOCK_WITHNOEXCEPTION = {
        
    function Invoke-PublishModule {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][string]$Name,
            [Parameter(Mandatory=$true)][string]$NuGetApiKey,
            [Parameter(Mandatory=$false)][switch]$Force
        )
        
        "Invoke-PublishModule called with Name: $Name, NuGetApiKey: $NuGetApiKey, Force: $Force" | Write-Information
        
        return 0
    }
}
$EXCEPTION_MESSAGE = 'Some throw exception comming from Publish-Module Injection'
$SCRITPBLOCK_WITHEXCEPTION = {
        
    function Invoke-PublishModule {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true)][string]$Name,
            [Parameter(Mandatory=$true)][string]$NuGetApiKey,
            [Parameter(Mandatory=$false)][switch]$Force
        )
        
        "Invoke-PublishModule called With THROW with Name: $Name, NuGetApiKey: $NuGetApiKey, Force: $Force" | Write-Information

        throw $EXCEPTION_MESSAGE
    }
}

$PUBLISH_CALL_PARAMS = @{
    ErrorAction = 'SilentlyContinue' 
    ErrorVar = 'errorVar'
    InformationAction = 'SilentlyContinue' 
    InformationVar = 'infoVar'
    DependencyInjection = $SCRITPBLOCK_WITHNOEXCEPTION
}
$PUBLISH_CALL_PARAMS_WITHEXCEPTION = @{
    ErrorAction = 'SilentlyContinue' 
    ErrorVar = 'errorVar'
    InformationAction = 'SilentlyContinue' 
    InformationVar = 'infoVar'
    DependencyInjection = $SCRITPBLOCK_WITHEXCEPTION
}

function TestingHelperTest_Publish_NoTag_NoKey{

    # Fails due to lack of key as parameter of environment
    
    # Clear key env variable 
    $env:NUGETAPIKEY = $null

    & $publish_ps1 @PUBLISH_CALL_PARAMS

    # Assert for error
    Assert-IsFalse $? -Comment "Publish command should fail with Exit <> 0" 
    Assert-AreEqual -Expected 1 -Presented $LASTEXITCODE
    Assert-Count -Expected 1 -Presented $errorVar
    Assert-IsTrue -Condition ($errorVar[0].exception.Message.Contains('$Env:NUGETAPIKEY is not set.') )
} Export-ModuleMember -Function TestingHelperTest_Publish_NoTag_NoKey

function TestingHelperTest_Publish_WithKey{

    & $publish_ps1 -NuGetApiKey "something" @PUBLISH_CALL_PARAMS

    Assert-IsTrue $? -Comment "Publish command should success with Exit <> 0" 
    Assert-Publish_PS1_Invoke-PublishModule -Presented $infoVar
} Export-ModuleMember -Function TestingHelperTest_Publish_WithKey

function TestingHelperTest_Publish_WithKey_WhatIf{

    & $publish_ps1 -NuGetApiKey "something" -WhatIf @PUBLISH_CALL_PARAMS 

    Assert-IsTrue $? -Comment "Publish command should success with Exit <> 0" 

    # Invoke-PublishModule should not be called
    Assert-ContainsNotPattern -Expected "Publishing *" -Presented $infoVar.MessageData
} Export-ModuleMember -Function TestingHelperTest_Publish_WithKey_WhatIf

function TestingHelperTest_Publish_WithWrongKey_Injected{

    $hasThrow = $false
    try {
        & $publish_ps1 -NuGetApiKey "something"  @PUBLISH_CALL_PARAMS_WITHEXCEPTION
    }
    catch {
        # Assert-IsTrue $? -Comment "Publish command should success with Exit <> 0" 
        Assert-AreEqual -Expected $EXCEPTION_MESSAGE -Presented $_.exception.Message
        $hasThrow = $true
    }
    Assert-IsTrue -Condition $hasThrow -Comment "Publish command should fail with Exit <> 0"

    Assert-Publish_PS1_Invoke-PublishModule -Presented $infoVar
} Export-ModuleMember -Function TestingHelperTest_Publish_WithWrongKey_Injected

function TestingHelperTest_Publish_Key_InEnvironment{

    $Env:NUGETAPIKEY = "something"

    & $publish_ps1 -NuGetApiKey "something" @PUBLISH_CALL_PARAMS
    
    Assert-IsTrue $? -Comment "Publish command should success with Exit <> 0" 

    Assert-Publish_PS1_Invoke-PublishModule -Presented $infoVar
} Export-ModuleMember -Function TestingHelperTest_Publish_Key_InEnvironment

function TestingHelperTest_Publish_With_VersionTag{

    # Confirm that we extract from the tag the paramers

    Reset-Manifest

    $Env:NUGETAPIKEY = "something"

    $versionTag = '1.0.0-alpha'

    & $publish_ps1 -VersionTag $versionTag @PUBLISH_CALL_PARAMS

    Assert-Manifest -Version "1.0.0" -Prerelease "alpha" -Comment "Valid version tag [$versionTag]"

    Reset-Manifest
} Export-ModuleMember -Function TestingHelperTest_Publish_With_VersionTag

function TestingHelperTest_Publish_With_VersionTag_FormatVersion_Valid{
    
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
        
        & $publish_ps1 -VersionTag $versionTag @PUBLISH_CALL_PARAMS

        Assert-Publish_PS1_Invoke-PublishModule -Presented $infoVar
        Assert-Manifest -Version $ExpectedVersion -Prerelease $ExpectedPrerelease -Comment "Valid version tag [$versionTag]"

        Reset-Manifest
    }
} Export-ModuleMember -Function TestingHelperTest_Publish_With_VersionTag_FormatVersion_Valid

function TestingHelperTest_Publish_With_VersionTag_FormatVersion_NotValid{

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
 
        & $publish_ps1 -VersionTag $versionTag @PUBLISH_CALL_PARAMS
        
        Assert-IsFalse -Condition $? -Comment "Publish command should fail with Exit <> 0"
        # Assert-ContainsPattern -Expected "Cannot process argument transformation on parameter 'ModuleVersion'.*" -Presented $errorVar.exception.Message
        Assert-ContainsPattern -Expected "Failed to update module manifest with version tag*" -Presented $errorVar.exception.Message
        Assert-ContainsPattern -Expected "*$versionTag*" -Presented $errorVar.exception.Message

        Reset-Manifest
    }

}  Export-ModuleMember -Function TestingHelperTest_Publish_With_VersionTag_FormatVersion_NotValid

function Assert-Publish_PS1_Invoke-PublishModule{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][object] $Presented
    )
    Assert-ContainsPattern -Expected "Publishing TestingHelper.psm1*" -Presented $Presented.MessageData

}

function Assert-ContainsPattern{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter(Mandatory)] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    $found = $false
    foreach($p in $Presented){
        if ($p -like $Expected) {
            $found = $true
            break
        }
    }

    Assert-IsTrue -Condition $found -Comment "Not found pattern [$Expected] in $Presented - $Comment "
}

function Assert-ContainsNotPattern{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter(Mandatory)] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    $found = $false
    foreach($p in $Presented){
        if ($p -like $Expected) {
            $found = $true
            break
        }
    }

    Assert-IsFalse -Condition $found -Comment "Found pattern [$Expected] in $Presented - $Comment"
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
