# TestingHelper Powershell Module

This `module` contains `functions` to help create and run Unit Testing for Powershell modules.

## CI/CD Status

**Main**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Publish on Release Published](https://github.com/rulasg/TestingHelper/actions/workflows/publish_module_on_release.yml/badge.svg)](https://github.com/rulasg/TestingHelper/actions/workflows/publish_module_on_release.yml)

**release/v2**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg?branch=release%2Fv2)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg?branch=release%2Fv2)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Publish on Release Published](https://github.com/rulasg/TestingHelper/actions/workflows/publish_module_on_release.yml/badge.svg?branch=release%2Fv2)](https://github.com/rulasg/TestingHelper/actions/workflows/publish_module_on_release.yml)

**release/v3**
[![powershell](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml/badge.svg?branch=release%2Fv3)](https://github.com/rulasg/TestingHelper/actions/workflows/powershell.yml)
[![Test with TestingHelper](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml/badge.svg?branch=release%2Fv3)](https://github.com/rulasg/TestingHelper/actions/workflows/test_with_TestingHelper.yml)
[![Publish on Release Published](https://github.com/rulasg/TestingHelper/actions/workflows/publish_module_on_release.yml/badge.svg?branch=release%2Fv3)](https://github.com/rulasg/TestingHelper/actions/workflows/publish_module_on_release.yml)

## How to use it

This library will allow you to create quick unit testing for a given module. It will provide Asset statements too for the assertion section of your tests.

Use `New-Module`  to create the full set with testing and `.vscode/launth.json`

If you have a module you want to add testing too use `New-TestingModule`

Follow naming convention for easier use. Function names `ModuleNameTest_*` will be consideres test to PASS.

## Version 2.0

> Moving to `2.0`as I am not sure if this version will break compatibility with the previous one.

- Make development compatible with Codespaces
- Remove unecesary dependencies
- First version of about help
- Improve testing output
- Assert Functions
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
- Functions to help on the arrangement
  - New-TestingFile
  - Remove-TestingFile
  - New-TestingFolder

