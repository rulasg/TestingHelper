# Structure of a Module

## Module

   1. Module Manifest
      1. Module Script(s)
   2. About
   3. license (MIT)
   4. devcontainer.json

## Testing

   1. Testing
      1. Test module
         1. Module manifest
         2. Module script(s)
      2. launch.json
      3. test.ps1

## Tools Scripts

   1. publish.ps1
      1. deploy.Helper.ps1er.ps1
   2. release.ps1
   3. sync.ps1
      1. sync.Helper.ps1

## Workflows

   1. PSScriptAnalyzer.yml
   2. publish_module_on_release.yml - publish.ps1
   3. test_with_TestingHelper.yml - test.ps1
