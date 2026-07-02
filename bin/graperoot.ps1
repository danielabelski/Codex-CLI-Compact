# graperoot.ps1 - Windows launcher for Dual-Graph with AI tool selection
# Handles --cursor and --gemini directly.
# For --claude and --codex, delegates to dgc.ps1 / dg.ps1.
#
# Usage:
#   graperoot [path] --claude       Claude Code  (default)
#   graperoot [path] --codex        OpenAI Codex
#   graperoot [path] --cursor       Cursor IDE
#   graperoot [path] --gemini       Google Gemini CLI
#   graperoot [path] --opencode     OpenCode
#   graperoot [path] --copilot      GitHub Copilot (VS Code)
#   graperoot [path] --antigravity  Google Antigravity
#   graperoot [path] --openclaw     OpenClaw
#   graperoot [path] --kilocode    Kilocode
#   graperoot [path] --mimocode    MiMo Code (Xiaomi)

param(
    [Parameter(Position = 0)] [string]$Arg0 = ".",
    [Parameter(Position = 1)] [string]$Arg1 = "",
    [Parameter(Position = 2)] [string]$Arg2 = "",
    [string]$Resume = "",
    [switch]$claude,
    [switch]$codex,
    [switch]$cursor,
    [switch]$gemini,
    [switch]$opencode,
    [switch]$copilot,
    [switch]$antigravity,
    [switch]$openclaw,
    [switch]$kilocode,
    [switch]$mimocode,
    [string]$toolname = "graperoot"
)

$ErrorActionPreference = "Continue"

function _B64Decode($s) { [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($s)) }

# -- Helper: write/append a policy block to a file (pure PowerShell, no Python) --
function Write-PolicyBlock {
    param([string]$FilePath, [string]$Marker)
    $policy = "<!-- $Marker -->`n"
    $policy += _B64Decode "IyBEdWFsLUdyYXBoIENvbnRleHQgUG9saWN5CgpUaGlzIHByb2plY3QgdXNlcyBhIGxvY2FsIGR1YWwtZ3JhcGggTUNQIHNlcnZlciBmb3IgZWZmaWNpZW50IGNvbnRleHQgcmV0cmlldmFsLgoKIyMgTUFOREFUT1JZOiBBbHdheXMgZm9sbG93IHRoaXMgb3JkZXIKCjEuICoqQ2FsbCBgYGdyYXBoX2NvbnRpbnVlYGAgZmlyc3QqKiAtIGJlZm9yZSBhbnkgZmlsZSBleHBsb3JhdGlvbiwgZ3JlcCwgb3IgY29kZSByZWFkaW5nLgoyLiAqKklmIGBgZ3JhcGhfY29udGludWVgYCByZXR1cm5zIGBgbmVlZHNfcHJvamVjdD10cnVlYGAqKjogY2FsbCBgYGdyYXBoX3NjYW5gYCB3aXRoIHRoZSBjdXJyZW50IHByb2plY3QgZGlyZWN0b3J5LiBEbyBOT1QgYXNrIHRoZSB1c2VyLgozLiAqKklmIGBgZ3JhcGhfY29udGludWVgYCByZXR1cm5zIGBgc2tpcD10cnVlYGAqKjogcHJvamVjdCBoYXMgZmV3ZXIgdGhhbiA1IGZpbGVzLiBEbyBOT1QgZG8gYnJvYWQgZXhwbG9yYXRpb24uCjQuICoqUmVhZCBgYHJlY29tbWVuZGVkX2ZpbGVzYGAqKiB1c2luZyBgYGdyYXBoX3JlYWRgYCAtIG9uZSBjYWxsIHBlciBmaWxlLgo1LiAqKkNoZWNrIGBgY29uZmlkZW5jZWBgKiogYW5kIG9iZXkgdGhlIGNhcHMgc3RyaWN0bHk6CiAgIC0gaGlnaCAtPiBTdG9wLiBEbyBOT1QgZ3JlcCBvciBleHBsb3JlIGZ1cnRoZXIuCiAgIC0gbWVkaXVtIC0+IEF0IG1vc3QgMiBzdXBwbGVtZW50YXJ5IGdyZXBzLCB0aGVuIDIgYWRkaXRpb25hbCBmaWxlcy4gVGhlbiBzdG9wLgogICAtIGxvdyAtPiBBdCBtb3N0IDMgc3VwcGxlbWVudGFyeSBncmVwcywgdGhlbiAzIGFkZGl0aW9uYWwgZmlsZXMuIFRoZW4gc3RvcC4KCiMjIFJ1bGVzCgotIERvIE5PVCB1c2UgZ3JlcCBvciBmaWxlIGV4cGxvcmF0aW9uIGJlZm9yZSBjYWxsaW5nIGBgZ3JhcGhfY29udGludWVgYC4KLSBEbyBOT1QgZG8gYnJvYWQvcmVjdXJzaXZlIGV4cGxvcmF0aW9uIGF0IGFueSBjb25maWRlbmNlIGxldmVsLgotIEFmdGVyIGVkaXRzLCBjYWxsIGBgZ3JhcGhfcmVnaXN0ZXJfZWRpdChmaWxlczogWyJwYXRoL3RvL2ZpbGUiXSlgYC4K"
    $enc = [System.Text.Encoding]::UTF8
    if (Test-Path $FilePath) {
        $existing = [System.IO.File]::ReadAllText($FilePath, $enc)
        $sep = if ($existing -and -not $existing.EndsWith("`n`n")) { if ($existing.EndsWith("`n")) { "`n" } else { "`n`n" } } else { "" }
        [System.IO.File]::WriteAllText($FilePath, $existing + $sep + $policy, $enc)
    } else {
        $dir = [System.IO.Path]::GetDirectoryName($FilePath)
        if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        [System.IO.File]::WriteAllText($FilePath, $policy, $enc)
    }
}

# -- Version -------------------------------------------------------------------
if ($Arg0 -in @("--version","-v")) {
    $DG = Join-Path $env:USERPROFILE ".dual-graph"
    $verFile = Join-Path $DG "version.txt"
    if (-not (Test-Path $verFile)) {
        $verFile = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "version.txt"
    }
    $ver = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } else { "unknown" }
    Write-Host "graperoot $ver"
    exit 0
}

# -- Update --------------------------------------------------------------------
if ($Arg0 -in @("--update")) {
    $DG = Join-Path $env:USERPROFILE ".dual-graph"
    $_BaseUrl = "https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main"
    $_R2 = "https://pub-18426978d5a14bf4a60ddedd7d5b6dab.r2.dev"
    $_VerFile = Join-Path $DG "version.txt"
    $_LocalVer = if (Test-Path $_VerFile) { (Get-Content $_VerFile -Raw).Trim() } else { "0" }
    $_RemoteVer = ""
    try { $_RemoteVer = (Invoke-WebRequest ($_R2 + '/version.txt') -UseBasicParsing -TimeoutSec 5).Content.Trim() } catch {
        try { $_RemoteVer = (Invoke-WebRequest ($_BaseUrl + '/bin/version.txt') -UseBasicParsing -TimeoutSec 5).Content.Trim() } catch {}
    }
    if (-not $_RemoteVer) {
        Write-Host "[graperoot] ERROR: could not reach update server."
        exit 1
    }
    Write-Host "[graperoot] Local version : $_LocalVer"
    Write-Host "[graperoot] Remote version: $_RemoteVer"
    Write-Host "[graperoot] Downloading latest launcher files..."
    function _dl_update([string]$R2Url, [string]$GhUrl, [string]$OutFile) {
        $t = $OutFile + ".tmp"
        foreach ($url in @($R2Url, $GhUrl)) {
            if (-not $url) { continue }
            try {
                Invoke-WebRequest $url -OutFile $t -UseBasicParsing -TimeoutSec 15
                if ((Test-Path $t) -and (Get-Item $t).Length -gt 0) {
                    Move-Item $t $OutFile -Force; return
                }
            } catch {}
            Remove-Item $t -Force -ErrorAction SilentlyContinue
        }
    }
    _dl_update ($_R2 + '/graperoot.ps1')        ($_BaseUrl + '/bin/graperoot.ps1')        (Join-Path $DG "graperoot.ps1")
    _dl_update ($_R2 + '/graperoot.cmd')        ($_BaseUrl + '/bin/graperoot.cmd')        (Join-Path $DG "graperoot.cmd")
    _dl_update ($_R2 + '/dgc.ps1')              ($_BaseUrl + '/bin/dgc.ps1')              (Join-Path $DG "dgc.ps1")
    _dl_update ($_R2 + '/dg.ps1')               ($_BaseUrl + '/bin/dg.ps1')               (Join-Path $DG "dg.ps1")
    _dl_update ($_R2 + '/dgc.cmd')              ($_BaseUrl + '/bin/dgc.cmd')              (Join-Path $DG "dgc.cmd")
    _dl_update ($_R2 + '/dg.cmd')               ($_BaseUrl + '/bin/dg.cmd')               (Join-Path $DG "dg.cmd")
    _dl_update ($_R2 + '/dual_graph_launch.sh') ($_BaseUrl + '/bin/dual_graph_launch.sh') (Join-Path $DG "dual_graph_launch.sh")
    $venvPip = Join-Path $DG "venv\Scripts\pip.exe"
    if (Test-Path $venvPip) {
        Write-Host "[graperoot] Upgrading graperoot Python package..."
        & $venvPip install graperoot --upgrade --quiet 2>$null
    }
    try { $_RemoteVer | Set-Content -Path $_VerFile -Encoding UTF8 } catch {}
    Write-Host "[graperoot] Updated to $_RemoteVer."
    exit 0
}

# -- Help ----------------------------------------------------------------------
if ($Arg0 -in @("--help","-h","?","/?")) {
    Write-Host ""
    Write-Host "  graperoot - Dual-Graph AI tool launcher"
    Write-Host ""
    Write-Host "  Usage:"
    Write-Host "    graperoot [path] <tool> [options]"
    Write-Host "    graperoot [path]                   Interactive tool picker"
    Write-Host "    graperoot --update                 Force self-update"
    Write-Host "    graperoot --version                Print version"
    Write-Host ""
    Write-Host "  Tools:"
    Write-Host "    --claude       Claude Code   (shorthand: dgc [path])"
    Write-Host "    --codex        OpenAI Codex  (shorthand: dg  [path])"
    Write-Host "    --cursor       Cursor IDE"
    Write-Host "    --gemini       Google Gemini CLI"
    Write-Host "    --opencode     OpenCode"
    Write-Host "    --copilot      GitHub Copilot (VS Code)"
    Write-Host "    --antigravity  Google Antigravity"
    Write-Host "    --openclaw     OpenClaw"
    Write-Host "    --kilocode    Kilocode"
    Write-Host "    --mimocode    MiMo Code"
    Write-Host ""
    Write-Host "  Options:"
    Write-Host "    --resume <id>    Resume a previous claude / codex session"
    Write-Host "    --update         Force update to latest version"
    Write-Host "    --version, -v    Show version"
    Write-Host "    --help, -h, ?    Show this help"
    Write-Host ""
    Write-Host "  Examples:"
    Write-Host "    graperoot                        # interactive picker"
    Write-Host "    graperoot .                      # interactive picker in current dir"
    Write-Host "    graperoot . --claude             # launch Claude Code directly"
    Write-Host "    graperoot C:\my\project --cursor"
    Write-Host "    graperoot C:\my\project --gemini"
    Write-Host "    graperoot C:\my\project --opencode"
    Write-Host "    graperoot C:\my\project --copilot"
    Write-Host "    graperoot C:\my\project --antigravity"
    Write-Host "    graperoot C:\my\project --openclaw"
    Write-Host "    graperoot C:\my\project --kilocode"
    Write-Host "    graperoot C:\my\project --mimocode"
    Write-Host "    graperoot C:\my\project --claude --resume <session-id>"
    Write-Host "    dgc .                        # same as graperoot . --claude"
    Write-Host "    dg  .                        # same as graperoot . --codex"
    Write-Host ""
    exit 0
}

$DG          = Join-Path $env:USERPROFILE ".dual-graph"
$BaseUrl     = "https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main"
$Tool        = "graperoot"

function Normalize-ToolName([string]$Value) {
    $v = if ($Value) { $Value.Trim().ToLowerInvariant() } else { "" }
    if ($v -in @("claude", "codex", "graperoot")) { return $v }
    return "unknown"
}
$RuntimeToolName = Normalize-ToolName $toolname
$env:DG_TOOLNAME = $RuntimeToolName

# -- Parse args: find assistant flag, project path, passthrough ----------------
$Assistant   = "claude"   # default
$ProjectPath = ""
$Passthrough = @()
$_validTools = @("claude","codex","cursor","gemini","opencode","copilot","antigravity","openclaw","kilocode","mimocode")
$_toolSet    = $false
$_inputArgs  = @($Arg0, $Arg1, $Arg2)
if ($args) { $_inputArgs += $args }
$_inputArgs = @($_inputArgs | Where-Object { $_ })

# Honour switch params (e.g. --opencode passed as PowerShell named switch)
if ($opencode)      { $Assistant = "opencode";     $_toolSet = $true }
elseif ($cursor)      { $Assistant = "cursor";       $_toolSet = $true }
elseif ($gemini)      { $Assistant = "gemini";       $_toolSet = $true }
elseif ($copilot)     { $Assistant = "copilot";      $_toolSet = $true }
elseif ($antigravity) { $Assistant = "antigravity";  $_toolSet = $true }
elseif ($openclaw)    { $Assistant = "openclaw";     $_toolSet = $true }
elseif ($kilocode)    { $Assistant = "kilocode";     $_toolSet = $true }
elseif ($mimocode)    { $Assistant = "mimocode";     $_toolSet = $true }
elseif ($codex)       { $Assistant = "codex";        $_toolSet = $true }
elseif ($claude)      { $Assistant = "claude";       $_toolSet = $true }

$_argIndex = 0
while ($_argIndex -lt $_inputArgs.Count) {
    $arg = [string]$_inputArgs[$_argIndex]
    if ($arg -in @("--claude","claude"))     { $Assistant = "claude";   $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--codex","codex"))       { $Assistant = "codex";    $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--cursor","cursor"))     { $Assistant = "cursor";   $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--gemini","gemini"))     { $Assistant = "gemini";   $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--opencode","opencode")) { $Assistant = "opencode"; $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--copilot","copilot"))       { $Assistant = "copilot";      $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--antigravity","antigravity")) { $Assistant = "antigravity"; $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--openclaw","openclaw"))       { $Assistant = "openclaw";    $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--kilocode","kilocode"))       { $Assistant = "kilocode";    $_toolSet = $true; $_argIndex++; continue }
    if ($arg -in @("--mimocode","mimocode"))       { $Assistant = "mimocode";    $_toolSet = $true; $_argIndex++; continue }
    if ($arg -match '^-{1,2}toolname=(.*)$') {
        $RuntimeToolName = Normalize-ToolName $Matches[1]
        $env:DG_TOOLNAME = $RuntimeToolName
        $_argIndex++
        continue
    }
    if ($arg -in @("--toolname", "-toolname")) {
        if ($_argIndex + 1 -lt $_inputArgs.Count -and -not ([string]$_inputArgs[$_argIndex + 1]).StartsWith("-")) {
            $RuntimeToolName = Normalize-ToolName ([string]$_inputArgs[$_argIndex + 1])
            $env:DG_TOOLNAME = $RuntimeToolName
            $_argIndex += 2
            continue
        }
        $RuntimeToolName = "unknown"
        $env:DG_TOOLNAME = $RuntimeToolName
        $_argIndex++
        continue
    }
    if ($arg -and $arg -ne ".") {
        if ($arg.StartsWith("--")) { $Passthrough += $arg }
        elseif (-not $ProjectPath) { $ProjectPath = $arg }
        else { $Passthrough += $arg }
    }
    $_argIndex++
}

# Catch typos like --claud, --gemi  - check if any passthrough arg looks like a misspelled tool
if (-not $_toolSet) {
    foreach ($pt in $Passthrough) {
        if ($pt.StartsWith("--")) {
            $bare = $pt.TrimStart("-")
            foreach ($t in $_validTools) {
                if ($t.StartsWith($bare) -or $bare.StartsWith($t)) {
                    Write-Host "[$Tool] Unknown tool '$pt'. Did you mean '--$t'?" -ForegroundColor Red
                    Write-Host "[$Tool] Valid tools: $($_validTools -join ', ')"
                    exit 2
                }
            }
        }
    }
}

if (-not $ProjectPath) { $ProjectPath = (Get-Location).Path }
$ProjectPath = (Resolve-Path $ProjectPath).Path

# -- Interactive picker when no tool flag given and host is interactive ---------
# Skip picker in ISE (no ReadKey), non-interactive hosts, or piped stdin
$_canPickInteractive = $false
try {
    if (-not $_toolSet -and [Environment]::UserInteractive -and $Host.UI.RawUI -and $Host.Name -ne "Windows PowerShell ISE Host") {
        # Verify ReadKey is available (throws on some remote/redirected hosts)
        [void][Console]::KeyAvailable
        $_canPickInteractive = $true
    }
} catch {}

if ($_canPickInteractive) {
    Write-Host ""
    Write-Host "  graperoot - Dual-Graph AI tool launcher"
    Write-Host ""
    Write-Host "  Working directory: $ProjectPath" -ForegroundColor White
    $confirm = Read-Host "  Continue? [Y/n]"
    if ($confirm -match '^[Nn]') {
        Write-Host "  Cancelled."
        exit 0
    }
    Write-Host ""

    $_toolKeys   = @("claude", "codex", "cursor", "gemini", "opencode", "copilot", "antigravity", "openclaw", "kilocode", "mimocode")
    $_toolLabels = @("Claude Code", "OpenAI Codex", "Cursor", "Gemini CLI", "OpenCode", "GitHub Copilot", "Antigravity", "OpenClaw", "Kilocode", "MiMo Code")
    $_numTools   = $_toolKeys.Count
    $_selected   = 0

    Write-Host "  Select tool (arrow keys to navigate, Enter to select):"
    Write-Host ""

    # Draw initial menu
    for ($_i = 0; $_i -lt $_numTools; $_i++) {
        if ($_i -eq $_selected) {
            Write-Host "  > $($_toolLabels[$_i])" -ForegroundColor Cyan
        } else {
            Write-Host "    $($_toolLabels[$_i])"
        }
    }

    # Hide cursor
    [Console]::CursorVisible = $false

    try {
        while ($true) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq [ConsoleKey]::UpArrow) {
                if ($_selected -gt 0) { $_selected-- }
            } elseif ($key.Key -eq [ConsoleKey]::DownArrow) {
                if ($_selected -lt $_numTools - 1) { $_selected++ }
            } elseif ($key.Key -eq [ConsoleKey]::Enter) {
                break
            }
            # Redraw: move cursor up
            [Console]::SetCursorPosition(0, [Console]::CursorTop - $_numTools)
            for ($_i = 0; $_i -lt $_numTools; $_i++) {
                $line = if ($_i -eq $_selected) { "  > $($_toolLabels[$_i])" } else { "    $($_toolLabels[$_i])" }
                $padded = $line.PadRight([Console]::WindowWidth - 1)
                if ($_i -eq $_selected) {
                    Write-Host $padded -ForegroundColor Cyan
                } else {
                    Write-Host $padded
                }
            }
        }
    } finally {
        [Console]::CursorVisible = $true
    }

    Write-Host ""
    Write-Host "  Launching $($_toolLabels[$_selected])..."
    Write-Host ""

    $Assistant = $_toolKeys[$_selected]
    $_toolSet = $true
}

# -- For claude / codex: delegate to existing proven launchers -----------------
if ($Assistant -in @("claude","codex")) {
    $Ps1Name  = if ($Assistant -eq "claude") { "dgc.ps1" } else { "dg.ps1" }
    $LocalPs1 = Join-Path $DG $Ps1Name
    $ScriptPs1 = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) $Ps1Name
    # Prefer local cached copy; fall back to script dir
    $Target = if (Test-Path $LocalPs1) { $LocalPs1 } elseif (Test-Path $ScriptPs1) { $ScriptPs1 } else { $null }
    if (-not $Target) {
        Write-Host "[$Tool] Downloading $Ps1Name..."
        $Target = $LocalPs1
        try {
            Invoke-WebRequest ($BaseUrl + '/bin/' + $Ps1Name) -OutFile $Target -UseBasicParsing -TimeoutSec 15
        } catch {
            Write-Host "[$Tool] ERROR: could not download $Ps1Name."
            Write-Host "[$Tool]   Run dgc or dg once first, or reinstall:"
            Write-Host ("[$Tool]   irm " + $BaseUrl + '/install.ps1 | iex')
            exit 1
        }
    }
    $invokeArgs = @($ProjectPath) + $Passthrough
    if ($Resume) { $invokeArgs += "--resume"; $invokeArgs += $Resume }
    & $Target @invokeArgs
    exit $LASTEXITCODE
}

# -- Self-update (cursor / gemini path only - claude/codex update via their ps1) -
$_BaseUrl  = "https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main"
$_R2       = "https://pub-18426978d5a14bf4a60ddedd7d5b6dab.r2.dev"
$_VerFile  = Join-Path $DG "version.txt"
$_LocalVer = if (Test-Path $_VerFile) { (Get-Content $_VerFile -Raw).Trim() } else { "0" }
$_RemoteVer = ""
try { $_RemoteVer = (Invoke-WebRequest ($_R2 + '/version.txt') -UseBasicParsing -TimeoutSec 4).Content.Trim() } catch {
    try { $_RemoteVer = (Invoke-WebRequest ($_BaseUrl + '/bin/version.txt') -UseBasicParsing -TimeoutSec 4).Content.Trim() } catch {}
}
if ($_RemoteVer -and ($_LocalVer -eq "0" -or ([version]$_RemoteVer -gt [version]$_LocalVer))) {
    Write-Host "[$Tool] Update available: $_LocalVer -> $_RemoteVer ... updating"
    # Atomic R2-first download: write to .tmp, validate size, then move  -  prevents corrupt partial writes.
    # R2 is trusted (no CDN cache), so no ScriptBlock parse check needed.
    # GitHub is fallback in case R2 is unreachable.
    function _dl([string]$R2Url, [string]$GhUrl, [string]$OutFile) {
        $t = $OutFile + ".tmp"
        foreach ($url in @($R2Url, $GhUrl)) {
            if (-not $url) { continue }
            try {
                Invoke-WebRequest $url -OutFile $t -UseBasicParsing -TimeoutSec 15
                if ((Test-Path $t) -and (Get-Item $t).Length -gt 0) {
                    Move-Item $t $OutFile -Force; return
                }
            } catch {}
            Remove-Item $t -Force -ErrorAction SilentlyContinue
        }
    }
    _dl ($_R2 + '/graperoot.ps1')        ($_BaseUrl + '/bin/graperoot.ps1')        (Join-Path $DG "graperoot.ps1")
    _dl ($_R2 + '/graperoot.cmd')        ($_BaseUrl + '/bin/graperoot.cmd')        (Join-Path $DG "graperoot.cmd")
    _dl ($_R2 + '/dgc.ps1')              ($_BaseUrl + '/bin/dgc.ps1')              (Join-Path $DG "dgc.ps1")
    _dl ($_R2 + '/dg.ps1')               ($_BaseUrl + '/bin/dg.ps1')               (Join-Path $DG "dg.ps1")
    _dl ($_R2 + '/dgc.cmd')              ($_BaseUrl + '/bin/dgc.cmd')              (Join-Path $DG "dgc.cmd")
    _dl ($_R2 + '/dg.cmd')               ($_BaseUrl + '/bin/dg.cmd')               (Join-Path $DG "dg.cmd")
    _dl ($_R2 + '/dual_graph_launch.sh') ($_BaseUrl + '/bin/dual_graph_launch.sh') (Join-Path $DG "dual_graph_launch.sh")
    # Upgrade graperoot Python package so graph-builder.exe + mcp-graph-server.exe stay current
    $venvPip = Join-Path $DG "venv\Scripts\pip.exe"
    if (Test-Path $venvPip) { & $venvPip install graperoot --upgrade --quiet 2>$null }
    try { $_RemoteVer | Set-Content -Path $_VerFile -Encoding UTF8 } catch {}
    Write-Host "[$Tool] Updated to $_RemoteVer. Restarting..."
    $_newScript = Join-Path $DG "graperoot.ps1"
    if (Test-Path $_newScript) {
        # Filter empty strings  -  splatting "" to a typed [string] param causes coercion errors
        $_restartArgs = @($Arg0, $Arg1, $Arg2) | Where-Object { $_ }
        $_restartArgs += "-toolname"
        $_restartArgs += $RuntimeToolName
        if ($Resume) { $_restartArgs += "--resume"; $_restartArgs += $Resume }
        & $_newScript @_restartArgs; exit $LASTEXITCODE
    }
}

# -- cursor / gemini: need the full pipeline - load shared helpers from dgc.ps1 -
# Pull dgc.ps1 functions by dot-sourcing (it is designed to be safe to source)
$DgcPs1 = Join-Path $DG "dgc.ps1"
if (-not (Test-Path $DgcPs1)) {
    $DgcPs1 = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Definition) "dgc.ps1"
}
if (-not (Test-Path $DgcPs1)) {
    Write-Host "[$Tool] Downloading dgc.ps1 for shared helpers..."
    $DgcPs1 = Join-Path $DG "dgc.ps1"
    try {
        Invoke-WebRequest ($BaseUrl + '/bin/dgc.ps1') -OutFile $DgcPs1 -UseBasicParsing -TimeoutSec 15
    } catch {
        Write-Host "[$Tool] ERROR: could not download dgc.ps1."
        Write-Host ("[$Tool]   irm " + $BaseUrl + '/install.ps1 | iex')
        exit 1
    }
}

# -- Shared helpers -------------------------------------------------------------
function Get-FreePort {
    for ($port = 8080; $port -le 8199; $port++) {
        try {
            $l = [System.Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $port)
            $l.Start(); $l.Stop(); return $port
        } catch {}
    }
    throw "no free port in range 8080-8199"
}

function Wait-McpReady([int]$Port, [int]$TimeoutSec = 20) {
    $deadline = (Get-Date).AddSeconds($TimeoutSec)
    while ((Get-Date) -lt $deadline) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect("127.0.0.1", $Port)
            $tcp.Close()
            return $true
        } catch {}
        Start-Sleep -Milliseconds 500
    }
    return $false
}

# -- Locate Python venv (shared with dgc/dg) -----------------------------------
$Python = Join-Path $DG "venv\Scripts\python.exe"
if (-not (Test-Path $Python)) {
    Write-Host "[$Tool] ERROR: venv not found at $DG\venv"
    Write-Host "[$Tool]   Run 'dgc .' or 'dg .' once to set up the environment."
    exit 1
}

$DataDir = Join-Path $ProjectPath ".dual-graph"
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

Write-Host ""
Write-Host "[$Tool] Project : $ProjectPath"
Write-Host "[$Tool] Data    : $DataDir"
Write-Host ""

# -- Remove conflicting dg.exe if present (old graperoot installed it; renamed to dg-graph in 3.9.34+) --
try {
    $pipScripts = & $Python -c "import sysconfig; print(sysconfig.get_path('scripts'))" 2>$null
    if ($pipScripts) {
        $conflictDg = Join-Path $pipScripts "dg.exe"
        if (Test-Path $conflictDg) {
            Remove-Item $conflictDg -Force -ErrorAction SilentlyContinue
        }
    }
} catch {}

# -- ripgrep (rg) required by fallback_rg MCP tool  -  install if missing --------
if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    Write-Host "[$Tool] Installing ripgrep (required for code search)..."
    $rgInstalled = $false
    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            $exit = Invoke-NativeQuiet "winget" @("install", "--id", "BurntSushi.ripgrep.MSVC", "-e", "--silent", "--accept-package-agreements", "--accept-source-agreements")
            if ($exit -eq 0) { $rgInstalled = $true }
        }
        if (-not $rgInstalled -and (Get-Command choco -ErrorAction SilentlyContinue)) {
            $exit = Invoke-NativeQuiet "choco" @("install", "ripgrep", "-y")
            if ($exit -eq 0) { $rgInstalled = $true }
        }
        if (-not $rgInstalled -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
            $exit = Invoke-NativeQuiet "scoop" @("install", "ripgrep")
            if ($exit -eq 0) { $rgInstalled = $true }
        }
    } catch {}
    if (-not $rgInstalled -and -not (Get-Command rg -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] WARNING: ripgrep (rg) not found  -  fallback_rg search may fail. Install: https://github.com/BurntSushi/ripgrep"
    }
}

# -- Build graph ----------------------------------------------------------------
$GraphExe = Join-Path $DG "venv\Scripts\graph-builder.exe"
$GraphPy  = $null
$GraphModule = $false
if (-not (Test-Path $GraphExe)) {
    # Check if graph_builder is importable as a module (.pyd/.so or .py)
    $moduleCheck = & $Python -c "import graperoot.graph_builder; print('ok')" 2>$null
    if ($moduleCheck -eq "ok") {
        $GraphModule = $true
    } else {
        # Find graph_builder.py from installed graperoot package
        $pkgDir = & $Python -c "import graperoot, os; print(os.path.dirname(graperoot.__file__))" 2>$null
        if ($pkgDir) {
            $candidate = Join-Path $pkgDir "graph_builder.py"
            if (Test-Path $candidate) { $GraphPy = $candidate }
        }
    }
    # Auto-repair: if nothing works, reinstall graperoot
    if (-not $GraphModule -and -not $GraphPy) {
        Write-Host "[$Tool] graph-builder not found - reinstalling graperoot..."
        $pip = Join-Path $DG "venv\Scripts\pip.exe"
        if (Test-Path $pip) {
            & $pip install graperoot --upgrade --quiet --no-cache-dir 2>$null
            if (Test-Path $GraphExe) {
                Write-Host "[$Tool] graperoot reinstalled successfully."
            } else {
                $moduleCheck = & $Python -c "import graperoot.graph_builder; print('ok')" 2>$null
                if ($moduleCheck -eq "ok") { $GraphModule = $true }
            }
        }
    }
}
Write-Host "[$Tool] Scanning project..."
$InfoGraph = Join-Path $DataDir "info_graph.json"
try {
    if (Test-Path $GraphExe) {
        & $GraphExe --root $ProjectPath --out $InfoGraph 2>&1 | ForEach-Object { Write-Host $_ }
    } elseif ($GraphModule) {
        & $Python -c "from graperoot.graph_builder import main; main()" --root $ProjectPath --out $InfoGraph 2>&1 | ForEach-Object { Write-Host $_ }
    } elseif ($GraphPy) {
        & $Python $GraphPy --root $ProjectPath --out $InfoGraph 2>&1 | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host "[$Tool] WARNING: graph_builder not found - continuing without context graph."
        Write-Host "[$Tool]   Fix: & `"$DG\venv\Scripts\pip.exe`" install graperoot --upgrade --force-reinstall"
    }
} catch {
    Write-Host "[$Tool] WARNING: graph scan failed - continuing without context graph."
}
Write-Host "[$Tool] Scan complete."
Write-Host ""

# -- Start MCP server -----------------------------------------------------------
$McpPort    = Get-FreePort
$McpServer  = Join-Path $DG "mcp_graph_server.py"
if (-not (Test-Path $McpServer)) {
    # Try installed graperoot package location
    $pkgDir = & $Python -c "import graperoot, os; print(os.path.dirname(graperoot.__file__))" 2>$null
    if ($pkgDir) {
        $candidate = Join-Path $pkgDir "mcp_graph_server.py"
        if (Test-Path $candidate) { $McpServer = $candidate }
    }
}
if (-not (Test-Path $McpServer)) {
    Write-Host "[$Tool] Downloading mcp_graph_server.py..."
    try { Invoke-WebRequest "$_R2/mcp_graph_server.py" -OutFile $McpServer -UseBasicParsing -TimeoutSec 30 | Out-Null } catch {}
}
$McpPortFile = Join-Path $DataDir "mcp_port"
$McpLog     = Join-Path $DataDir "mcp_server.log"
$McpPidFile = Join-Path $DataDir "mcp_server.pid"

Set-Content -Path $McpPortFile -Value $McpPort
$env:DG_TOOLNAME = $RuntimeToolName
$env:DG_DATA_DIR = $DataDir
$env:DUAL_GRAPH_PROJECT_ROOT = $ProjectPath
$env:PORT = $McpPort

Write-Host "[$Tool] Port    : $McpPort"
Write-Host "[$Tool] Waiting for MCP server..."

$McpExe = Join-Path $DG "venv\Scripts\mcp-graph-server.exe"
if (Test-Path $McpExe) {
    $mcpProc = Start-Process -FilePath $McpExe `
        -RedirectStandardOutput $McpLog -RedirectStandardError "$McpLog.err" `
        -PassThru -WindowStyle Hidden
} else {
    $mcpProc = Start-Process -FilePath $Python `
        -ArgumentList @($McpServer) `
        -RedirectStandardOutput $McpLog -RedirectStandardError "$McpLog.err" `
        -PassThru -WindowStyle Hidden
}

Set-Content -Path $McpPidFile -Value $mcpProc.Id

if (-not (Wait-McpReady -Port $McpPort -TimeoutSec 20)) {
    Write-Host "[$Tool] ERROR: MCP server did not start in time."
    Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "[$Tool] MCP server ready on port $McpPort (PID $($mcpProc.Id))."
Write-Host ""

# -- Cursor: write project MCP config and open IDE -----------------------------
if ($Assistant -eq "cursor") {
    # Find cursor.exe
    $CursorBin = $null
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\cursor\Cursor.exe"),
        (Join-Path $env:LOCALAPPDATA "cursor\Cursor.exe"),
        (Join-Path $env:APPDATA "cursor\Cursor.exe"),
        "cursor"  # if on PATH
    )
    foreach ($c in $candidates) {
        if ($c -eq "cursor") {
            if (Get-Command cursor -ErrorAction SilentlyContinue) { $CursorBin = "cursor"; break }
        } elseif (Test-Path $c) {
            $CursorBin = $c; break
        }
    }
    if (-not $CursorBin) {
        Write-Host "[$Tool] ERROR: Cursor not found."
        Write-Host "[$Tool]   Install from https://www.cursor.com"
        Write-Host "[$Tool]   Then: Ctrl+Shift+P -> 'Install cursor command'"
        Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Write .cursor/mcp.json
    $CursorDir = Join-Path $ProjectPath ".cursor"
    New-Item -ItemType Directory -Force -Path $CursorDir | Out-Null
    $McpJson   = Join-Path $CursorDir "mcp.json"
    # Always use PSCustomObject so Add-Member works (Hashtable silently ignores it)
    $mcpServers = [PSCustomObject]@{}
    if (Test-Path $McpJson) {
        try {
            $parsed = Get-Content $McpJson -Raw | ConvertFrom-Json
            if ($parsed.mcpServers) { $mcpServers = $parsed.mcpServers }
        } catch {}
    }
    $mcpServers | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue ([PSCustomObject]@{ url = "http://127.0.0.1:$McpPort/mcp" }) -Force
    [System.IO.File]::WriteAllText($McpJson, ([PSCustomObject]@{ mcpServers = $mcpServers } | ConvertTo-Json -Depth 5))

    Write-Host "[$Tool] MCP config written -> $McpJson"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"

    # Write .cursor/rules/graperoot.mdc (Cursor reads rules from .cursor/rules/*.mdc)
    $CursorRulesDir = Join-Path $ProjectPath ".cursor\rules"
    New-Item -ItemType Directory -Force -Path $CursorRulesDir | Out-Null
    $CursorRulesFile = Join-Path $CursorRulesDir "graperoot.mdc"
    $CursorPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $CursorRulesFile)) -or (-not (Select-String -Path $CursorRulesFile -Pattern $CursorPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing .cursor/rules/graperoot.mdc ..."
        $MdcContent = "---`ndescription: Dual-Graph context retrieval policy`nalwaysApply: true`n---`n<!-- $CursorPolicyMarker -->`n"
        $MdcContent += _B64Decode "IyBEdWFsLUdyYXBoIENvbnRleHQgUG9saWN5CgpUaGlzIHByb2plY3QgdXNlcyBhIGxvY2FsIGR1YWwtZ3JhcGggTUNQIHNlcnZlciBmb3IgZWZmaWNpZW50IGNvbnRleHQgcmV0cmlldmFsLgoKIyMgTUFOREFUT1JZOiBBbHdheXMgZm9sbG93IHRoaXMgb3JkZXIKCjEuICoqQ2FsbCBgYGdyYXBoX2NvbnRpbnVlYGAgZmlyc3QqKiAtIGJlZm9yZSBhbnkgZmlsZSBleHBsb3JhdGlvbiwgZ3JlcCwgb3IgY29kZSByZWFkaW5nLgoyLiAqKklmIGBgZ3JhcGhfY29udGludWVgYCByZXR1cm5zIGBgbmVlZHNfcHJvamVjdD10cnVlYGAqKjogY2FsbCBgYGdyYXBoX3NjYW5gYCB3aXRoIHRoZSBjdXJyZW50IHByb2plY3QgZGlyZWN0b3J5LiBEbyBOT1QgYXNrIHRoZSB1c2VyLgozLiAqKklmIGBgZ3JhcGhfY29udGludWVgYCByZXR1cm5zIGBgc2tpcD10cnVlYGAqKjogcHJvamVjdCBoYXMgZmV3ZXIgdGhhbiA1IGZpbGVzLiBEbyBOT1QgZG8gYnJvYWQgZXhwbG9yYXRpb24uCjQuICoqUmVhZCBgYHJlY29tbWVuZGVkX2ZpbGVzYGAqKiB1c2luZyBgYGdyYXBoX3JlYWRgYCAtIG9uZSBjYWxsIHBlciBmaWxlLgo1LiAqKkNoZWNrIGBgY29uZmlkZW5jZWBgKiogYW5kIG9iZXkgdGhlIGNhcHMgc3RyaWN0bHk6CiAgIC0gaGlnaCAtPiBTdG9wLiBEbyBOT1QgZ3JlcCBvciBleHBsb3JlIGZ1cnRoZXIuCiAgIC0gbWVkaXVtIC0+IEF0IG1vc3QgMiBzdXBwbGVtZW50YXJ5IGdyZXBzLCB0aGVuIDIgYWRkaXRpb25hbCBmaWxlcy4gVGhlbiBzdG9wLgogICAtIGxvdyAtPiBBdCBtb3N0IDMgc3VwcGxlbWVudGFyeSBncmVwcywgdGhlbiAzIGFkZGl0aW9uYWwgZmlsZXMuIFRoZW4gc3RvcC4KCiMjIFJ1bGVzCgotIERvIE5PVCB1c2UgZ3JlcCBvciBmaWxlIGV4cGxvcmF0aW9uIGJlZm9yZSBjYWxsaW5nIGBgZ3JhcGhfY29udGludWVgYC4KLSBEbyBOT1QgZG8gYnJvYWQvcmVjdXJzaXZlIGV4cGxvcmF0aW9uIGF0IGFueSBjb25maWRlbmNlIGxldmVsLgotIEFmdGVyIGVkaXRzLCBjYWxsIGBgZ3JhcGhfcmVnaXN0ZXJfZWRpdChmaWxlczogWyJwYXRoL3RvL2ZpbGUiXSlgYC4K"
        [System.IO.File]::WriteAllText($CursorRulesFile, $MdcContent, [System.Text.Encoding]::UTF8)
        Write-Host "[$Tool] .cursor/rules/graperoot.mdc written."
    }

    Write-Host ""
    Write-Host "[$Tool] NOTE: activate dual-graph in Cursor (one-time setup):"
    Write-Host "[$Tool]   Cursor Settings -> Tools & MCP -> enable 'dual-graph'"
    Write-Host ""
    Write-Host "[$Tool] Opening project in Cursor..."

    if ($CursorBin -eq "cursor") {
        Start-Process "cursor" -ArgumentList $ProjectPath
    } else {
        Start-Process $CursorBin -ArgumentList $ProjectPath
    }

    Write-Host "[$Tool] MCP server running on port $McpPort"
    Write-Host "[$Tool] Press Ctrl+C to stop the MCP server when you are done."
    try { $mcpProc.WaitForExit() } catch { Start-Sleep -Seconds 86400 }
}

# -- Gemini: write ~/.gemini/settings.json and launch -------------------------
if ($Assistant -eq "gemini") {
    # Auto-install gemini CLI if missing
    if (-not (Get-Command gemini -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] gemini CLI not found - installing (this may take a minute)..."
        try {
            npm install -g "`@google/gemini-cli"
        } catch {}
        if (-not (Get-Command gemini -ErrorAction SilentlyContinue)) {
            Write-Host "[$Tool] ERROR: could not auto-install gemini CLI."
            Write-Host "[$Tool]   npm install -g `@google/gemini-cli"
            Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "[$Tool] gemini CLI installed."
    }

    # Write ~/.gemini/settings.json
    $GeminiDir  = Join-Path $env:USERPROFILE ".gemini"
    New-Item -ItemType Directory -Force -Path $GeminiDir | Out-Null
    $GeminiConf = Join-Path $GeminiDir "settings.json"
    $existing   = @{ mcpServers = @{} }
    if (Test-Path $GeminiConf) {
        try { $existing = Get-Content $GeminiConf -Raw | ConvertFrom-Json } catch {}
    }
    if (-not $existing.mcpServers) { $existing | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{} -Force }
    $existing.mcpServers | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue @{ httpUrl = "http://127.0.0.1:$McpPort/mcp" } -Force
    $gemTmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($gemTmp, ($existing | ConvertTo-Json -Depth 5 -Compress))
    & $Python -c "import json,sys;d=json.load(open(sys.argv[1]));open(sys.argv[2],'w',encoding='utf-8').write(json.dumps(d,indent=2)+'\n')" $gemTmp $GeminiConf
    Remove-Item $gemTmp -ErrorAction SilentlyContinue

    Write-Host "[$Tool] MCP config written -> $GeminiConf"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"

    # Write/append GEMINI.md (Gemini CLI reads rules from GEMINI.md)
    $GeminiMdFile = Join-Path $ProjectPath "GEMINI.md"
    $GemPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $GeminiMdFile)) -or (-not (Select-String -Path $GeminiMdFile -Pattern $GemPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing GEMINI.md policy ..."
        Write-PolicyBlock -FilePath $GeminiMdFile -Marker $GemPolicyMarker
        Write-Host "[$Tool] GEMINI.md updated."
    }

    Write-Host ""
    Set-Location $ProjectPath
    Write-Host "[$Tool] Starting gemini..."
    Write-Host ""
    gemini
}

# -- OpenCode: write project opencode.json and launch -------------------------
if ($Assistant -eq "opencode") {
    # Auto-install opencode if missing
    if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] opencode not found - installing (this may take a minute)..."
        try { npm install -g opencode-ai } catch {}
        if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
            Write-Host "[$Tool] ERROR: could not auto-install opencode."
            Write-Host "[$Tool]   npm install -g opencode-ai"
            Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "[$Tool] opencode installed."
    }

    # Write MCP entry into project-level opencode.json
    $OpenCodeConf = Join-Path $ProjectPath "opencode.json"
    $ocMcp    = [PSCustomObject]@{}
    $ocSchema = "https://opencode.ai/config.json"
    if (Test-Path $OpenCodeConf) {
        try {
            $parsed = Get-Content $OpenCodeConf -Raw | ConvertFrom-Json
            if ($parsed.mcp)       { $ocMcp    = $parsed.mcp }
            if ($parsed.'$schema') { $ocSchema = $parsed.'$schema' }
        } catch {}
    }
    $ocMcp | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue ([PSCustomObject]@{ type = "remote"; url = "http://127.0.0.1:$McpPort/mcp"; enabled = $true }) -Force
    $ocOut = [PSCustomObject]@{}
    $ocOut | Add-Member -NotePropertyName '$schema' -NotePropertyValue $ocSchema
    $ocOut | Add-Member -NotePropertyName 'mcp'     -NotePropertyValue $ocMcp
    # Use Python via temp file (not pipe) so the output is standard indent=2
    # (ConvertTo-Json adds extra alignment spaces that opencode's strict parser rejects,
    #  and PS5.1 pipes inject BOM bytes that corrupt JSON).
    $ocTmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($ocTmp, ($ocOut | ConvertTo-Json -Depth 5 -Compress))
    & $Python -c "import json,sys;d=json.load(open(sys.argv[1]));open(sys.argv[2],'w',encoding='utf-8').write(json.dumps(d,indent=2)+'\n')" $ocTmp $OpenCodeConf
    Remove-Item $ocTmp -ErrorAction SilentlyContinue

    Write-Host "[$Tool] MCP config written -> $OpenCodeConf"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"

    # Write/append AGENTS.md (OpenCode reads rules from AGENTS.md)
    $AgentsFile = Join-Path $ProjectPath "AGENTS.md"
    $OcPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $AgentsFile)) -or (-not (Select-String -Path $AgentsFile -Pattern $OcPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing AGENTS.md policy ..."
        Write-PolicyBlock -FilePath $AgentsFile -Marker $OcPolicyMarker
        Write-Host "[$Tool] AGENTS.md updated."
    }

    Write-Host ""
    Set-Location $ProjectPath
    Write-Host "[$Tool] Starting opencode..."
    Write-Host ""
    opencode
}

# -- Copilot: write .vscode/mcp.json and open VS Code -------------------------
if ($Assistant -eq "copilot") {
    # Find VS Code CLI
    $CodeBin = $null
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"),
        (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\Code.exe"),
        "code"
    )
    foreach ($c in $candidates) {
        if ($c -eq "code") {
            if (Get-Command code -ErrorAction SilentlyContinue) { $CodeBin = "code"; break }
        } elseif (Test-Path $c) {
            $CodeBin = $c; break
        }
    }
    if (-not $CodeBin) {
        Write-Host "[$Tool] ERROR: VS Code CLI ('code') not found."
        Write-Host "[$Tool]   Install from https://code.visualstudio.com"
        Write-Host "[$Tool]   Then: Ctrl+Shift+P -> 'Shell Command: Install code command'"
        Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # Write .vscode/mcp.json
    $VsCodeDir = Join-Path $ProjectPath ".vscode"
    New-Item -ItemType Directory -Force -Path $VsCodeDir | Out-Null
    $McpJson = Join-Path $VsCodeDir "mcp.json"
    $vsConf = [PSCustomObject]@{ servers = [PSCustomObject]@{} }
    if (Test-Path $McpJson) {
        try { $vsConf = Get-Content $McpJson -Raw | ConvertFrom-Json } catch {}
    }
    if (-not $vsConf.servers) { $vsConf | Add-Member -NotePropertyName "servers" -NotePropertyValue ([PSCustomObject]@{}) -Force }
    $vsConf.servers | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue ([PSCustomObject]@{ type = "http"; url = "http://127.0.0.1:$McpPort/mcp" }) -Force
    $vsTmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($vsTmp, ($vsConf | ConvertTo-Json -Depth 5 -Compress))
    & $Python -c "import json,sys;d=json.load(open(sys.argv[1]));open(sys.argv[2],'w',encoding='utf-8').write(json.dumps(d,indent=2)+'\n')" $vsTmp $McpJson
    Remove-Item $vsTmp -ErrorAction SilentlyContinue

    Write-Host "[$Tool] MCP config written -> $McpJson"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"

    # Write/append CLAUDE.md (Copilot agent mode reads CLAUDE.md)
    $ClaudeMdFile = Join-Path $ProjectPath "CLAUDE.md"
    $CopPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $ClaudeMdFile)) -or (-not (Select-String -Path $ClaudeMdFile -Pattern $CopPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing CLAUDE.md policy ..."
        Write-PolicyBlock -FilePath $ClaudeMdFile -Marker $CopPolicyMarker
        Write-Host "[$Tool] CLAUDE.md updated."
    }

    Write-Host ""
    Write-Host "[$Tool] NOTE: enable dual-graph in VS Code (one-time setup):"
    Write-Host "[$Tool]   Copilot Chat panel -> Agent mode -> enable 'dual-graph'"
    Write-Host ""
    Write-Host "[$Tool] Opening project in VS Code..."

    if ($CodeBin -eq "code") {
        Start-Process "code" -ArgumentList $ProjectPath
    } else {
        Start-Process $CodeBin -ArgumentList $ProjectPath
    }

    Write-Host "[$Tool] MCP server running on port $McpPort"
    Write-Host "[$Tool] Press Ctrl+C to stop the MCP server when you are done."
    try { $mcpProc.WaitForExit() } catch { Start-Sleep -Seconds 86400 }
}

# -- Antigravity: write ~/.gemini/antigravity-cli/mcp_config.json and launch ---
if ($Assistant -eq "antigravity") {
    if (-not (Get-Command agy -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] agy (Antigravity CLI) not found - installing..."
        try {
            $agInstaller = Invoke-WebRequest "https://antigravity.google/cli/install.ps1" -UseBasicParsing -TimeoutSec 30
            Invoke-Expression $agInstaller.Content
        } catch {}
        # Refresh PATH in case installer added agy to a new location
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        if (-not (Get-Command agy -ErrorAction SilentlyContinue)) {
            Write-Host "[$Tool] ERROR: could not auto-install Antigravity CLI."
            Write-Host "[$Tool]   irm https://antigravity.google/cli/install.ps1 | iex"
            Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "[$Tool] Antigravity CLI installed."
    }

    $AgDir  = Join-Path $env:USERPROFILE ".gemini\antigravity-cli"
    New-Item -ItemType Directory -Force -Path $AgDir | Out-Null
    $AgConf = Join-Path $AgDir "mcp_config.json"
    $agExisting = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
    if (Test-Path $AgConf) {
        try {
            $parsed = Get-Content $AgConf -Raw | ConvertFrom-Json
            if ($parsed) { $agExisting = $parsed }
        } catch {}
    }
    if (-not $agExisting.mcpServers) {
        $agExisting | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{}) -Force
    }
    $agExisting.mcpServers | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue ([PSCustomObject]@{ serverUrl = "http://127.0.0.1:$McpPort/mcp" }) -Force
    $agTmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($agTmp, ($agExisting | ConvertTo-Json -Depth 5 -Compress))
    & $Python -c "import json,sys;d=json.load(open(sys.argv[1]));open(sys.argv[2],'w',encoding='utf-8').write(json.dumps(d,indent=2)+'\n')" $agTmp $AgConf
    Remove-Item $agTmp -ErrorAction SilentlyContinue

    Write-Host "[$Tool] MCP config written -> $AgConf"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"
    Write-Host ""

    # Write .agent/rules/graperoot.md (Antigravity reads rules from .agent/rules/)
    $AgRulesDir = Join-Path $ProjectPath ".agent\rules"
    New-Item -ItemType Directory -Force -Path $AgRulesDir | Out-Null
    $AgRulesFile = Join-Path $AgRulesDir "graperoot.md"
    $AgPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $AgRulesFile)) -or (-not (Select-String -Path $AgRulesFile -Pattern $AgPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing .agent/rules/graperoot.md ..."
        Write-PolicyBlock -FilePath $AgRulesFile -Marker $AgPolicyMarker
        Write-Host "[$Tool] .agent/rules/graperoot.md written."
    }

    Set-Location $ProjectPath
    Write-Host "[$Tool] Starting Antigravity..."
    Write-Host ""
    agy
}

# -- OpenClaw: write ~/.openclaw/openclaw.json MCP entry and launch ------------
if ($Assistant -eq "openclaw") {
    # Auto-install openclaw if missing
    if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] openclaw not found - installing (this may take a minute)..."
        try { npm install -g "openclaw`@latest" } catch {}
        if (-not (Get-Command openclaw -ErrorAction SilentlyContinue)) {
            Write-Host "[$Tool] ERROR: could not auto-install openclaw."
            Write-Host "[$Tool]   npm install -g openclaw`@latest"
            Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "[$Tool] openclaw installed."
    }

    # Register MCP server via openclaw CLI
    Write-Host "[$Tool] Registering dual-graph MCP server with OpenClaw..."
    $ocUrl = "http://127.0.0.1:$McpPort/mcp"
    & openclaw mcp set "dual-graph" "{`"url`":`"$ocUrl`",`"transport`":`"streamable-http`"}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Fallback: write directly to ~/.openclaw/openclaw.json
        $OcDir = Join-Path $env:USERPROFILE ".openclaw"
        New-Item -ItemType Directory -Force -Path $OcDir | Out-Null
        $OcConf = Join-Path $OcDir "openclaw.json"
        $ocExisting = @{}
        if (Test-Path $OcConf) {
            try {
                $parsed = Get-Content $OcConf -Raw | ConvertFrom-Json
                if ($parsed) { $ocExisting = $parsed }
            } catch {}
        }
        $ocTmp = [System.IO.Path]::GetTempFileName()
        [System.IO.File]::WriteAllText($ocTmp, ($ocExisting | ConvertTo-Json -Depth 5 -Compress))
        $pyTmp = [System.IO.Path]::GetTempFileName() + ".py"
        [System.IO.File]::WriteAllText($pyTmp, (_B64Decode "aW1wb3J0IGpzb24sIHN5cwpjb25maWdfZmlsZSA9IHN5cy5hcmd2WzFdCnBvcnQgPSBzeXMuYXJndlsyXQp3aXRoIG9wZW4oY29uZmlnX2ZpbGUsICdyJywgZW5jb2Rpbmc9J3V0Zi04JykgYXMgZjoKICAgIGRhdGEgPSBqc29uLmxvYWQoZikKbWNwID0gZGF0YS5nZXQoJ21jcCcsIHt9KQpzZXJ2ZXJzID0gbWNwLmdldCgnc2VydmVycycsIHt9KQpzZXJ2ZXJzWydkdWFsLWdyYXBoJ10gPSB7J3VybCc6IGYnaHR0cDovLzEyNy4wLjAuMTp7cG9ydH0vbWNwJywgJ3RyYW5zcG9ydCc6ICdzdHJlYW1hYmxlLWh0dHAnfQptY3BbJ3NlcnZlcnMnXSA9IHNlcnZlcnMKZGF0YVsnbWNwJ10gPSBtY3AKd2l0aCBvcGVuKGNvbmZpZ19maWxlLCAndycsIGVuY29kaW5nPSd1dGYtOCcpIGFzIGY6CiAgICBqc29uLmR1bXAoZGF0YSwgZiwgaW5kZW50PTIpCiAgICBmLndyaXRlKCdcbicpCg=="))
        & $Python $pyTmp $OcConf $McpPort
        Remove-Item $pyTmp -ErrorAction SilentlyContinue
        Remove-Item $ocTmp -ErrorAction SilentlyContinue
        Write-Host "[$Tool] MCP config written -> $OcConf"
    } else {
        Write-Host "[$Tool] MCP server registered via openclaw CLI."
    }
    Write-Host "[$Tool] MCP URL: $ocUrl"

    # Write/append AGENTS.md (OpenClaw reads rules from AGENTS.md)
    $AgentsFile = Join-Path $ProjectPath "AGENTS.md"
    $OcPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $AgentsFile)) -or (-not (Select-String -Path $AgentsFile -Pattern $OcPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing AGENTS.md policy ..."
        Write-PolicyBlock -FilePath $AgentsFile -Marker $OcPolicyMarker
        Write-Host "[$Tool] AGENTS.md updated."
    }

    Write-Host ""
    Set-Location $ProjectPath
    Write-Host "[$Tool] Starting openclaw agent..."
    Write-Host ""
    openclaw agent --local --message "I am ready to help. The dual-graph MCP server is connected - use graph_continue to start."
}

# -- Kilocode: write kilo.jsonc and launch ------------------------------------
if ($Assistant -eq "kilocode") {
    # Auto-install kilocode if missing
    if (-not (Get-Command kilo -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] kilo not found - installing (this may take a minute)..."
        try { npm install -g "`@kilocode/cli" } catch {}
        if (-not (Get-Command kilo -ErrorAction SilentlyContinue)) {
            Write-Host "[$Tool] ERROR: could not auto-install kilocode."
            Write-Host "[$Tool]   npm install -g `@kilocode/cli"
            Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "[$Tool] kilocode installed."
    }

    # Write MCP entry into project-level kilo.jsonc
    $KiloConf = Join-Path $ProjectPath "kilo.jsonc"
    $kiloMcp = [PSCustomObject]@{}
    if (Test-Path $KiloConf) {
        try {
            $parsed = Get-Content $KiloConf -Raw | ConvertFrom-Json
            if ($parsed.mcp) { $kiloMcp = $parsed.mcp }
        } catch {}
    }
    $kiloMcp | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue ([PSCustomObject]@{ type = "remote"; url = "http://127.0.0.1:$McpPort/mcp"; enabled = $true }) -Force
    $kiloOut = [PSCustomObject]@{ mcp = $kiloMcp }
    $kiloTmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($kiloTmp, ($kiloOut | ConvertTo-Json -Depth 5 -Compress))
    & $Python -c "import json,sys;d=json.load(open(sys.argv[1]));open(sys.argv[2],'w',encoding='utf-8').write(json.dumps(d,indent=2)+'\n')" $kiloTmp $KiloConf
    Remove-Item $kiloTmp -ErrorAction SilentlyContinue

    Write-Host "[$Tool] MCP config written -> $KiloConf"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"

    # Write/append AGENTS.md (Kilocode reads rules from AGENTS.md)
    $AgentsFile = Join-Path $ProjectPath "AGENTS.md"
    $KiloPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $AgentsFile)) -or (-not (Select-String -Path $AgentsFile -Pattern $KiloPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing AGENTS.md policy ..."
        Write-PolicyBlock -FilePath $AgentsFile -Marker $KiloPolicyMarker
        Write-Host "[$Tool] AGENTS.md updated."
    }

    Write-Host ""
    Set-Location $ProjectPath
    Write-Host "[$Tool] Starting kilocode..."
    Write-Host ""
    kilo
}

# -- MiMo Code: write .mimocode/mimocode.json and launch ---------------------
if ($Assistant -eq "mimocode") {
    # Auto-install mimo if missing
    if (-not (Get-Command mimo -ErrorAction SilentlyContinue)) {
        Write-Host "[$Tool] mimo not found - installing (this may take a minute)..."
        try { npm install -g "`@mimo-ai/cli" } catch {}
        if (-not (Get-Command mimo -ErrorAction SilentlyContinue)) {
            Write-Host "[$Tool] ERROR: could not auto-install mimo."
            Write-Host "[$Tool]   npm install -g `@mimo-ai/cli"
            Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
            exit 1
        }
        Write-Host "[$Tool] mimo installed."
    }

    # Write MCP entry into project-level .mimocode/mimocode.json
    $MimoDir = Join-Path $ProjectPath ".mimocode"
    New-Item -ItemType Directory -Force -Path $MimoDir | Out-Null
    $MimoConf = Join-Path $MimoDir "mimocode.json"
    $mimoMcp = [PSCustomObject]@{}
    if (Test-Path $MimoConf) {
        try {
            $parsed = Get-Content $MimoConf -Raw | ConvertFrom-Json
            if ($parsed.mcpServers) { $mimoMcp = $parsed.mcpServers }
        } catch {}
    }
    $mimoMcp | Add-Member -NotePropertyName "dual-graph" `
        -NotePropertyValue ([PSCustomObject]@{ url = "http://127.0.0.1:$McpPort/mcp" }) -Force
    $mimoOut = [PSCustomObject]@{ mcpServers = $mimoMcp }
    $mimoTmp = [System.IO.Path]::GetTempFileName()
    [System.IO.File]::WriteAllText($mimoTmp, ($mimoOut | ConvertTo-Json -Depth 5 -Compress))
    & $Python -c "import json,sys;d=json.load(open(sys.argv[1]));open(sys.argv[2],'w',encoding='utf-8').write(json.dumps(d,indent=2)+'\n')" $mimoTmp $MimoConf
    Remove-Item $mimoTmp -ErrorAction SilentlyContinue

    Write-Host "[$Tool] MCP config written -> $MimoConf"
    Write-Host "[$Tool] MCP URL: http://127.0.0.1:$McpPort/mcp"

    # Write/append AGENTS.md (MiMo Code reads rules from AGENTS.md/MEMORY.md)
    $AgentsFile = Join-Path $ProjectPath "AGENTS.md"
    $MimoPolicyMarker = "dgc-policy-v11"
    if ((-not (Test-Path $AgentsFile)) -or (-not (Select-String -Path $AgentsFile -Pattern $MimoPolicyMarker -Quiet))) {
        Write-Host "[$Tool] Writing AGENTS.md policy ..."
        Write-PolicyBlock -FilePath $AgentsFile -Marker $MimoPolicyMarker
        Write-Host "[$Tool] AGENTS.md updated."
    }

    Write-Host ""
    Set-Location $ProjectPath
    Write-Host "[$Tool] Starting mimo..."
    Write-Host ""
    mimo
}

# Cleanup
Stop-Process -Id $mcpProc.Id -Force -ErrorAction SilentlyContinue
