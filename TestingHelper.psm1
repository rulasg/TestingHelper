
Write-Host "Loading TestingHelper ..." -ForegroundColor DarkCyan

Set-Variable -Name TestRunFolderName -Value "TestRunFolder" 

function GetTestingModuleName ([string] $TargetModule) { return ($TargetModule + "Test") }
function GetTestingFunctionPrefix ([string] $TestingModuleName) { return ($TestingModuleName + "_*") }

function Trace-Message {
    [CmdletBinding()]
    param (
        [Parameter(Position = 1)]
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
        #Write-Host "." -NoNewline -ForegroundColor DarkMagenta
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
        [Parameter()] [switch] $ShowError
    )

    Process {

        if ($FunctionInfo) {
            $FunctionName = $FunctionInfo.Name
        }
        Write-Verbose -Message "Running [ $FunctionName ]"
    
        $local = Push-TestingFolder -Path $FunctionName
    
        try {
            Write-Host "$FunctionName ... [" -NoNewline -ForegroundColor DarkCyan 
            & $FunctionName 
            Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
            Write-Host "PASS"  -ForegroundColor DarkYellow 
        }
        catch {
    
            if ($_.Exception.Message -eq "SKIP_TEST") {
                Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
                Write-Host "Skip"  -ForegroundColor Magenta 
            }
            else {
                Write-Host "x"  -NoNewline -ForegroundColor Red 
                Write-Host "] "  -NoNewline -ForegroundColor DarkCyan 
                Write-Host "Failed"  -ForegroundColor Red 
                
                if ($ShowError) {
                    $_
                }
            }
        }
        finally {
            $local | Pop-TestingFolder -Force
        }
    }
}

function Test-Module {
    [CmdletBinding()] 
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName,Position = 0)] [string] $Name,
        [Parameter( Position = 1)] [string] $TestName,
        [Parameter()] [switch] $ShowError
    )

    process {

        Write-Verbose "Running tests for Module [ $Name ] functions [ $TestName ] "

        $local = Push-TestingFolder

        try {

            Import-TestingModule -TargetModule $Name -Force

            $TestingModuleName = GetTestingModuleName -TargetModule $Name

            $functionsTest = @()

            #Use standar testing fucntions prfix
            if ( $TestName) {
                # Filter based on TestFunction names
                $ShowError = $true
                $functionsTest += Get-Command -Name $TestName -Module $TestingModuleName 
            }
            else {
                # Legacy
                $TestName = GetTestingFunctionPrefix -TestingModuleName ($TestingModuleName )
                $functionsTest += Get-Command -Name $TestName -Module $TestingModuleName 
                
                # New function name Test-*
                $functionsTest += Get-Command -Name "Test-*" -Module $TestingModuleName 
            } 
            
            $functionsTest | Start-TestingFunction -ShowError:$ShowError

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
    
        $moduleName = Join-Path -Path (Split-Path -Path $modulePath -Parent) -ChildPath (GetTestingModuleName -TargetModule $TargetModule)

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

    Assert -Condition $false -Expected $true -Comment "Function not implemented"
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
    if ($Object) {
        $isNull = $false
    }
    else {
        $isNull = $true
    }
    Assert-IsFalse -Condition $isNull -Comment ("Object is null -" + $Comment)
}

function Assert-IsNull {
    [CmdletBinding()]
    param (
        $Object
    )

    if ($Object) {
        $isNull = $false
    }
    else {
        $isNull = $true
    }
    Assert-IsTrue -Condition $isNull -Comment "IsNull"
}
function Assert-AreEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment

    )

    Assert-IsTrue -Condition ($Expected -eq $Presented) -Comment ("Object are not Equal : Expected [ $Expected ] and presented [ $Presented] - " + $Comment)
}

function Assert-AreNotEqual {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [object] $Expected,
        [Parameter(Mandatory)] [object] $Presented,
        [Parameter()] [string] $Comment
    )

    Assert-IsFalse -Condition ($Expected -eq $Presented) -Comment ("Object are Equal : Expecte [ $Expected ] and presented [ $Presented] - " + $Comment)

}

function Assert-ItemExist {
    param(
        [string] $Path
    )
    try {
        Assert-IsTrue -Condition ($Path | Test-Path)
    }
    catch {
        throw "Item does not exist [ $Path ]"
    }
}

function Assert-ItemNotExist {
    param(
        [string] $Path
    )
    try {
        Assert-IsFalse -Condition ($Path | Test-Path)
    }
    catch {
        throw "Item does not exist [ $Path ]"
    }
}

function Assert-IsGuid{
    param(
        [string] $Presented
    )
    try {
        Assert-IsNotNull -Object (New-Object -TypeName System.Guid -ArgumentList $Presented)
    }
    catch {
        throw "String is not a valid Guid"
    }
}

function Assert-Count {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [int] $Expected,
        [Parameter(Mandatory)] [object] $Presented
    )
    Assert-IsTrue -Condition ($Presented.Length -eq $Expected)
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
        [Parameter(Mandatory)] [string] $Path
    )

    # Need to consolidate as mkdir behaves diferent on PC or Mac
    $result = New-Item -ItemType Directory -Path $Path 

    Write-Verbose -Message "Created Diretory [ $result ] "
}

function GetRooTestingFolderPath{
    $rd = Get-Date -Format yyMMdd
    $path = Join-Path -Path "Temp:" -ChildPath ("Posh_Testing_" + $rd)
    return $path
}
