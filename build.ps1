<#
$embree_version="2.16.4"
$tbb_version="tbb2017_20170604oss"

# unzip function
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

# donwload embree source code
wget "https://github.com/embree/embree/archive/v${embree_version}.zip" -OutFile "embree.zip"

# donwload prebuild tbb
wget "https://github.com/01org/tbb/releases/download/2017_U7/${tbb_version}_win.zip" -OutFile "${tbb_version}.zip"

# unzip
Unzip "$PWD\embree.zip" "$PWD"

# rename unzipped directory to tbb to ease packaging

If (Test-Path embree) {
	Remove-Item -Recurse -Force embree
}

rni embree-${embree_version} embree

# unzip tbb to embree/
Unzip "$PWD\${tbb_version}.zip" "$PWD\embree\"

# rename tbb
cd embree
rni ${tbb_version} tbb
cd ..
#>

# prepare win64 project
mkdir target_x64
cd target_x64
cmake -G "Visual Studio 15 2017 Win64" -T "Intel C++ Compiler 17.0" ../embree -DEMBREE_ISPC_SUPPORT:bool=false
cd ..

#prepare win32 project
mkdir target_x86
cd target_x86
cmake -G "Visual Studio 15 2017" -T "Intel C++ Compiler 17.0" ../embree -DEMBREE_ISPC_SUPPORT:bool=false
cd ..

#build win64
cd target_x64
cmake --build . --target embree --config Release
cmake --build . --target embree --config Debug
cd ..

#build win32
cd target_x86
cmake --build . --target embree --config Release
cmake --build . --target embree --config Debug
cd ..
