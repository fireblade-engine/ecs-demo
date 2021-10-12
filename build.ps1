$oldwd = $PWD
Set-Location .build/checkouts/SwiftSDL2
./genshim.ps1
Set-Location $oldwd
foreach($config in "debug", "release") {
    swift build --configuration $config
}
.build/checkouts/SwiftSDL2/copylibs.ps1
