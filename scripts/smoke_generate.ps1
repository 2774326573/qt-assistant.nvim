param(
    [string]$OutDir
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg) {
    Write-Host "[qt-assistant smoke] $msg"
}

$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    throw "nvim not found in PATH. Please install Neovim and ensure 'nvim' is available."
}

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $OutDir = Join-Path $env:TEMP "qt-assistant-smoke-$stamp"
}

$OutDir = (Resolve-Path -LiteralPath (New-Item -ItemType Directory -Force -Path $OutDir).FullName).Path

$luaRoot = $OutDir.Replace('\\','/')

Write-Step "Repo: $repoRoot"
Write-Step "Output: $OutDir"

Push-Location $repoRoot
try {
    $lua = @"
local pm = require('qt-assistant.project_manager')
local root = [[$luaRoot]]

pm.new_project('SmokeProject', 'multi_project', '17', root, { enable_tests = false })
local ws = root .. '/SmokeProject'

pm.add_module('core_qt', 'shared_lib', ws, { enable_tests = true, test_framework = 'qt' })
pm.add_module('core_gtest', 'shared_lib', ws, { enable_tests = true, test_framework = 'gtest' })
"@

    Write-Step "Generating projects via headless nvim..."
    & nvim --headless "+lua $lua" +qa

    $wsPath = Join-Path $OutDir 'SmokeProject'
    $checks = @(
        (Join-Path $wsPath 'CMakeLists.txt'),
        (Join-Path $wsPath 'core_qt\CMakeLists.txt'),
        (Join-Path $wsPath 'core_qt\tests\CMakeLists.txt'),
        (Join-Path $wsPath 'core_gtest\tests\CMakeLists.txt')
    )

    foreach ($p in $checks) {
        if (-not (Test-Path -LiteralPath $p)) {
            throw "Smoke check failed: missing $p"
        }
    }

    Write-Step "OK. Generated workspace: $wsPath"
    Write-Step "Tip: open it and run :QtBuild / :QtExport as usual."
}
finally {
    Pop-Location
}
