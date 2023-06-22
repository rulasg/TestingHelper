Set-Variable -Name TestRunFolderName -Value "TestRunFolder" 

function Test-Module {
    [System.ObsoleteAttribute("This function is obsolete. Use Invoke-TestingHelper instead", $true)]
    [CmdletBinding()] 
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName,Position = 0)] 
        [string] $Name,
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
} Export-ModuleMember -Function Test-Module

function Invoke-TestingHelper {
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
            $result | Add-Member -NotePropertyName "Name" -NotePropertyValue $manifest.Name
            $result | Add-Member -NotePropertyName "TestModule" -NotePropertyValue $TestingModuleName
            $result | Add-Member -NotePropertyName "TestsName" -NotePropertyValue $functionsTestName
            $result | Add-Member -NotePropertyName "Tests" -NotePropertyValue $functionsTest.Length
            $result | Add-Member -NotePropertyName "Time" -NotePropertyValue $time

            # Display single line result
            Show-ResultSingleLine -Result $result

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
} Export-ModuleMember -Function Invoke-TestingHelper

function Test-ModulelocalPSD1 {
    [System.ObsoleteAttribute("This function is obsolete. Use Invoke-TestingHelper instead", $true)]
    [CmdletBinding()] 
    param (
        [Parameter( Position = 1)] [string] $TestName,
        [Parameter( Position = 2)] [string] $Path = $MyInvocation.PSScriptRoot,
        [Parameter()] [switch] $ShowTestErrors
    )

    process {
        Invoke-TestingHelper -TestName:$TestName -Path:$Path -ShowTestErrors:$ShowTestErrors
    }
} Export-ModuleMember -Function Test-ModulelocalPSD1

function Show-ResultSingleLine($Result) {

    # Display single line result
    Write-Host  -ForegroundColor DarkCyan 
    $TestingModuleName | Write-Host  -ForegroundColor Green -NoNewline
    " results - " | Write-Host  -ForegroundColor DarkCyan -NoNewline
    Out-SingleResultData -Name "Pass"           -Value $result.Pass           -Color "Yellow"
    Out-SingleResultData -Name "Failed"         -Value $result.Failed         -Color "Red"
    Out-SingleResultData -Name "Skipped"        -Value $result.Skipped        -Color "Yellow"
    Out-SingleResultData -Name "NotImplemented" -Value $result.NotImplemented -Color "Red"
    Write-Host  -ForegroundColor DarkCyan 
}

function Out-SingleResultData($Name,$Value, $Color){
    $testColor = $Value -eq 0 ? "DarkCyan" : $Color

    "{0}" -f $Name | Write-Host  -ForegroundColor $testColor -NoNewline 
    "["   -f $Name | Write-Host  -ForegroundColor DarkCyan -NoNewline 
    $Value         | Write-Host  -ForegroundColor $testColor -NoNewline 
    "] "  -f $Name | Write-Host  -ForegroundColor DarkCyan -NoNewline 
}

function Get-TestingFunctionPrefix ([string] $TestingModuleName) { return ($TestingModuleName + "_*") }

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