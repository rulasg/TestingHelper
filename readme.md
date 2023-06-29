# TestingHelper Powershell Module

This `module` contains `functions` to help create and run Unit Testing for Powershell modules.

## CI/CD Status

**Current**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Deploy on Release Deployed](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml/badge.svg)](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml)

**Main**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg?branch=main)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg?branch=main)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Deploy on Release Published](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml/badge.svg?branch=main)](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml)

**release/v3**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg?branch=release%2Fv3)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg?branch=release%2Fv3)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Deploy on Release Published](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml/badge.svg?branch=release%2Fv3)](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml)

**release/v2**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg?branch=release%2Fv2)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg?branch=release%2Fv2)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Deploy on Release Published](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml/badge.svg?branch=release%2Fv2)](https://github.com/rulasg/TestingHelper/actions/workflows/deploy_module_on_release.yml)

## How to use it

This library will allow you to create a PowerShell Module with all the gearing for a full SDLC on GitHub platform.

- Create a Module with sample code
- Add Testing for sample tests
- Add Module gearing
- Add Helper scripts to create releases and deploy
- Add GitHub Worflows for Code Analysis, Testing and Deploy

[Information on how to use it on the Docs](docs/index.md)

## API V3

### Testing

- Invoke-TestingHelper
- Import-TestingModule
- Test-Module (*ObsoleteAttribute*)
- Test-ModulelocalPSD1 (*ObsoleteAttribute*)

### Tracing

- Trace-Message
- Write-AssertionSectionEnd

### Files and Folders

- New-TestingFile
- New-TestingFolder
- Remove-TestingFile
- Remove-TestingFolder

### New Module

- New-Module (Alias New-ModuleV3)
- New-ModuleV1
- New-ModuleV2
- New-ModuleV3

- Add-ModuleV3

### Add Testing

- New-TestingModule
- Add-TestModuleV3

### AddToModule*

- Add-ToModuleAll
- Add-ToModuleSampleCode
  
- Add-ToModuleAbout
- Add-ToModuleReadme
- Add-ToModuleLicense
- Add-ToModuleDevContainerJson
- Add-ToModuleGitRepository

- Add-ToModuleDeployScript
- Add-ToModuleReleaseScript
- Add-ToModuleSyncScript

- Add-ToModuleTestAll

- Add-ToModuleLaunchJson
- Add-ToModuleTestScript
- Add-ToModuleTestModule
- Add-ToModuleTestSampleCode

- Add-ToModuleDeployWorkflow
- Add-ToModulePSScriptAnalyzerWorkflow
- Add-ToModuleTestWorkflow

### Asserts

- Assert-AreEqual
- Assert-AreEqualContent
- Assert-AreEqualPath
- Assert-AreEqualSecureString
- Assert-AreNotEqual
- Assert-AreNotEqualContent
- Assert-AreNotEqualPath
- Assert-CollectionIsNotNullOrEmpty
- Assert-CollectionIsNullOrEmpty
- Assert-ContainedXOR
- Assert-Contains
- Assert-ContainsPath
- Assert-Count
- Assert-CountTimes
- Assert-FileContains
- Assert-FilesAreEqual
- Assert-FilesAreNotEqual
- Assert-IsFalse
- Assert-IsGuid
- Assert-IsNotNull
- Assert-IsNull
- Assert-IsTrue
- Assert-ItemExist
- Assert-ItemNotExist
- Assert-NotContains
- Assert-NotContainsPath
- Assert-NotImplemented
- Assert-SkipTest
- Assert-StringIsNotNullOrEmpty
- Assert-StringIsNullOrEmpty
