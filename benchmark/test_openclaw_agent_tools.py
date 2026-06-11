#!/usr/bin/env python3
"""
Test: verify OpenClaw agent calls dual-graph MCP tools.

Starts the MCP server, registers it with OpenClaw, runs one agent turn via
`openclaw agent --local --json`, and verifies tool calls appear in the output.

Requirements:
    - openclaw CLI installed (npm install -g openclaw@latest)
    - Model provider API key in shell (OPENAI_API_KEY or ANTHROPIC_API_KEY)
    - Python 3.10+

Usage:
    python benchmark/test_openclaw_agent_tools.py [--port 9876] [--timeout 120]
    python benchmark/test_openclaw_agent_tools.py --mock  # skip real MCP server
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
MCP_SERVER_PATH = os.path.expanduser(
    "~/Documents/Open source/Claude-CLI-Compact-core/mcp_graph_server.py"
)

# ─── MCP server management ───────────────────────────────────────────────────


def find_free_port() -> int:
    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


def start_mcp_server(port: int) -> subprocess.Popen | None:
    """Start the dual-graph MCP server on the given port."""
    if not os.path.exists(MCP_SERVER_PATH):
        print(f"  [SKIP] MCP server not found at {MCP_SERVER_PATH}")
        return None

    env = os.environ.copy()
    env["PORT"] = str(port)
    env["DG_DATA_DIR"] = tempfile.mkdtemp(prefix="dg_test_")
    env["DUAL_GRAPH_PROJECT_ROOT"] = PROJECT_ROOT

    proc = subprocess.Popen(
        [sys.executable, MCP_SERVER_PATH],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    for attempt in range(30):
        time.sleep(0.5)
        if proc.poll() is not None:
            stderr = proc.stderr.read().decode() if proc.stderr else ""
            print(f"  [ERROR] Server exited: {stderr[:300]}")
            return None
        try:
            urllib.request.urlopen(f"http://127.0.0.1:{port}/mcp", timeout=2)
        except urllib.error.HTTPError:
            print(f"  [OK] MCP server ready on port {port}")
            return proc
        except Exception:
            continue

    print("  [WARN] Server didn't respond in 15s")
    proc.terminate()
    return None


# ─── OpenClaw config management ──────────────────────────────────────────────

OPENCLAW_CONFIG = os.path.expanduser("~/.openclaw/openclaw.json")


def register_mcp_in_openclaw(port: int) -> dict | None:
    """Register the dual-graph MCP server in OpenClaw's config. Returns old config for restore."""
    old_config = None
    if os.path.exists(OPENCLAW_CONFIG):
        with open(OPENCLAW_CONFIG, "r") as f:
            old_config = json.load(f)

    # Try CLI method first
    url = f"http://127.0.0.1:{port}/mcp"
    result = subprocess.run(
        ["openclaw", "mcp", "set", "dual-graph",
         json.dumps({"url": url, "transport": "streamable-http"})],
        capture_output=True, text=True
    )
    if result.returncode == 0:
        print(f"  [OK] Registered MCP via openclaw CLI")
        return old_config

    # Fallback: write config directly
    config = old_config.copy() if old_config else {}
    mcp = config.get("mcp", {})
    servers = mcp.get("servers", {})
    servers["dual-graph"] = {"url": url, "transport": "streamable-http"}
    mcp["servers"] = servers
    config["mcp"] = mcp

    os.makedirs(os.path.dirname(OPENCLAW_CONFIG), exist_ok=True)
    with open(OPENCLAW_CONFIG, "w") as f:
        json.dump(config, f, indent=2)
        f.write("\n")

    print(f"  [OK] Registered MCP via config file")
    return old_config


def restore_openclaw_config(old_config: dict | None):
    """Restore the original OpenClaw config."""
    if old_config is None:
        # Remove MCP section if we added it
        if os.path.exists(OPENCLAW_CONFIG):
            with open(OPENCLAW_CONFIG, "r") as f:
                config = json.load(f)
            config.pop("mcp", None)
            with open(OPENCLAW_CONFIG, "w") as f:
                json.dump(config, f, indent=2)
                f.write("\n")
    else:
        with open(OPENCLAW_CONFIG, "w") as f:
            json.dump(old_config, f, indent=2)
            f.write("\n")


# ─── Run OpenClaw agent ──────────────────────────────────────────────────────


def _get_aws_env() -> dict:
    """
    Load AWS credentials from Claude Code's settings.json (the Bedrock-backed
    subscription).  Falls back to whatever is already in the environment.
    """
    env = os.environ.copy()
    settings_path = os.path.expanduser("~/.claude/settings.json")
    if os.path.exists(settings_path):
        try:
            with open(settings_path) as f:
                s = json.load(f)
            for k in ("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_REGION"):
                v = s.get("env", {}).get(k)
                if v:
                    env[k] = v
        except Exception:
            pass
    return env


def _clear_auth_cooldown():
    """Clear OpenClaw's auth failure cooldown so bedrock provider isn't skipped."""
    import sqlite3
    db_path = os.path.expanduser("~/.openclaw/agents/main/agent/openclaw-agent.sqlite")
    if os.path.exists(db_path):
        try:
            con = sqlite3.connect(db_path)
            con.execute("DELETE FROM auth_profile_state")
            con.commit()
            con.close()
        except Exception:
            pass


def run_openclaw_agent(message: str, timeout: int = 120) -> dict:
    """
    Run `openclaw agent --local --json --message <msg>` and return parsed output.
    """
    cmd = [
        "openclaw", "agent",
        "--local",
        "--json",
        "--agent", "main",
        "--session-key", "agent:main:dg-test",
        "--model", os.environ.get("OPENCLAW_DEFAULT_MODEL", "amazon-bedrock/global.anthropic.claude-opus-4-6-v1"),
        "--message", message,
        "--thinking", "off",
        "--timeout", str(timeout),
    ]

    print(f"\n  Running: {' '.join(cmd[:6])}...")
    print(f"  Message: {message[:80]}...")

    _clear_auth_cooldown()
    env = _get_aws_env()

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout + 30,
        cwd=PROJECT_ROOT,
        env=env,
    )

    output = {
        "returncode": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "parsed": None,
        "session_file": None,
        "tool_calls": [],
    }

    # Parse the --json stdout (payloads + meta)
    clean_stdout = "\n".join(
        l for l in result.stdout.split("\n") if not l.startswith("\x1b")
    ).strip()
    if clean_stdout:
        try:
            parsed = json.loads(clean_stdout)
            output["parsed"] = parsed
            # Get session trajectory file path from meta
            session_file = (
                parsed.get("meta", {})
                .get("agentMeta", {})
                .get("sessionFile", "")
            )
            if session_file:
                # trajectory file is sessionFile + ".trajectory.jsonl" without .jsonl
                # actually it's <session-id>.trajectory.jsonl alongside <session-id>.jsonl
                traj = session_file.replace(".jsonl", ".trajectory.jsonl")
                if os.path.exists(traj):
                    output["session_file"] = traj
                    output["tool_calls"] = extract_tool_calls_from_trajectory(traj)
        except json.JSONDecodeError:
            pass

    return output


def extract_tool_calls_from_trajectory(traj_path: str) -> list[dict]:
    """
    Extract MCP tool calls from an OpenClaw trajectory JSONL file.

    Tool calls appear in model.completed -> messagesSnapshot[].content[]
    as {"type": "toolCall", "name": "server__tool_name", "arguments": {...}}
    """
    calls = []
    try:
        with open(traj_path) as f:
            for raw in f:
                obj = json.loads(raw.strip())
                if obj.get("type") != "model.completed":
                    continue
                for msg in obj.get("data", {}).get("messagesSnapshot", []):
                    for block in msg.get("content", []):
                        if not isinstance(block, dict):
                            continue
                        if block.get("type") == "toolCall":
                            full_name = block.get("name", "")
                            # Strip MCP server prefix: "dual-graph__graph_continue" -> "graph_continue"
                            tool_name = full_name.split("__", 1)[-1] if "__" in full_name else full_name
                            calls.append({
                                "name": tool_name,
                                "full_name": full_name,
                                "input": block.get("arguments", {}),
                            })
    except Exception as e:
        print(f"  [WARN] Could not read trajectory: {e}")
    return calls


# ─── Verification ────────────────────────────────────────────────────────────


def verify_results(output: dict) -> bool:
    """Check that OpenClaw called the expected MCP tools."""
    print("\n" + "=" * 60)
    print("TEST RESULTS")
    print("=" * 60)

    tool_calls = output["tool_calls"]
    tool_names = list({tc["name"] for tc in tool_calls})

    print(f"\n  Return code: {output['returncode']}")
    print(f"  Tool calls found: {len(tool_calls)}")
    print(f"  Tools called: {tool_names}")

    if output.get("session_file"):
        print(f"  Session trajectory: {output['session_file']}")

    if output["stderr"]:
        stderr_preview = output["stderr"][:200]
        print(f"  Stderr: {stderr_preview}")

    if not output["parsed"]:
        print(f"\n  Raw stdout (first 500 chars):")
        print(f"    {output['stdout'][:500]}")

    checks = [
        ("openclaw exited cleanly", output["returncode"] == 0),
        ("JSON output parsed", output["parsed"] is not None),
        ("graph_continue called", "graph_continue" in tool_names),
        ("graph_read called", "graph_read" in tool_names),
        ("At least 2 tool calls", len(tool_calls) >= 2),
    ]

    passed = True
    print("\n  Checks:")
    for label, ok in checks:
        status = "PASS" if ok else "FAIL"
        print(f"    [{status}] {label}")
        if not ok:
            passed = False

    # Show individual tool calls
    if tool_calls:
        print("\n  Tool call sequence:")
        for i, tc in enumerate(tool_calls, 1):
            input_str = json.dumps(tc["input"])[:80]
            print(f"    {i}. {tc['name']}({input_str})")

    print(f"\n  {'ALL TESTS PASSED' if passed else 'SOME TESTS FAILED'}")
    return passed


# ─── Main ────────────────────────────────────────────────────────────────────


def main():
    parser = argparse.ArgumentParser(
        description="Test OpenClaw agent calling dual-graph MCP tools"
    )
    parser.add_argument("--port", type=int, default=0, help="MCP server port (0=auto)")
    parser.add_argument("--timeout", type=int, default=120, help="Agent timeout in seconds")
    parser.add_argument("--mock", action="store_true", help="Skip MCP server, test agent only")
    parser.add_argument("--keep-config", action="store_true", help="Don't restore openclaw config after test")
    args = parser.parse_args()

    # Check openclaw is installed
    if not shutil.which("openclaw"):
        print("[ERROR] openclaw CLI not found. Install with: npm install -g openclaw@latest")
        sys.exit(1)

    port = args.port or find_free_port()
    server_proc = None
    old_config = None

    print("=" * 60)
    print("OpenClaw Agent + Dual-Graph MCP Tool Test")
    print("=" * 60)

    try:
        # Step 1: Start MCP server
        if not args.mock:
            print(f"\n[1/4] Starting MCP server on port {port}...")
            server_proc = start_mcp_server(port)
            if server_proc is None:
                print("  [WARN] No MCP server — OpenClaw will fail to call tools.")
                print("  [INFO] Use --mock to skip server requirement.")
        else:
            print(f"\n[1/4] Skipping MCP server (--mock)")

        # Step 2: Register MCP in OpenClaw config
        if server_proc or args.mock:
            print(f"\n[2/4] Registering MCP server in OpenClaw config...")
            old_config = register_mcp_in_openclaw(port)
        else:
            print(f"\n[2/4] Skipping MCP registration (no server)")

        # Step 3: Run OpenClaw agent
        print(f"\n[3/4] Running OpenClaw agent (timeout={args.timeout}s)...")
        message = (
            "The dual-graph MCP server is connected. "
            "Call graph_continue first to start a session, then read one recommended file with graph_read. "
            "Report what you found."
        )
        output = run_openclaw_agent(message, timeout=args.timeout)

        # Step 4: Verify
        print(f"\n[4/4] Verifying results...")
        passed = verify_results(output)

        sys.exit(0 if passed else 1)

    except subprocess.TimeoutExpired:
        print("\n[ERROR] OpenClaw agent timed out")
        sys.exit(2)
    except KeyboardInterrupt:
        print("\n[INFO] Interrupted by user")
        sys.exit(130)
    finally:
        # Cleanup
        if server_proc:
            server_proc.terminate()
            try:
                server_proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                server_proc.kill()
            print("\n[CLEANUP] MCP server stopped.")

        if old_config is not None and not args.keep_config:
            restore_openclaw_config(old_config)
            print("[CLEANUP] OpenClaw config restored.")


if __name__ == "__main__":
    main()
