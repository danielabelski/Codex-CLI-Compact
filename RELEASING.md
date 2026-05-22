# Release Checklist

Follow this checklist **exactly** when bumping a version. All three repos must stay in sync.

## Repos

| Repo | Local path | Remote |
|------|-----------|--------|
| **Dashboard** | `~/Documents/Open source/beads-main/dual-graph-dashboard` | `kunal12203/Codex-CLI-Compact` |
| **Core** | `~/Documents/Open source/Claude-CLI-Compact-core` | `kunal12203/Claude-CLI-Compact-core` |
| **Scoop** | `~/Documents/Open source/scoop-dual-graph` | `kunal12203/scoop-dual-graph` |

## Version locations (ALL must match)

| Repo | File | Field |
|------|------|-------|
| Dashboard | `bin/version.txt` | Entire file content |
| Dashboard | `README.md` | `Current version: **X.Y.Z**` |
| Core | `src/graperoot/__init__.py` | `__version__ = "X.Y.Z"` |
| Core | `pyproject.toml` | `version = "X.Y.Z"` |
| Core | `version.txt` | Entire file content (synced to R2 by sync-r2.yml on every push) |
| Scoop | `bucket/dual-graph.json` | `"version": "X.Y.Z"` |

## What ships where

| File | How distributed | Format |
|------|----------------|--------|
| `graph_builder`, `dg`, `context_packer`, `dgc_claude`, `graph_builder_ast` | PyPI (`graperoot`) | compiled `.so` / `.pyd` |
| `audit`, `undo_shield` | PyPI (`graperoot`) | compiled `.so` / `.pyd` |
| `mcp_graph_server` | PyPI (`graperoot`) | plain `.py` (async decorators incompatible with Cython) |
| `dual_graph_launch.sh` | R2 CDN + GitHub | shell script |
| `dgc`, `dg`, `graperoot` launchers | GitHub only | shell/cmd scripts |
| `install.ps1`, `install.sh` | R2 CDN + GitHub | installer scripts |

**audit.py and undo_shield.py are NOT standalone files anymore** — they ship as compiled
`.so` modules inside the graperoot pip package. Do not upload them to R2.

## Step-by-step

### 1. Determine the next version

Find the highest version across all three repos and increment by 1:

```bash
cat ~/Documents/Open\ source/beads-main/dual-graph-dashboard/bin/version.txt
grep __version__ ~/Documents/Open\ source/Claude-CLI-Compact-core/src/graperoot/__init__.py
grep '"version"' ~/Documents/Open\ source/scoop-dual-graph/bucket/dual-graph.json
```

The new version = max(all versions) + 0.0.1

### 2. Update changelog.txt — ALWAYS DO THIS FIRST

**Before touching any version file**, add a new entry at the top of `bin/changelog.txt` (Dashboard):

```
X.Y.Z
- Added/Fixed: <what changed>

```

Then copy to Core:
```bash
cp bin/changelog.txt ../Claude-CLI-Compact-core/changelog.txt
cp bin/dual_graph_launch.sh ../Claude-CLI-Compact-core/dual_graph_launch.sh
```
**Why:** `sync-r2.yml` in Core runs `aws s3 sync .` on every push — it overwrites R2's `dual_graph_launch.sh` with whatever is in the Core repo root. Always keep them in sync.

The changelog is shown to users on auto-update. **Never push a version without updating it.**

### 3. Update all version files

```bash
printf "X.Y.Z" > ~/Documents/Open\ source/beads-main/dual-graph-dashboard/bin/version.txt

sed -i '' 's/Current version: \*\*[0-9.]*\*\*/Current version: **X.Y.Z**/' \
  ~/Documents/Open\ source/beads-main/dual-graph-dashboard/README.md

sed -i '' 's/__version__ = "[0-9.]*"/__version__ = "X.Y.Z"/' \
  ~/Documents/Open\ source/Claude-CLI-Compact-core/src/graperoot/__init__.py

sed -i '' 's/^version = "[0-9.]*"/version = "X.Y.Z"/' \
  ~/Documents/Open\ source/Claude-CLI-Compact-core/pyproject.toml

printf "X.Y.Z" > ~/Documents/Open\ source/Claude-CLI-Compact-core/version.txt
```

### 4. Commit Dashboard

```bash
cd ~/Documents/Open\ source/beads-main/dual-graph-dashboard
git add bin/version.txt bin/changelog.txt README.md \
        bin/dual_graph_launch.sh install.ps1  # add any other changed files
git commit -m "X.Y.Z: <short description>"
```

### 5. Pull and rebase Dashboard

```bash
git stash        # if uncommitted changes exist
git pull --rebase
git stash pop
```

### 6. Get Dashboard commit hash and install.ps1 SHA256

```bash
git rev-parse HEAD          # full commit hash
shasum -a 256 install.ps1   # SHA256 — only changes if install.ps1 changed
```

### 7. Update Scoop manifest

In `scoop-dual-graph/bucket/dual-graph.json`, update:

- `"version"` → new version
- `"url"` → replace the commit hash with the Dashboard commit hash from step 6
- `"hash"` → the SHA256 from step 6 (only changes if `install.ps1` changed)

### 8. Commit Core and Scoop

```bash
# Core — always include changelog.txt + version files; add any changed source files
cd ~/Documents/Open\ source/Claude-CLI-Compact-core
git add src/graperoot/__init__.py pyproject.toml changelog.txt version.txt  # + any changed .py files
git commit -m "X.Y.Z: <description>"

# Scoop
cd ~/Documents/Open\ source/scoop-dual-graph
git add bucket/dual-graph.json
git commit -m "X.Y.Z: <description>"
```

### 9. Push — ORDER MATTERS: Dashboard → Scoop → Core

```bash
cd ~/Documents/Open\ source/beads-main/dual-graph-dashboard && git push

cd ~/Documents/Open\ source/scoop-dual-graph && git push

cd ~/Documents/Open\ source/Claude-CLI-Compact-core && git push
```

### 10. Tag Core to trigger compiled wheel builds (GitHub Actions)

**Always do this after pushing Core.** The `v*` tag triggers `publish.yml` which uses
cibuildwheel to build compiled `.so` wheels for all platforms and publish them to PyPI.

```bash
cd ~/Documents/Open\ source/Claude-CLI-Compact-core
git tag vX.Y.Z
git push origin vX.Y.Z
```

GitHub Actions builds wheels for:

| Platform | Architectures | Python versions |
|----------|--------------|-----------------|
| Linux (manylinux) | x86_64, aarch64 | 3.10, 3.11, 3.12, 3.13 |
| macOS | x86_64, arm64 | 3.10, 3.11, 3.12, 3.13 |
| Windows | AMD64 | 3.10, 3.11, 3.12, 3.13 |

Each wheel contains compiled `.so`/`.pyd` files — **no Python source** visible to users.

Monitor the build at:
`https://github.com/kunal12203/Claude-CLI-Compact-core/actions`

### 11. Upload to Cloudflare R2 (MANDATORY — always do this)

R2 is the fallback CDN for `dual_graph_launch.sh` and installer scripts.

**IMPORTANT:** Only upload launcher/installer files from Dashboard. Do NOT upload Python
source files — those ship via the graperoot pip package (compiled .so) now.

```bash
cd ~/Documents/Open\ source/beads-main/dual-graph-dashboard
R2="https://612010d26d6532d6f2eae623a776a42b.r2.cloudflarestorage.com"

# Upload only what changed (check git diff):
aws s3 cp bin/dual_graph_launch.sh s3://dual-graph-core/dual_graph_launch.sh --endpoint-url "$R2" --profile r2
aws s3 cp bin/dg.ps1              s3://dual-graph-core/dg.ps1               --endpoint-url "$R2" --profile r2
aws s3 cp bin/dgc.ps1             s3://dual-graph-core/dgc.ps1              --endpoint-url "$R2" --profile r2
aws s3 cp bin/graperoot.ps1       s3://dual-graph-core/graperoot.ps1        --endpoint-url "$R2" --profile r2
aws s3 cp install.ps1             s3://dual-graph-core/install.ps1          --endpoint-url "$R2" --profile r2
aws s3 cp bin/changelog.txt       s3://dual-graph-core/changelog.txt        --endpoint-url "$R2" --profile r2

# Always update version.txt LAST (use printf, not echo — avoids trailing newline):
printf "X.Y.Z" | aws s3 cp - s3://dual-graph-core/version.txt --endpoint-url "https://612010d26d6532d6f2eae623a776a42b.r2.cloudflarestorage.com" --profile r2
```

**Note:** Pass `--endpoint-url` as a **literal string**, never a shell variable — variable
expansion silently produces an empty string causing a cryptic AWS CLI error.

### 12. (Optional) Publish a local Mac wheel immediately

GitHub Actions takes ~15 min. If you need Mac arm64 / Python 3.12 available immediately:

```bash
cd ~/Documents/Open\ source/Claude-CLI-Compact-core
python3.12 setup.py bdist_wheel          # builds compiled .so wheel — NOT python3 -m build
python3.12 -m twine upload dist/graperoot-X.Y.Z-cp312-cp312-macosx_*.whl
```

**WARNING:** Never run `python3 -m build` for PyPI releases — it produces a pure-Python
wheel with all source code visible. Always use `setup.py bdist_wheel`.

### 13. Verify everything

```bash
VER="X.Y.Z"   # <-- set this
COMMIT=$(cd ~/Documents/Open\ source/beads-main/dual-graph-dashboard && git rev-parse HEAD)

OK=0; FAIL=0
check() {
  if [ "$2" = "$3" ]; then echo "  PASS  $1"; OK=$((OK+1))
  else echo "  FAIL  $1: got '$2', expected '$3'"; FAIL=$((FAIL+1)); fi
}

check "bin/version.txt"     "$(cat ~/Documents/Open\ source/beads-main/dual-graph-dashboard/bin/version.txt)" "$VER"
check "README.md"           "$(grep -o '[0-9]*\.[0-9]*\.[0-9]*' ~/Documents/Open\ source/beads-main/dual-graph-dashboard/README.md | head -1)" "$VER"
check "Core __init__.py"    "$(grep -o '[0-9]*\.[0-9]*\.[0-9]*' ~/Documents/Open\ source/Claude-CLI-Compact-core/src/graperoot/__init__.py)" "$VER"
check "Core pyproject.toml" "$(grep '^version' ~/Documents/Open\ source/Claude-CLI-Compact-core/pyproject.toml | grep -o '[0-9]*\.[0-9]*\.[0-9]*')" "$VER"
check "Scoop JSON"          "$(grep '"version"' ~/Documents/Open\ source/scoop-dual-graph/bucket/dual-graph.json | grep -o '[0-9]*\.[0-9]*\.[0-9]*')" "$VER"
check "Scoop URL commit"    "$(grep '"url"' ~/Documents/Open\ source/scoop-dual-graph/bucket/dual-graph.json | grep -o '[0-9a-f]\{40\}')" "$COMMIT"
check "R2 version.txt"      "$(aws s3 cp s3://dual-graph-core/version.txt - --endpoint-url "https://612010d26d6532d6f2eae623a776a42b.r2.cloudflarestorage.com" --profile r2 2>/dev/null)" "$VER"
check "GitHub raw"          "$(curl -sf https://raw.githubusercontent.com/kunal12203/Codex-CLI-Compact/main/bin/version.txt)" "$VER"
check "PyPI exists"         "$(curl -sf https://pypi.org/pypi/graperoot/$VER/json | python3 -c 'import sys,json; print(json.load(sys.stdin)["info"]["version"])')" "$VER"
check "Scoop URL HTTP"      "$(curl -sf --max-time 5 -o /dev/null -w '%{http_code}' "$(grep '\"url\"' ~/Documents/Open\ source/scoop-dual-graph/bucket/dual-graph.json | grep -o 'https://[^\"]*')")" "200"

# Verify PyPI wheel is compiled (not pure Python)
check "PyPI wheel compiled" "$(curl -sf https://pypi.org/pypi/graperoot/$VER/json | python3 -c '
import sys,json
data = json.load(sys.stdin)
wheels = [u for u in data["urls"] if u["packagetype"]=="bdist_wheel" and "none-any" not in u["filename"]]
print("yes" if wheels else "no")
')" "yes"

TODAY=$(date +%Y-%m-%d)
for f in dual_graph_launch.sh changelog.txt; do
  DATE=$(aws s3 ls s3://dual-graph-core/$f --endpoint-url "https://612010d26d6532d6f2eae623a776a42b.r2.cloudflarestorage.com" --profile r2 2>/dev/null | awk '{print $1}')
  check "R2 $f date" "$DATE" "$TODAY"
done

echo ""
echo "$OK passed, $FAIL failed"
[ $FAIL -eq 0 ] && echo "ALL GOOD — $VER fully deployed" || echo "ISSUES FOUND — do not announce release yet"
```

## Cython build rules

The graperoot package compiles Python to native `.so`/`.pyd` binaries via Cython.

### Which modules are compiled

| Module | Compiled | Reason |
|--------|----------|--------|
| `graph_builder` | ✓ | core indexing engine |
| `graph_builder_ast` | ✓ | AST parser |
| `dg` | ✓ | retrieval + scoring |
| `context_packer` | ✓ | token packing |
| `dgc_claude` | ✓ | Claude context adapter |
| `audit` | ✓ | vibe code auditor |
| `undo_shield` | ✓ | PreToolUse hook |
| `mcp_graph_server` | ✗ | async/MCP decorators incompatible with Cython |

### Cython compatibility rules

When adding or editing compiled modules, follow these rules or the wheel build will fail:

1. **No inline dict/set/list type annotations on mutable containers:**
   ```python
   # WRONG — Cython rejects defaultdict assigned to dict[K,V]
   adj: dict[str, set[str]] = defaultdict(set)

   # RIGHT
   adj = defaultdict(set)
   ```

2. **No top-level executable code in compiled modules** — wrap everything in `main()`:
   ```python
   # WRONG — top-level code runs on import (breaks compiled module import)
   payload = json.load(sys.stdin)   # top level!

   # RIGHT
   def main():
       payload = json.load(sys.stdin)

   if __name__ == "__main__":
       main()
   ```

3. **No `async def` at module level with MCP decorators** — keep those in `mcp_graph_server.py` (not compiled).

4. **Build command:** always use `python3.12 setup.py bdist_wheel`, never `python3 -m build`.
   `python3 -m build` creates a pure-Python wheel and exposes source code.

5. **Test after building:**
   ```bash
   python3.12 -m zipfile -l dist/graperoot-X.Y.Z-*.whl | grep "\.py\b"
   # Should only show: graperoot/__init__.py and graperoot/mcp_graph_server.py
   # All other modules should appear as .so / .pyd
   ```

### Adding a new compiled module

1. Add the `.py` file to `Claude-CLI-Compact-core/src/graperoot/`
2. Add the module name to `COMPILED_MODULES` in `setup.py`
3. Ensure no top-level executable code (wrap in `main()`)
4. Remove inline type annotations on `defaultdict`/`set`/`list` assignments
5. Build and verify: `python3.12 setup.py bdist_wheel && python3.12 -m zipfile -l dist/*.whl`

## Backwards compatibility checklist

Before releasing any change to `dual_graph_launch.sh` or `dgc.ps1`, verify:

| Command | Expected outcome |
|---------|-----------------|
| `dgc` | Uses `pwd` as project, launches claude normally |
| `dgc /path/to/project` | Uses given path, launches claude normally |
| `dgc /path/to/project "do something"` | Passes prompt to claude |
| `dgc --resume SESSION_ID` | Uses `pwd`, resumes session |
| `dgc audit /path/to/project` | Runs compiled graperoot.audit module |
| `dgc audit /path --fix` | Runs audit then launches dgc with context |

## Common mistakes

- **`python3 -m build` for PyPI** — produces pure-Python wheel, exposes all source. Always use `python3.12 setup.py bdist_wheel`.
- **Skipping the git tag** — cibuildwheel only triggers on `v*` tags. Without it, only the Mac wheel gets published (if you ran step 12).
- **Skipping R2** — always upload changed launcher files + version.txt on every release.
- **Shell variable in `--endpoint-url`** — pass the R2 URL as a literal string; a variable silently expands to empty.
- **Forgetting `pyproject.toml`** — `__init__.py` and `pyproject.toml` versions must match in Core.
- **Forgetting Core `version.txt`** — `sync-r2.yml` runs on every Core push and overwrites R2's `version.txt` with whatever is in Core's root. If stale, R2 reverts to the old version after push.
- **Forgetting to copy `dual_graph_launch.sh` to Core** — same issue: `sync-r2.yml` syncs Core root to R2, overwriting R2's launcher with the stale Core copy on every push.
- **Stale scoop hash** — if you rebase Dashboard after computing the hash, recompute both.
- **Pushing scoop before dashboard** — the scoop URL will 404 until the Dashboard commit exists on GitHub.
- **Version not highest** — always check all three repos; they can drift independently.
- **Uploading audit.py/undo_shield.py to R2** — these are now compiled into the pip package. Do not put them on R2.
- **Cython dict annotation** — `x: dict[K,V] = defaultdict(...)` fails at runtime in compiled modules. Drop the annotation.

## Pip / dependency versions

- `pip` itself: not pinned — installers run `pip install --upgrade pip`
- `mcp>=1.3.0`: minimum floor, not pinned
- `graperoot`: installed by `install.sh`, `install.ps1`, and auto-upgraded on each `dgc` run
- All installers install: `mcp>=1.3.0 uvicorn anyio starlette graperoot`

No pip version conflicts. Dependencies use minimum floors, not pins.
