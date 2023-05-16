Set-Variable -Name TestRunFolderName -Value "TestRunFolder" 

function Get-TestingModuleName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)] [string] $TargetModule
    )
    
    return ($TargetModule + "Test") 
}

function Get-TestingFunctionPrefix ([string] $TestingModuleName) { return ($TestingModuleName + "_*") }

function Trace-Message {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Position = 1)]
        [string]
        $Message
    )

    Write-Verbose -Message $Message
}

function Test-Assert {
    [CmdletBinding()]
    [Alias("Assert")]
    param (
        [Parameter(Mandatory)] [bool] $Condition,
        [Parameter()][bool] $Expected = $true,
        [Parameter()][string]$Comment = "No Comment"
    )
    
    Write-Verbose -Message "Assert -Condition $Condition -Expected $Expected - $Comment"
    if ($Condition -ne $Expected) {
        throw "Assertion - Found [ $Condition ] Expected [ $Expected ] - $Comment"
    }
    else {
        Write-AssertionDot -Color DarkMagenta
    }
}

function Write-AssertionDot {
    [CmdletBinding()]
    param ( 
        [Parameter()] [string] $Color
    )
    Write-Host "." -NoNewline -ForegroundColor $Color
}

function Write-AssertionSectionEnd{
    Write-AssertionDot -Color Yellow
}

function Start-TestingFunction {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline,ParameterSetName="FuncInfo")][System.Management.Automation.FunctionInfo] $FunctionInfo,
        [Parameter(Mandatory, ParameterSetName="FuncName")] [string] $FunctionName,
        [Parameter()] [switch] $ShowTestErrors
    )

    begin{
        $ret = @{
            # Pass = 0
            # Failed = 0 
            # SkippedCount = 0 
            # NotImplementedCount = 0 
            FailedTests = @()
            FailedTestsErrors = @()
            NotImplementedTests = @()
            SkippedTests = @()
        }

    }

    Process {

        if ($ShowTestErrors) {
            $ErrorShow = 'Continue'
        }
        else {
            $ErrorShow = 'SilentlyContinue'
        }

        if ($FunctionInfo) {
            $FunctionName = $FunctionInfo.Name
        }
        Write-Verbose -Message "Running [ $FunctionName ]"
    
        $local = Push-TestingFolder -Path $FunctionName
    
        try {
            Write-Host "$FunctionName ... [" -NoNewline -ForegroundColor DarkCyan
            $null = & $FunctionName -ErrorAction $ErrorShow
            Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
            Write-Host "PASS"  -ForegroundColor DarkYellow 
            $ret.Pass++
        }
        catch {
    
            Write-Host "x"  -NoNewline -ForegroundColor Red 
            Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 

            if ($_.Exception.Message -eq "SKIP_TEST") {
                Write-Host "Skip"  -ForegroundColor Magenta 
                $ret.SkippedTests += $FunctionName
                
            }elseif ($_.Exception.Message -eq "NOT_IMPLEMENTED") {
                Write-Host "NotImplemented"  -ForegroundColor Red 
                $ret.NotImplementedTests += $FunctionName
                
            } else {
                Write-Host "Failed"  -ForegroundColor Red 
                $ret.FailedTests += $FunctionName
                
                $ret.FailedTestsErrors += @($functionName,$_)
                
                if ($ShowTestErrors) {
                    @($functionName,$_)
                } 
            }
        }
        finally {
            $local | Pop-TestingFolder -Force
        }
    }

    end{

        $Global:FailedTestsErrors = $FailedTestsErrors

        if($ret.FailedTests.count -eq 0)         { $ret.Remove("FailedTests")}         else {$ret.Failed = $ret.FailedTests.Count}
        if($ret.SkippedTests.count -eq 0)        { $ret.Remove("SkippedTests")}        else {$ret.Skipped = $ret.SkippedTests.Count}
        if($ret.NotImplementedTests.count -eq 0) { $ret.Remove("NotImplementedTests")} else {$ret.NotImplemented = $ret.NotImplementedTests.Count}

        $Global:FailedTestsErrors = $ret.FailedTestsErrors

        if($ret.FailedTestsErrors.count -eq 0) { $ret.Remove("FailedTestsErrors")}

        return [PSCustomObject] $ret
    }
}

function Out-SingleResultData($Name,$Value, $Color){
    $testColor = $Value -eq 0 ? "DarkCyan" : $Color

    "{0}" -f $Name | Write-Host  -ForegroundColor $testColor -NoNewline 
    "["     -f $Name | Write-Host  -ForegroundColor DarkCyan -NoNewline 
    $Value            | Write-Host  -ForegroundColor $testColor -NoNewline 
    "] "     -f $Name | Write-Host  -ForegroundColor DarkCyan -NoNewline 
}

function Test-Module {
    [CmdletBinding()] 
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName,Position = 0)] [string] $Name,
        [Parameter( Position = 1)] [string] $TestName,
        [Parameter()] [switch] $ShowTestErrors
    )

    process {
        Get-ModuleHeader | Write-Host -ForegroundColor Green
        write-host
        "[ {0} ] Running tests functions [ {1} ] " -f $Name,([string]::IsNullOrWhiteSpace($TestName) ? "*" : $TestName) | Write-Host -ForegroundColor Green

        $local = Push-TestingFolder

        try {

            # Remove-Module -Name "$Name*"
            
            Import-TestingModule -TargetModule $Name -Force

            $TestingModuleName = Get-TestingModuleName -TargetModule $Name

            $functionsTest = @()

            # Check if specific scoped to specific testing functions
            if ( $TestName) {
                # Filter based on TestFunction names
                $ShowTestErrors = $true
                $functionsTestName = $TestName
            }
            else {
                # No function scope so search for all testing functions in module based on prefix
                $functionsTestName = Get-TestingFunctionPrefix -TestingModuleName ($TestingModuleName )
            } 
            
            # Get list of testing fucntions to run
            $functionsTest += Get-Command -Name $functionsTestName -Module $TestingModuleName -ErrorAction SilentlyContinue
            
            # Run tests and gather result
            $start = Get-Date
            $result = $functionsTest | Start-TestingFunction -ShowTestErrors:$ShowTestErrors
            $time = ($start | New-TimeSpan ).ToString("hh\:mm\:ss\:FFFF")
            
            # Add extra info to result
            $result | Add-Member -NotePropertyName "Name" -NotePropertyValue $Name
            $result | Add-Member -NotePropertyName "TestModule" -NotePropertyValue $TestingModuleName
            $result | Add-Member -NotePropertyName "TestsName" -NotePropertyValue $functionsTestName
            $result | Add-Member -NotePropertyName "Tests" -NotePropertyValue $functionsTest.Length
            $result | Add-Member -NotePropertyName "Time" -NotePropertyValue $time

            # Display single line result
            Write-Host  -ForegroundColor DarkCyan 
            $TestingModuleName | Write-Host  -ForegroundColor Green -NoNewline
            " results - " | Write-Host  -ForegroundColor DarkCyan -NoNewline
            Out-SingleResultData -Name "Pass"           -Value $result.Pass           -Color "Yellow"
            Out-SingleResultData -Name "Failed"         -Value $result.Failed         -Color "Red"
            Out-SingleResultData -Name "Skipped"        -Value $result.Skipped        -Color "Yellow"
            Out-SingleResultData -Name "NotImplemented" -Value $result.NotImplemented -Color "Red"
            Write-Host  -ForegroundColor DarkCyan 

            # Displayy all results strucutre
            $result

            # Save result to global variable
            $global:ResultTestingHelper = $result

            # unload testing module
            Remove-Module -Name $TestingModuleName -Force
        }
        finally {
            $local | Pop-TestingFolder
        }
    }
}

function Get-ModuleManifest($Path){

    $localPath = $Path | Convert-Path

    $psdpath = Get-ChildItem -Path $localPath -Filter "*.psd1" -ErrorAction SilentlyContinue

    if($psdpath.count -ne 1){
        throw "No psd1 file found in path $localPath"
    }
    
    $manifest = Import-PowerShellDataFile -Path $psdpath.FullName

    $manifest.Path = $localPath
    $manifest.PsdPath = $psdpath.FullName
    $manifest.Name = $manifest.RootModule | Split-Path -leafbase


    return $manifest
}

function Test-ModulelocalPSD1 {
    [CmdletBinding()] 
    param (
        [Parameter( Position = 1)] [string] $TestName,
        [Parameter( Position = 2)] [string] $Path = $MyInvocation.PSScriptRoot,
        [Parameter()] [switch] $ShowTestErrors
    )

    process {

        $manifest = Get-ModuleManifest -Path ($Path | Convert-Path)
        $testingmodulemanifest = Get-TestingModuleManifest -ModulePath $manifest.Path
        $versionString = "{0} {1} {2}" -f $manifest.Name, $manifest.ModuleVersion, $manifest.PrivateData.PSData.Prerelease

        Get-ModuleHeader | Write-Host -ForegroundColor Green
        write-host
        "[ {0} ] Running tests from functions [ {1} ] " -f $versionString,([string]::IsNullOrWhiteSpace($TestName) ? "*" : $TestName) | Write-Host -ForegroundColor Green

        $local = Push-TestingFolder
  
        try {

            # Import Target Module
            Import-Module -Name $manifest.PsdPath -Force -Scope:Global
            
            # Load Testing Module 
            Import-TestingModule -Name $testingmodulemanifest.path -Force

            $TestingModuleName = Get-TestingModuleName -TargetModule $manifest.Name

            $functionsTest = @()

            # Check if specific scoped to specific testing functions
            if ( $TestName) {
                # Filter based on TestFunction names
                $ShowTestErrors = $true
                $functionsTestName = $TestName
            }
            else {
                # No function scope so search for all testing functions in module based on prefix
                $functionsTestName = Get-TestingFunctionPrefix -TestingModuleName ($testingmodulemanifest.Name )
            } 
            
            # Get list of testing fucntions to run
            $functionsTest += Get-Command -Name $functionsTestName -Module $TestingModuleName -ErrorAction SilentlyContinue
            
            # Run tests and gather result
            $start = Get-Date
            $result = $functionsTest | Start-TestingFunction -ShowTestErrors:$ShowTestErrors
            $time = ($start | New-TimeSpan ).ToString("hh\:mm\:ss\:FFFF")
            
            # Add extra info to result
            $result | Add-Member -NotePropertyName "Name" -NotePropertyValue $Name
            $result | Add-Member -NotePropertyName "TestModule" -NotePropertyValue $TestingModuleName
            $result | Add-Member -NotePropertyName "TestsName" -NotePropertyValue $functionsTestName
            $result | Add-Member -NotePropertyName "Tests" -NotePropertyValue $functionsTest.Length
            $result | Add-Member -NotePropertyName "Time" -NotePropertyValue $time

            # Display single line result
            Write-Host  -ForegroundColor DarkCyan 
            $TestingModuleName | Write-Host  -ForegroundColor Green -NoNewline
            " results - " | Write-Host  -ForegroundColor DarkCyan -NoNewline
            Out-SingleResultData -Name "Pass"           -Value $result.Pass           -Color "Yellow"
            Out-SingleResultData -Name "Failed"         -Value $result.Failed         -Color "Red"
            Out-SingleResultData -Name "Skipped"        -Value $result.Skipped        -Color "Yellow"
            Out-SingleResultData -Name "NotImplemented" -Value $result.NotImplemented -Color "Red"
            Write-Host  -ForegroundColor DarkCyan 

            # Displayy all results strucutre
            $result

            # Save result to global variable
            $global:ResultTestingHelper = $result

            # unload testing module
            Remove-Module -Name $TestingModuleName -Force
        }
        finally {
            $local | Pop-TestingFolder
        }
    }
}

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
}

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
}

# function Start-TestModule {
#     [CmdletBinding()] 
#     param (
#         [Parameter(Mandatory, Position = 0)][string] $TestModuleName,
#         [Parameter()][string] $Prefix,
#         [Parameter()][string] $ModuleName
#     )

#     if ($ModuleName) {
#         Import-Module -Name $ModuleName
#     }

#     Write-Host "Running Test Module [ $TestModuleName ] ..." -ForegroundColor DarkYellow
#     Import-TestingModule -Name $TestModuleName

#     if ($Prefix) {
#         Write-Host "Filtering functions by Prefix [ $Prefix ] ..." -ForegroundColor DarkYellow
#         $functions = Get-Command -Module $TestModuleName -Name $Prefix*
#     }
#     else { 
#         $functions = Get-Command -Module $TestModuleName 
#     }

#     $functions | ForEach-Object {
#         Start-TestingFunction -FunctionName $_.Name
#     }
# }

function Assert-NotImplemented {

    throw "NOT_IMPLEMENTED"
}

function Assert-SkipTest{
    throw "SKIP_TEST"
}

function Assert-IsTrue {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)] [bool] $Condition,
        [Parameter()][string] $Comment
    )
    Assert -Condition $Condition -Expected $true -Comment:$Comment
}

function Assert-IsFalse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)] [bool] $Condition,
        [Parameter()][string] $Comment
    )
    Assert -Condition $Condition -Expected $false -Comment:$Comment
}

function Assert-IsNotNull {
    [CmdletBinding()]
    param (
        $Object,
        $Comment
    )

    Assert-IsFalse -Condition ($null -eq $Object) -Comment ("Object is null -" + $Comment)
}

function Assert-IsNull {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)] $Object,
        $Comment
    )


    Assert-IsTrue -Condition ($null -eq $Object) -Comment ("Object not null -" + $Comment)
}

function Assert-AreEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    Assert-IsTrue -Condition ($Expected -eq $Presented) -Comment ("Object are not Equal : Expected [ $Expected ] and presented [ $Presented ] - " + $Comment)
}

function Assert-AreEqualSecureString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter(Mandatory)] [securestring] $Presented,
        [Parameter()] [string] $Comment

    )

    $pss = $Presented | ConvertFrom-SecureString -AsPlainText

    Assert-AreEqual -Expected $Expected -Presented $pss -Comment ("SecureString - " + $Comment)
}

function Assert-AreEqualPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    Assert-AreEqual -Expected $ex -Presented $pr -Comment ("Path not equal - " + $Comment)
}

function Assert-AreNotEqualPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    Assert-AreNotEqual -Expected $ex -Presented $pr -Comment ("Path equal - " + $Comment)
}

function Assert-ContainsPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ $Presented | Convert-Path} else {$Presented}

    Assert-Contains -Expected $ex -Presented $pr -Comment ("Path not contained - " + $Comment)
}

function Assert-NotContainsPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ $Presented | Convert-Path} else {$Presented}

    Assert-NotContains -Expected $ex -Presented $pr -Comment ("Path not contained - " + $Comment)
}

function Assert-AreNotEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsFalse -Condition ($Expected -eq $Presented) -Comment ("Object are Equal : Expecte [ $Expected ] and presented [ $Presented ] - " + $Comment)
}

function Assert-AreEqualContent{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    $hashEx = Get-FileHash -Path $ex
    $hashPr = Get-FileHash -Path $pr

    Assert-AreEqual -Expected $hashEx -Presented $hashPr 
}

function Assert-AreNotEqualContent{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = &{ if ($Expected  | Test-Path) { $Expected  | Convert-Path} else {$Expected} }
    $pr = &{ if ($Presented | Test-Path) { $Presented | Convert-Path} else {$Presented}}

    $hashEx = Get-FileHash -Path $ex
    $hashPr = Get-FileHash -Path $pr

    Assert-AreNotEqual -Expected $hashEx -Presented $hashPr  
}

function Assert-ItemExist {
    param(
        [string] $Path
    )
    Assert-IsNotNull -Object $Path -Comment "[Assert-ItemExist] Path is empty"
    Assert-IsTrue -Condition ($Path | Test-Path)
}

function Assert-ItemNotExist {
    param(
        [string] $Path
        )
        
    Assert-IsNotNull -Object $Path -Comment "[Assert-ItemNotExist] Path is empty"
    Assert-IsFalse -Condition ($Path | Test-Path)
}

function Assert-IsGuid{
    param(
        [string] $Presented
    )
    try {
        Assert-IsNotNull -Object (New-Object -TypeName System.Guid -ArgumentList $Presented)
    }
    catch {
        Assert -Condition $false -Comment "String is not a valid Guid"
    }
}

function Assert-Count {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [int] $Expected,
        [Parameter()] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    if (!$Presented) {
        Assert-IsTrue -Condition ($Expected -eq 0) -Comment ("Presented is null expected [{0}]- {1}" -f $Expected, $Comment)
    } else {
        Assert-IsTrue -Condition ($Presented.Count -eq $Expected) -Comment ("Count Expected [{0}] and Presented [{1}] - {2}" -f $Expected,$Presented.Count, $Comment)

    }
}

function Assert-CountTimes {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [int] $Expected,
        [Parameter(Mandatory)] [string] $Pattern,
        [Parameter()] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

        if (!$Presented) {
        Assert-IsTrue -Condition ($Expected -eq 0) -Comment ("Presented is null expected [{0}]- {1}" -f $Expected, $Comment)
    } else {
        $iterations = $Presented | Where-Object {$_ -eq $pattern}
        Assert-IsTrue -Condition ($iterations.Count -eq $Expected) -Comment ("Count Expected [{0}] and Presented [{1}] - {2}" -f $Expected,$iterations.Count, $Comment)
    }
}

function Assert-Contains{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter()] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    Test-Assert -Condition (!([string]::IsNullOrEmpty($Expected)) -and ($Presented.Contains($Expected))) -Comment  ("[Assert-Contains] Expected[{0}] present on {1}" -f $Expected, $Presented)

}

function Assert-NotContains{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string] $Expected,
        [Parameter()] [string[]] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert -Condition ([string]::IsNullOrEmpty($Expected)) -Expected $false -Comment "[Assert-Contains] Expected can not be empty"

    Assert-IsTrue -Condition (!($Presented.Contains($Expected))) -Comment  ("[Assert-Contains] Expected[{0}] present on {1}" -f $Expected, $Presented)
}

function Assert-ContainedXOR{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [string] $Expected,
        [Parameter(Mandatory)] [string[]] $PresentedA,
        [Parameter(Mandatory)] [string[]] $PresentedB,
        [Parameter()] [string] $Comment
    )

    process {
        $ga = $PresentedA.contains($Expected)
        $gb = $PresentedB.contains($Expected)
        
        Assert-IsTrue -Condition ( $ga -xor $gb) -Comment ("Assert-ContainedXOR [{0}]" -f ($Expected))
    }
}

function Assert-FilesAreEqual{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = $Expected | Get-FileHash
    $pr = $Presented | Get-FileHash

    Assert-AreEqual -Expected $ex.Hash -Presented $pr.Hash -Comment ("Files not equal - " + $Comment)
}

function Assert-FilesAreNotEqual{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    $ex = $Expected | Get-FileHash
    $pr = $Presented | Get-FileHash

    Assert-AreNotEqual -Expected $ex.Hash -Presented $pr.Hash -Comment ("Files equal - " + $Comment)
}

function Assert-FileContains{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Object] $Path,
        [Parameter(Mandatory)][Object] $Pattern,
        [Parameter()] [string] $Comment

    )

    $SEL = Select-String -Path $Path -Pattern $Pattern

    Assert-IsTrue -Condition ($null -ne $SEL) -Comment ("Files contains - " + $Comment)
}

function Assert-StringIsNotNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][string] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsFalse -Condition ([string]::IsNullOrEmpty($Presented))-Comment ("String not null or empty -" + $Comment)
}

function Assert-StringIsNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][string] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsTrue -Condition ([string]::IsNullOrEmpty($Presented))-Comment ("String null or empty -" + $Comment)
}

function Assert-CollectionIsNotNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][object] $Presented,
        [Parameter()] [string] $Comment
    )

    Test-Assert -Condition (($null -ne $presented) -and ($presented.Count -gt 0)) -Comment:$Comment
}

function Assert-CollectionIsNullOrEmpty {
    [CmdletBinding()]
    param (
        [parameter(Position=0,ValueFromPipeline)][object] $Presented,
        [Parameter()] [string] $Comment
    )

    Test-Assert -Condition (($null -eq $presented) -or ($presented.Count -eq 0)) -Comment:$Comment
}

function Remove-TestingFolder {
    param(
        [Parameter(Mandatory, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string] $Path,
        [switch] $Force
    )

    if (-not ($Path | Test-Path)) {
        return
    }

    #Recursive call
    $ChildTestFolder = Join-Path -Path $Path -ChildPath $TestRunFolderName
    if (Test-Path -Path $ChildTestFolder) {
        Remove-TestingFolder -Path $ChildTestFolder
    }

    # So far only remove content for TestRunFolder named folders
    if (($Path | Split-Path -Leaf) -ne $TestRunFolderName) {
        if (-not $Force) {
            return
        }
    }

    if (Test-Path -Path $Path) {
        $local = Get-Item -Path $Path
        $local | Get-ChildItem -File | Remove-Item -Force
        $local | Get-ChildItem -Directory |  Remove-TestingFolder -Force
        $local | Remove-Item -Force -Recurse
    }
}

function Push-TestingFolder {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string] $Path
    )

    $originalPath = Resolve-Path .

    if ($Path) {
        $testFolderName = $Path
    }
    else {
        $testFolderName = Join-Path -Path (GetRooTestingFolderPath) -ChildPath  $TestRunFolderName
    }
    New-TestingFolder $testFolderName
    $TestRunPath = Resolve-Path -Path $testFolderName

    if (Test-Path -Path $TestRunPath) { Remove-Testingfolder -Path $TestRunPath }

    New-Item -Path $TestRunPath  -ItemType "directory" -Force | Out-Null

    Set-Location -Path $TestRunPath

    return $originalPath
}

function Pop-TestingFolder {
    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string] $Path,
        [switch] $Force
    )

    $local = Get-Location | Resolve-Path
    $localLeaf = $local | Split-Path -Leaf

    Set-Location -Path $Path

    if (($localLeaf -eq $TestRunFolderName) -or $Force) {
        Remove-TestingFolder -Path $local
    }
}

function New-TestingFolder {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)] [string] $Path,
        [Parameter()] [string] $Name,
        [switch] $PassThru
    )

    if ($Path -and !$Name) {
        $finalPath = $Path
    } else {
        if ([string]::IsNullOrWhiteSpace($Name))    { $Name    = (New-Guid).ToString()}
        if ([string]::IsNullOrWhiteSpace($Path))    { $Path    = '.' }

        $finalPath = $Path | Join-Path -ChildPath $Name
    }
    
    # if ($Path -and $Name) {
    #     $finalPath = $Path | Join-Path -ChildPath $Name
    # }
    
    # if (!$Path -and $Name) {
    #     $finalPath = '.' | Join-Path -ChildPath $Name
    # }
    
    # if (!$Path -and !$Name) {
    #     $finalPath = '.' | Join-Path -ChildPath (New-Guid).ToString()
    # }


    # Need to consolidate as mkdir behaves diferent on PC or Mac
    $result = New-Item -ItemType Directory -Path $finalPath

    Write-Verbose -Message "Created Diretory [ $result ] "

    if ($PassThru) {
        return $result
    }
}

function New-TestingFile {
    param(
        [Parameter(ValueFromPipeline)][string]$Path,
        [Parameter()][string]$Name,
        [Parameter()][string]$Content,
        [switch] $Hidden,
        [switch] $PassThru
    )

    if ([string]::IsNullOrWhiteSpace($Name))    { $Name    = ("{0}.txt" -f (New-Guid).ToString()) }
    if ([string]::IsNullOrWhiteSpace($Path))    { $Path    = '.' }
    if ([string]::IsNullOrWhiteSpace($Content)) { $Content = "random content" }

    $file = New-Item -ItemType File -Path $Path -Name $Name -Value $Content -Force

    if ($Hidden) {
        $file.Attributes = $file.Attributes -bxor [System.IO.FileAttributes]::Hidden
    }

    if ($PassThru) {
        return $file
    }
}

function Remove-TestingFile {
    param(
        [Parameter(ValueFromPipeline)][string]$Path,
        [Parameter()][string]$Name,
        [Parameter()][string]$Content,
        [switch] $Hidden
    )
    
    if ([string]::IsNullOrWhiteSpace($Path))    { $Path    = '.' }
    
    $target = ([string]::IsNullOrWhiteSpace($Name)) ? $Path : ($Path | Join-Path -ChildPath $Name)

    Assert-ItemExist -Path $target

    (Get-Item -Force -Path $target).Attributes = 0

    Remove-Item -Path $target

    Assert-itemNotExist -Path $target
} 

function GetRooTestingFolderPath{
    # get the first 6 char of a guid
    $random = (New-Guid).ToString().Substring(0,6)
    $rd = Get-Date -Format yyMMdd
    $path = Join-Path -Path "Temp:" -ChildPath ("Posh_Testing_{0}_{1}" -f $rd,$random)
    return $path
}



# TODO : Reduce the number of functions exported
# Export-ModuleMember -Function Assert-*
# Export-ModuleMember -Function New-Testing*
# Export-ModuleMember -Function Test-Module
# Export-ModuleMember -Function Pop-TestingFolder