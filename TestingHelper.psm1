
Write-Host "Loading TestingHelper ..." -ForegroundColor DarkCyan

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
        $SuccessCount = 0
        $FailedCount = 0 
        $SkippedCount = 0 
        $NotImplementedCount = 0 
        $FailedTests = @()
        $FailedTestsErrors = @()
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
            $SuccessCount++
        }
        catch {
    
            if ($_.Exception.Message -eq "SKIP_TEST") {
                Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
                Write-Host "Skip"  -ForegroundColor Magenta 
                $SkippedCount++
                
            }elseif ($_.Exception.Message -eq "NOT_IMPLEMENTED") {
                Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
                Write-Host "NotImplemented"  -ForegroundColor Red 
                $NotImplementedCount++
                
            } else {
                Write-Host "x"  -NoNewline -ForegroundColor Red 
                Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
                Write-Host "Failed"  -ForegroundColor Red 
                $FailedCount++
                $FailedTests += $FunctionName
                $FailedTestsErrors += @($functionName,$_)
                
                if ($ShowTestErrors) {
                    $_
                } 
            }
        }
        finally {
            $local | Pop-TestingFolder -Force
        }
    }

    end{

        $Global:FailedTestsErrors = $FailedTestsErrors
        
        return [PSCustomObject]@{

            Pass = $SuccessCount
            Failed = $FailedCount
            Skipped = $SkippedCount
            NotImplemented = $NotImplementedCount
            FailedTests = $FailedTests
        }
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
        write-host
        "[ {0} ] Running tests functions [ {1} ] " -f $Name,([string]::IsNullOrWhiteSpace($TestName) ? "*" : $TestName) | Write-Host -ForegroundColor Green

        $local = Push-TestingFolder

        try {

            Remove-Module -Name "$Name*"
            
            Import-TestingModule -TargetModule $Name -Force

            $TestingModuleName = Get-TestingModuleName -TargetModule $Name

            $functionsTest = @()

            #Use standar testing fucntions prfix
            if ( $TestName) {
                # Filter based on TestFunction names
                $ShowTestErrors = $true
                $functionsTestName = $TestName
            }
            else {
                
                $functionsTestName = Get-TestingFunctionPrefix -TestingModuleName ($TestingModuleName )
                
            } 
            
            $functionsTest += Get-Command -Name $functionsTestName -Module $TestingModuleName -ErrorAction SilentlyContinue
            
            $start = Get-Date

            $result = $functionsTest | Start-TestingFunction -ShowTestErrors:$ShowTestErrors

            $time = ($start | New-TimeSpan ).ToString("hh\:mm\:ss\:FFFF")
            
            $result | Add-Member -NotePropertyName "Name" -NotePropertyValue $Name
            $result | Add-Member -NotePropertyName "TestModule" -NotePropertyValue $TestingModuleName
            $result | Add-Member -NotePropertyName "TestsName" -NotePropertyValue $functionsTestName
            $result | Add-Member -NotePropertyName "Tests" -NotePropertyValue $functionsTest.Length
            $result | Add-Member -NotePropertyName "Time" -NotePropertyValue $time

            Write-Host  -ForegroundColor DarkCyan 
            $TestingModuleName | Write-Host  -ForegroundColor Green -NoNewline
            " results - " | Write-Host  -ForegroundColor DarkCyan -NoNewline
            Out-SingleResultData -Name "Pass"           -Value $result.Pass           -Color "Yellow"
            Out-SingleResultData -Name "Failed"         -Value $result.Failed         -Color "Red"
            Out-SingleResultData -Name "Skipped"        -Value $result.Skipped        -Color "Yellow"
            Out-SingleResultData -Name "NotImplemented" -Value $result.NotImplemented -Color "Red"
            Write-Host  -ForegroundColor DarkCyan 

            $result

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
        [switch] $Force
    )

    if ($Name) {
        $moduleName = $Name
    }

    if ($TargetModule) {
  
        Import-TargetModule -Name $TargetModule -Force

        $modulePath = (Get-Module -Name $TargetModule).Path
    
        $moduleName = Join-Path -Path (Split-Path -Path $modulePath -Parent) -ChildPath (Get-TestingModuleName -TargetModule $TargetModule)

        if (-not (Test-Path -Path $moduleName)) {
            Write-Warning -Message "TestingModule for module [ $TargetModule ] not found at [ $moduleName ]"
            return
        }
    }
    
    Import-Module -Name $moduleName -Force:$Force -Global
}

function Import-TargetModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string] $Name,
        [switch] $Force
    )

    Import-Module -Name $Name -Force:$Force -Global
}

function Start-TestModule {
    [CmdletBinding()] 
    param (
        [Parameter(Mandatory, Position = 0)][string] $TestModuleName,
        [Parameter()][string] $Prefix,
        [Parameter()][string] $ModuleName
    )

    if ($ModuleName) {
        Import-Module -Name $ModuleName
    }

    Write-Host "Running Test Module [ $TestModuleName ] ..." -ForegroundColor DarkYellow
    Import-TestingModule -Name $TestModuleName

    if ($Prefix) {
        Write-Host "Filtering functions by Prefix [ $Prefix ] ..." -ForegroundColor DarkYellow
        $functions = Get-Command -Module $TestModuleName -Name $Prefix*
    }
    else { 
        $functions = Get-Command -Module $TestModuleName 
    }

    $functions | ForEach-Object {
        Start-TestingFunction -FunctionName $_.Name
    }
}

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

    Assert -Condition ([string]::IsNullOrEmpty($Expected)) -Expected $false -Comment "[Assert-Contains] Expected can not be empty"

    Assert-IsTrue -Condition ($Presented.Contains($Expected)) -Comment  ("[Assert-Contains] Expected[{0}] present on {1}" -f $Expected, $Presented)
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


function GetRooTestingFolderPath{
    $rd = Get-Date -Format yyMMdd
    $path = Join-Path -Path "Temp:" -ChildPath ("Posh_Testing_" + $rd)
    return $path
}

#Modules
function New-Module {
<#
.Synopsis
   Created a Powershell module with BiT21 format.
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Description,
        [Parameter()][string]$Path,
        [Parameter()][switch]$AvoidModuleFile,
        [Parameter()][switch]$AvoidTestFile,
        [Parameter()][String]$AppendToModuleFile
    )    

    $AUTHOR = 'rulasg'
    $ModuleName = $Name

    if (!$Path) {
        $Path = '.'
    }

    $modulePath = Join-Path -Path $Path -ChildPath $Name

    if(Test-Path($modulePath)){
        throw "Folder already exists"
    } else {
       $null = New-Item -ItemType Directory -Name $modulePath
    }

    # Manifest
    $filename = "$ModuleName.psd1"
    
    New-ModuleManifest `
        -Path (Join-Path -Path $modulePath -ChildPath $filename) `
        -RootModule "$ModuleName.psm1" `
        -Author        $AUTHOR `
        -ModuleVersion '0.1' `
        -Description   $Description `
        #-CompanyName   "rulasg" `
        #-Copyright     "(c) 2021 rulasg. All rights reserved."  `
        # -RequiredModules 'BaseSDK' `
        # -DefaultCommandPrefix $ModuleName 

    # Module File
    if (-Not $AvoidModuleFile)
    {
        NewModulefile -Path $modulePath -ModuleName $ModuleName -Author $AUTHOR -Description $Description -Append $AppendToModuleFile
    }    

    # Testing module
    if (-Not $AvoidTestFile)
    {
        New-TestingModule -Path $modulePath -ModuleName $ModuleName
        New-TestingVsCodeLaunchJson -Path $modulePath -ModuleName $ModuleName
    }

    return $modulePath
}

function NewModulefile($Path, $ModuleName, $Author, $Description, $Append){
    $myString = 
@'
<# 
.Synopsis 
_XMODULE_

.Description
_DESCRIPTION_

.Notes 
NAME  : _XMODULE_.psm1*
AUTHOR: _AUTHOR_   

CREATED: _CREATED_TIME_
#>

Write-Host "Loading _XMODULE_ ..." -ForegroundColor DarkCyan
'@
    $myString = $myString.Replace('_XMODULE_',$ModuleName)
    $myString = $myString.Replace('_DESCRIPTION_',$Description)
    $myString = $myString.Replace('_AUTHOR_',$AUTHOR)
    $myString = $myString.Replace('_CREATED_TIME_',(Get-Date).ToShortDateString());

    if ($Append) {
        $myString+=$Append
    }

    $myString |  Out-File -FilePath (Join-Path -Path $Path -ChildPath "$ModuleName.psm1")
} 

function New-TestingModule($Path, $ModuleName){

    $testingModuleName = $ModuleName + "Test"

    $testScript = 
@'
[CmdletBinding()]
param ()

$ModuleName = "_XMODULE_"

Import-Module -Name TestingHelper -Force

Test-Module -Name $ModuleName 
'@

    $testingModulePs1 = "$TestingModuleName.ps1"
    
    $testScript = $testScript.Replace('_XMODULE_',$ModuleName)
    $testScript = $testScript.Replace('_CREATED_TIME_',(Get-Date).ToShortDateString());
    
    $testScript |  Out-File -FilePath (Join-Path -Path $Path -ChildPath $testingModulePs1)

    $toAppend =
@'


function _MODULE_TESTING__Sample(){
    Assert-IsTrue -Condition $true
}

Export-ModuleMember -Function _MODULE_TESTING__*
'@

    $toAppend = $toAppend.Replace('_MODULE_TESTING_',$testingModuleName)

    $null = New-Module -Path $Path -Name $testingModuleName -Description "Testing module for $ModuleName" -AvoidTestFile -AppendToModuleFile $toAppend
}   

function New-TestingVsCodeLaunchJson($Path, $ModuleName){
    $testScript = 
@'
    {
        // Use IntelliSense to learn about possible attributes.
        // Hover to view descriptions of existing attributes.
        // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
        "version": "0.2.0",
        "configurations": [
            {
                "name": "PowerShell: _XMODULE_.ps1",
                "type": "PowerShell",
                "request": "launch",
                "script": "${workspaceFolder}/_XMODULE_Test.ps1",
                "cwd": "${workspaceFolder}"
            }
        ]
    }
'@

    $testScript = $testScript.Replace('_XMODULE_',$ModuleName)

    New-Item `
        -ItemType File `
        -Path (Join-Path -Path $Path -ChildPath '.vscode' -AdditionalChildPath 'launch.json') `
        -Value $testScript `
        -Force `
        | Out-Null
}

