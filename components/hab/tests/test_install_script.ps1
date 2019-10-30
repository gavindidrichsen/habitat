Describe "Install habitat using install.ps1" {
    It "can install the latest version of Habitat" {
        components/hab/install.ps1 -c dev
        $LASTEXITCODE | Should -Be 0
        (Get-Command hab).Path | Should -Be "C:\ProgramData\Habitat\hab.exe"
    }

    It "can install a specific version of Habitat" {
        components/hab/install.ps1 -v 0.89.46 -c dev
        $LASTEXITCODE | Should -Be 0

        $result = hab --version
        $result | Should -Match "hab 0.89.46/*"
    }

    It "can install a specific version of Habitat from Bintray" {
        components/hab/install.ps1 -v 0.79.1
        $LASTEXITCODE | Should -Be 0

        $result = hab --version
        $result | Should -Match "hab 0.79.1/*"
    }
}
