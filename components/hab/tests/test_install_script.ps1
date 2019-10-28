Describe "Install habitat using install.ps1" {
    It "can install the latest version of Habitat" {
        components/hab/install.ps1
        $LASTEXITCODE | Should -Be 0
    }

    It "can install a specific version of Habitat" {
        components/hab/install.ps1 -v 0.89.46
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
