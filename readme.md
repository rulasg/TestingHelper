# TestingHelper Powershell Module

This `module` contains `functions` to help create and run Unit Testing for Powershell modules.

## Backlog

| #   | Module/Area   | Type | Name                      | Status | Description                                                                   | Comments |
| --- | ------------- | ---- | ------------------------- | ------ | ----------------------------------------------------------------------------- | -------- |
| [ ] | TestingHelper | DCR  | Start-Test Return Objects | New    | Change execution frame work to return objects and not display run status text |          |
| [ ] | TestingHelper | DCR  | NoteBook                  | New    | Create help notebook                                                          |          |

## How to use it

This library will allow you to create quick unit testing for a given module. It will provide Asset statements too for the assertion section of your tests.

Use `New-Module`  to create the full set with testing and `.vscode/launth.json`

If you have a module you want to add testing too use `New-TestingModule`

Follow naming convention for easier use. Function names `ModuleNameTest_*` will be consideres test to PASS.