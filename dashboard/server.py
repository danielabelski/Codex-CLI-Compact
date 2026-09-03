#!/usr/bin/env python3
"""GrapeRoot Dashboard — local web server for managing AI coding tools."""

import json
import os
import subprocess
import signal
import sys
import webbrowser
from pathlib import Path
from typing import Any

try:
    from fastapi import FastAPI, HTTPException
    from fastapi.staticfiles import StaticFiles
    from fastapi.responses import FileResponse, JSONResponse
    import uvicorn
except ImportError:
    print("Installing dashboard dependencies...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "fastapi", "uvicorn[standard]", "--quiet"])
    from fastapi import FastAPI, HTTPException
    from fastapi.staticfiles import StaticFiles
    from fastapi.responses import FileResponse, JSONResponse
    import uvicorn

app = FastAPI(title="GrapeRoot Dashboard")

SCRIPT_DIR = Path(__file__).resolve().parent.parent / "bin"
DATA_DIR = Path.home() / ".dual-graph"
IDENTITY_FILE = DATA_DIR / "identity.json"
DASHBOARD_DIR = Path(__file__).resolve().parent
DASHBOARD_STATE = DATA_DIR / "dashboard_state.json"

MCP_PORT = 8080
MCP_ENTRY_NAME = "dual-graph"

# ── Tool definitions with config paths ───────────────────────────────────────
# "scope" is "project" (needs project path) or "home" (global user config)
# "config_format" describes the JSON structure

TOOLS = [
    {
        "id": "claude",
        "name": "Claude Code",
        "icon": "CC",
        "color": "#D97706",
        "scope": "project",
        "config_path": ".mcp.json",
        "config_format": "mcpServers",
        "entry_builder": "_claude_entry",
    },
    {
        "id": "cursor",
        "name": "Cursor",
        "icon": "Cu",
        "color": "#8B5CF6",
        "scope": "project",
        "config_path": ".cursor/mcp.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "gemini",
        "name": "Gemini CLI",
        "icon": "Ge",
        "color": "#3B82F6",
        "scope": "home",
        "config_path": ".gemini/settings.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "copilot",
        "name": "GitHub Copilot",
        "icon": "GH",
        "color": "#6366F1",
        "scope": "project",
        "config_path": ".vscode/mcp.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "antigravity",
        "name": "Antigravity",
        "icon": "AG",
        "color": "#EC4899",
        "scope": "home",
        "config_path": ".gemini/antigravity-cli/mcp_config.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "opencode",
        "name": "OpenCode",
        "icon": "OC",
        "color": "#10B981",
        "scope": "project",
        "config_path": "opencode.json",
        "config_format": "mcpServers",
        "entry_builder": "_opencode_entry",
    },
    {
        "id": "kiro",
        "name": "Kiro",
        "icon": "Ki",
        "color": "#F59E0B",
        "scope": "project",
        "config_path": ".kiro/settings/mcp.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "qwen",
        "name": "Qwen Code",
        "icon": "Qw",
        "color": "#0EA5E9",
        "scope": "project",
        "config_path": ".qwen/settings.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "command-code",
        "name": "Command Code",
        "icon": "CM",
        "color": "#6D28D9",
        "scope": "home",
        "config_path": ".commandcode/mcp.json",
        "config_format": "mcpServers",
        "entry_builder": "_commandcode_entry",
    },
    {
        "id": "openclaw",
        "name": "OpenClaw",
        "icon": "OW",
        "color": "#EF4444",
        "scope": "home",
        "config_path": ".openclaw/openclaw.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "kilocode",
        "name": "Kilocode",
        "icon": "KC",
        "color": "#14B8A6",
        "scope": "project",
        "config_path": "kilo.jsonc",
        "config_format": "mcp",
        "entry_builder": "_kilocode_entry",
    },
    {
        "id": "mimocode",
        "name": "Mimocode",
        "icon": "Mi",
        "color": "#F97316",
        "scope": "project",
        "config_path": ".mimocode/mimocode.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
    {
        "id": "codex",
        "name": "Codex CLI",
        "icon": "Cx",
        "color": "#22C55E",
        "scope": "cli",
        "config_path": "",
        "config_format": "cli",
        "entry_builder": "_codex_entry",
    },
    {
        "id": "minimax",
        "name": "MiniMax",
        "icon": "MM",
        "color": "#A855F7",
        "scope": "home",
        "config_path": ".gemini/settings.json",
        "config_format": "mcpServers",
        "entry_builder": "_http_entry",
    },
]


# ── MCP entry builders ───────────────────────────────────────────────────────

def _http_entry(port: int) -> dict:
    return {"transport": "http", "url": f"http://127.0.0.1:{port}/mcp"}


def _claude_entry(port: int) -> dict:
    return {"transport": "http", "url": f"http://127.0.0.1:{port}/mcp"}


def _commandcode_entry(port: int) -> dict:
    return {"transport": "http", "url": f"http://127.0.0.1:{port}/mcp"}


def _opencode_entry(port: int) -> dict:
    return {"type": "remote", "url": f"http://127.0.0.1:{port}/mcp"}


def _kilocode_entry(port: int) -> dict:
    return {"type": "remote", "url": f"http://127.0.0.1:{port}/mcp", "enabled": True}


def _codex_entry(port: int) -> dict:
    return {}


ENTRY_BUILDERS = {
    "_http_entry": _http_entry,
    "_claude_entry": _claude_entry,
    "_commandcode_entry": _commandcode_entry,
    "_opencode_entry": _opencode_entry,
    "_kilocode_entry": _kilocode_entry,
    "_codex_entry": _codex_entry,
}


# ── Config file read/write helpers ───────────────────────────────────────────

def _resolve_config_path(tool: dict, project_path: str) -> Path | None:
    if tool["scope"] == "cli":
        return None
    if tool["scope"] == "home":
        return Path.home() / tool["config_path"]
    return Path(project_path) / tool["config_path"]


def _read_json(path: Path) -> dict:
    if path.exists():
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except Exception:
            pass
    return {}


def _write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def _is_enabled(tool: dict, project_path: str) -> bool:
    """Check if GrapeRoot MCP entry exists in this tool's config."""
    if tool["scope"] == "cli":
        try:
            result = subprocess.run(
                ["codex", "mcp", "list"], capture_output=True, text=True, timeout=5
            )
            return MCP_ENTRY_NAME in result.stdout
        except Exception:
            return False

    config_path = _resolve_config_path(tool, project_path)
    if not config_path or not config_path.exists():
        return False

    cfg = _read_json(config_path)
    container_key = tool["config_format"]
    servers = cfg.get(container_key, {})
    return MCP_ENTRY_NAME in servers


def _enable_tool(tool: dict, project_path: str, port: int) -> dict:
    """Write GrapeRoot MCP entry into tool's config file."""
    if tool["scope"] == "cli":
        try:
            subprocess.run(
                ["codex", "mcp", "remove", MCP_ENTRY_NAME],
                capture_output=True, timeout=5,
            )
            result = subprocess.run(
                ["codex", "mcp", "add", MCP_ENTRY_NAME, "--",
                 "npx", "mcp-remote", f"http://127.0.0.1:{port}/mcp", "--allow-http"],
                capture_output=True, text=True, timeout=10,
            )
            if result.returncode == 0:
                return {"ok": True, "message": f"Registered via codex CLI"}
            return {"ok": False, "message": f"codex mcp add failed: {result.stderr.strip()}"}
        except FileNotFoundError:
            return {"ok": False, "message": "codex CLI not found. Install: npm install -g @openai/codex"}
        except Exception as e:
            return {"ok": False, "message": str(e)}

    config_path = _resolve_config_path(tool, project_path)
    if not config_path:
        return {"ok": False, "message": "No config path for this tool"}

    builder = ENTRY_BUILDERS.get(tool["entry_builder"], _http_entry)
    entry = builder(port)

    cfg = _read_json(config_path)
    container_key = tool["config_format"]
    servers = cfg.get(container_key, {})
    servers[MCP_ENTRY_NAME] = entry
    cfg[container_key] = servers

    if tool["id"] == "opencode" and "$schema" not in cfg:
        cfg["$schema"] = "https://opencode.ai/config.json"

    _write_json(config_path, cfg)
    return {"ok": True, "config_path": str(config_path)}


def _disable_tool(tool: dict, project_path: str) -> dict:
    """Remove GrapeRoot MCP entry from tool's config file."""
    if tool["scope"] == "cli":
        try:
            subprocess.run(
                ["codex", "mcp", "remove", MCP_ENTRY_NAME],
                capture_output=True, timeout=5,
            )
            return {"ok": True, "message": "Removed via codex CLI"}
        except FileNotFoundError:
            return {"ok": False, "message": "codex CLI not found"}
        except Exception as e:
            return {"ok": False, "message": str(e)}

    config_path = _resolve_config_path(tool, project_path)
    if not config_path:
        return {"ok": False, "message": "No config path for this tool"}

    if not config_path.exists():
        return {"ok": True, "message": "Config file doesn't exist, nothing to remove"}

    cfg = _read_json(config_path)
    container_key = tool["config_format"]
    servers = cfg.get(container_key, {})

    if MCP_ENTRY_NAME not in servers:
        return {"ok": True, "message": "Already disabled"}

    del servers[MCP_ENTRY_NAME]
    cfg[container_key] = servers

    if not servers:
        del cfg[container_key]

    if cfg:
        _write_json(config_path, cfg)
    else:
        config_path.unlink(missing_ok=True)

    return {"ok": True, "config_path": str(config_path)}


# ── MCP Server management ───────────────────────────────────────────────────

_mcp_process: subprocess.Popen | None = None


def _start_mcp_server(project_path: str) -> dict:
    global _mcp_process
    if _mcp_process and _mcp_process.poll() is None:
        return {"ok": True, "pid": _mcp_process.pid, "message": "Already running"}

    venv_bin = SCRIPT_DIR.parent / ".venv" / "bin"
    mcp_cmd = venv_bin / "mcp-graph-server"

    env = os.environ.copy()
    env["DUAL_GRAPH_PROJECT_ROOT"] = project_path
    env["DG_DATA_DIR"] = str(Path(project_path) / ".dual-graph")

    if mcp_cmd.exists():
        cmd = [str(mcp_cmd)]
    else:
        server_py = SCRIPT_DIR / "mcp_graph_server.py"
        if server_py.exists():
            cmd = [sys.executable, str(server_py)]
        else:
            try:
                cmd = [sys.executable, "-c", "from graperoot.mcp_graph_server import main; main()"]
            except Exception:
                return {"ok": False, "message": "MCP server binary not found"}

    try:
        _mcp_process = subprocess.Popen(
            cmd,
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
        return {"ok": True, "pid": _mcp_process.pid}
    except Exception as e:
        return {"ok": False, "message": str(e)}


def _stop_mcp_server() -> dict:
    global _mcp_process
    if _mcp_process and _mcp_process.poll() is None:
        try:
            os.killpg(os.getpgid(_mcp_process.pid), signal.SIGTERM)
            _mcp_process.wait(timeout=5)
        except Exception:
            _mcp_process.kill()
        _mcp_process = None
        return {"ok": True}
    return {"ok": True, "message": "Not running"}


def _mcp_running() -> bool:
    return _mcp_process is not None and _mcp_process.poll() is None


# ── Utility helpers ──────────────────────────────────────────────────────────

def _read_identity() -> dict:
    if IDENTITY_FILE.exists():
        try:
            return json.loads(IDENTITY_FILE.read_text(encoding="utf-8"))
        except Exception:
            pass
    return {}


def _read_version() -> str:
    vf = SCRIPT_DIR / "version.txt"
    if vf.exists():
        return vf.read_text().strip()
    return "unknown"


def _get_graph_info(project_path: str) -> dict:
    graph_file = Path(project_path) / ".dual-graph" / "info_graph.json"
    if graph_file.exists():
        try:
            data = json.loads(graph_file.read_text(encoding="utf-8"))
            return {
                "node_count": data.get("node_count", 0),
                "edge_count": data.get("edge_count", 0),
                "file_count": data.get("file_count", 0),
                "symbol_count": data.get("symbol_count", 0),
            }
        except Exception:
            pass
    return {"node_count": 0, "edge_count": 0, "file_count": 0, "symbol_count": 0}


def _get_recent_projects() -> list[str]:
    state_file = DATA_DIR / "recent_projects.json"
    if state_file.exists():
        try:
            return json.loads(state_file.read_text(encoding="utf-8"))
        except Exception:
            pass
    return []


def _save_recent_projects(projects: list[str]) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    (DATA_DIR / "recent_projects.json").write_text(
        json.dumps(projects[:10], indent=2), encoding="utf-8"
    )


# ── API Routes ───────────────────────────────────────────────────────────────

@app.get("/")
async def index():
    return FileResponse(DASHBOARD_DIR / "static" / "index.html")


@app.get("/api/status")
async def status():
    identity = _read_identity()
    project_path = ""
    recent = _get_recent_projects()
    if recent:
        project_path = recent[0]

    tool_status = []
    for t in TOOLS:
        enabled = _is_enabled(t, project_path) if project_path else False
        tool_status.append({
            "id": t["id"],
            "name": t["name"],
            "icon": t["icon"],
            "color": t["color"],
            "scope": t["scope"],
            "enabled": enabled,
        })

    graph = _get_graph_info(project_path) if project_path else {}

    return {
        "version": _read_version(),
        "telemetry": identity.get("telemetry", "unknown"),
        "graph": graph,
        "tools": tool_status,
        "recent_projects": recent,
        "mcp_running": _mcp_running(),
        "mcp_port": MCP_PORT,
        "project_path": project_path,
    }


@app.get("/api/project/{path:path}")
async def project_info(path: str):
    project_path = "/" + path
    if not Path(project_path).is_dir():
        raise HTTPException(404, "Project directory not found")
    graph = _get_graph_info(project_path)
    return {"path": project_path, "graph": graph}


@app.get("/api/browse")
async def browse_root():
    return _browse_dir(Path.home())


@app.get("/api/browse/{path:path}")
async def browse_dir(path: str):
    full = Path("/" + path)
    if not full.is_dir():
        raise HTTPException(404, "Not a directory")
    return _browse_dir(full)


def _browse_dir(dirpath: Path) -> dict:
    dirs = []
    has_git = (dirpath / ".git").is_dir()
    try:
        for entry in sorted(dirpath.iterdir(), key=lambda e: e.name.lower()):
            if not entry.is_dir():
                continue
            name = entry.name
            if name.startswith(".") and name not in (".git",):
                continue
            if name in ("node_modules", "__pycache__", "venv", ".venv", "dist", "build", ".next"):
                continue
            is_project = (entry / ".git").is_dir() or (entry / "package.json").is_file() or \
                         (entry / "pyproject.toml").is_file() or (entry / "Cargo.toml").is_file() or \
                         (entry / "pubspec.yaml").is_file() or (entry / "go.mod").is_file()
            dirs.append({"name": name, "path": str(entry), "is_project": is_project})
    except PermissionError:
        pass
    return {
        "current": str(dirpath),
        "parent": str(dirpath.parent) if dirpath != dirpath.parent else None,
        "is_project": has_git or (dirpath / "package.json").is_file() or (dirpath / "pyproject.toml").is_file(),
        "dirs": dirs,
    }


@app.post("/api/toggle")
async def toggle_tool(body: dict[str, Any]):
    tool_id = body.get("tool_id", "")
    enable = body.get("enable", False)
    project_path = body.get("project_path", "")

    if not project_path or not Path(project_path).is_dir():
        raise HTTPException(400, "Invalid project path")

    tool = next((t for t in TOOLS if t["id"] == tool_id), None)
    if not tool:
        raise HTTPException(400, f"Unknown tool: {tool_id}")

    if enable:
        result = _enable_tool(tool, project_path, MCP_PORT)
        if result.get("ok"):
            config_path = result.get("config_path", "CLI")
            return {"ok": True, "message": f"MCP access enabled for {tool['name']}", "config_path": config_path}
        return JSONResponse(status_code=500, content=result)
    else:
        result = _disable_tool(tool, project_path)
        if result.get("ok"):
            return {"ok": True, "message": f"MCP access disabled for {tool['name']}"}
        return JSONResponse(status_code=500, content=result)


@app.post("/api/mcp/start")
async def mcp_start(body: dict[str, Any]):
    project_path = body.get("project_path", "")
    if not project_path or not Path(project_path).is_dir():
        raise HTTPException(400, "Invalid project path")
    return _start_mcp_server(project_path)


@app.post("/api/mcp/stop")
async def mcp_stop():
    return _stop_mcp_server()


@app.post("/api/scan")
async def scan_project(body: dict[str, Any]):
    project_path = body.get("project_path", "")
    if not project_path or not Path(project_path).is_dir():
        raise HTTPException(400, "Invalid project path")

    projects = _get_recent_projects()
    if project_path not in projects:
        projects.insert(0, project_path)
        _save_recent_projects(projects)

    try:
        sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent / "Claude-CLI-Compact-core" / "src"))
        from graperoot.graph_builder import scan as gb_scan
        result = gb_scan(project_path)
        return {"ok": True, "result": {
            "node_count": result.get("node_count", 0),
            "edge_count": result.get("edge_count", 0),
            "file_count": result.get("file_count", 0),
            "symbol_count": result.get("symbol_count", 0),
        }}
    except ImportError:
        result = subprocess.run(
            [sys.executable, "-m", "graperoot.graph_builder", project_path],
            capture_output=True, text=True, timeout=120,
        )
        return {"ok": result.returncode == 0, "output": result.stdout}
    except Exception as e:
        raise HTTPException(500, str(e))


@app.post("/api/settings")
async def update_settings(body: dict[str, Any]):
    identity = _read_identity()
    if "telemetry" in body:
        identity["telemetry"] = "enabled" if body["telemetry"] else "disabled"
    IDENTITY_FILE.parent.mkdir(parents=True, exist_ok=True)
    IDENTITY_FILE.write_text(json.dumps(identity, indent=2), encoding="utf-8")
    return {"ok": True}


app.mount("/static", StaticFiles(directory=str(DASHBOARD_DIR / "static")), name="static")


def main():
    port = int(os.environ.get("GRAPEROOT_PORT", os.environ.get("DUAL_GRAPH_PORT", os.environ.get("PORT", "9090"))))
    host = os.environ.get("HOST", "127.0.0.1")
    print(f"\n  GrapeRoot Dashboard v{_read_version()}")
    print(f"  http://{host}:{port}\n")
    if not os.environ.get("RAILWAY_ENVIRONMENT"):
        webbrowser.open(f"http://localhost:{port}")
    uvicorn.run(app, host=host, port=port, log_level="warning")


if __name__ == "__main__":
    main()
