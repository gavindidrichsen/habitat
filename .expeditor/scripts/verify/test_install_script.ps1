hab pkg install core/pester --channel stable
Import-Module "$(hab pkg path core/pester)\module\pester.psd1"
$env:HAB_NOCOLORING = "true"

Invoke-Pester components/hab/tests/test_install_script.ps1 -EnableExit

