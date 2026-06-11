#!/usr/bin/env python3
"""
Test script: verify an Anthropic API agent can call dual-graph MCP tools.

Starts the MCP server locally, defines the dual-graph tools for the Claude API,
sends a message that should trigger tool calls (graph_continue, graph_read, etc.),
and verifies the agent actually calls them in its agentic loop.

Requirements:
    pip install anthropic

Usage:
    export ANTHROPIC_API_KEY=sk-ant-...
    python benchmark/test_mcp_agent_tools.py [--port 9999]
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time

import anthropic

# ─── Tool definitions matching the dual-graph MCP server ─────────────────────

TOOLS = [
    {
        "name": "graph_continue",
        "description": "Start or continue a dual-graph session. Call this first before any file exploration.",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "The user's query or task description",
                },
                "top_files": {
                    "type": "integer",
                    "description": "Number of top files to retrieve",
                },
                "top_edges": {
                    "type": "integer",
                    "description": "Number of top edges to retrieve",
                },
                "limit": {
                    "type": "integer",
                    "description": "Max recommended files to return",
                },
            },
            "required": ["query"],
        },
    },
    {
        "name": "graph_read",
        "description": "Read a file or symbol from the project via the dual-graph.",
        "input_schema": {
            "type": "object",
            "properties": {
                "file": {
                    "type": "string",
                    "description": "File path or file::symbol to read",
                },
                "max_chars": {
                    "type": "integer",
                    "description": "Max characters to return",
                },
                "query": {
                    "type": "string",
                    "description": "Optional query to focus the read",
                },
                "anchor": {
                    "type": "string",
                    "description": "Optional line anchor",
                },
            },
            "required": ["file"],
        },
    },
    {
        "name": "graph_scan",
        "description": "Scan a project directory to build the dual-graph index.",
        "input_schema": {
            "type": "object",
            "properties": {
                "project_root": {
                    "type": "string",
                    "description": "Absolute path to the project root to scan",
                },
            },
            "required": ["project_root"],
        },
    },
    {
        "name": "graph_register_edit",
        "description": "Register that files were edited so the graph updates.",
        "input_schema": {
            "type": "object",
            "properties": {
                "files": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "List of edited file paths",
                },
                "summary": {
                    "type": "string",
                    "description": "Optional edit summary",
                },
            },
            "required": ["files"],
        },
    },
    {
        "name": "fallback_rg",
        "description": "Ripgrep fallback search when graph retrieval is insufficient.",
        "input_schema": {
            "type": "object",
            "properties": {
                "pattern": {
                    "type": "string",
                    "description": "Regex pattern to search for",
                },
                "max_hits": {
                    "type": "integer",
                    "description": "Max results to return",
                },
            },
            "required": ["pattern"],
        },
    },
    {
        "name": "graph_add_memory",
        "description": "Add a memory entry to the context store.",
        "input_schema": {
            "type": "object",
            "properties": {
                "type": {
                    "type": "string",
                    "enum": ["decision", "task", "next", "fact", "blocker"],
                    "description": "Type of memory entry",
                },
                "content": {
                    "type": "string",
                    "description": "Memory content (max 15 words)",
                },
                "tags": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Tags for this memory",
                },
                "files": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "Related file paths",
                },
            },
            "required": ["type", "content"],
        },
    },
]

# ─── MCP server process management ───────────────────────────────────────────

MCP_SERVER_PATH = os.path.join(
    os.path.dirname(__file__),
    "..",
    "~",
    "Documents",
    "Open source",
    "Claude-CLI-Compact-core",
    "mcp_graph_server.py",
)


def start_mcp_server(port: int) -> subprocess.Popen | None:
    """Start the MCP server in the background. Returns the process or None."""
    server_path = os.path.realpath(MCP_SERVER_PATH)
    if not os.path.exists(server_path):
        print(f"[SKIP] MCP server not found at {server_path}")
        print("[INFO] Running in tool-call-only mode (no live server)")
        return None

    env = os.environ.copy()
    env["PORT"] = str(port)
    env["DG_DATA_DIR"] = "/tmp/dg_test_data"
    env["DUAL_GRAPH_PROJECT_ROOT"] = os.path.dirname(os.path.dirname(__file__))

    os.makedirs("/tmp/dg_test_data", exist_ok=True)

    proc = subprocess.Popen(
        [sys.executable, server_path],
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    # Wait for server to be ready
    for _ in range(30):
        time.sleep(0.5)
        if proc.poll() is not None:
            stderr = proc.stderr.read().decode() if proc.stderr else ""
            print(f"[ERROR] MCP server exited early: {stderr[:500]}")
            return None
        try:
            import urllib.request
            urllib.request.urlopen(f"http://127.0.0.1:{port}/mcp", timeout=2)
        except urllib.error.HTTPError:
            # 405 Method Not Allowed on GET means server is up (expects POST)
            print(f"[OK] MCP server listening on port {port}")
            return proc
        except Exception:
            continue

    print("[WARN] MCP server didn't respond in 15s, continuing without it")
    proc.terminate()
    return None


# ─── Simulated tool execution (for when server isn't available) ───────────────

def execute_tool_simulated(name: str, input_data: dict) -> str:
    """Return a simulated tool result for testing the agent loop."""
    if name == "graph_continue":
        return json.dumps({
            "mode": "retrieve_then_read",
            "confidence": "medium",
            "recommended_files": ["src/main.ts", "src/utils.ts"],
            "max_supplementary_greps": 2,
            "max_supplementary_files": 3,
            "needs_project": False,
            "skip": False,
        })
    elif name == "graph_read":
        return json.dumps({
            "ok": True,
            "file": input_data.get("file", "unknown"),
            "content": f"// Content of {input_data.get('file', 'unknown')}\nexport function main() {{ return 'hello'; }}",
            "lines": 2,
            "chars_used": 80,
        })
    elif name == "graph_scan":
        return json.dumps({
            "ok": True,
            "files_indexed": 42,
            "symbols_indexed": 156,
        })
    elif name == "fallback_rg":
        return json.dumps({
            "ok": True,
            "hits": [
                {"file": "src/main.ts", "line": 10, "text": "function handleRequest()"},
            ],
            "count": 1,
        })
    elif name == "graph_register_edit":
        return json.dumps({"ok": True, "registered": input_data.get("files", [])})
    elif name == "graph_add_memory":
        return json.dumps({"ok": True, "id": "mem_test_001"})
    else:
        return json.dumps({"error": f"Unknown tool: {name}"})


def execute_tool_live(name: str, input_data: dict, port: int) -> str:
    """Call the actual MCP server via HTTP."""
    import urllib.request

    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {"name": name, "arguments": input_data},
    }
    data = json.dumps(payload).encode()
    req = urllib.request.Request(
        f"http://127.0.0.1:{port}/mcp",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            result = json.loads(resp.read().decode())
            if "result" in result:
                content = result["result"].get("content", [])
                if content and content[0].get("type") == "text":
                    return content[0]["text"]
            return json.dumps(result)
    except Exception as e:
        return json.dumps({"error": str(e)})


# ─── Agent loop ──────────────────────────────────────────────────────────────

def run_agent_test(port: int, use_live_server: bool) -> dict:
    """
    Run an agentic loop using the Anthropic API.
    The agent is instructed to use dual-graph tools.
    Returns a summary of tool calls made.
    """
    client = anthropic.Anthropic()

    system_prompt = """You are a coding assistant with access to dual-graph tools.
You MUST call graph_continue first before doing anything else.
After graph_continue responds, read at least one recommended file using graph_read.
Then report what you found."""

    messages = [
        {
            "role": "user",
            "content": "What does the main entry point of this project do? Use your graph tools to find out.",
        }
    ]

    tool_calls_made = []
    max_iterations = 10

    print("\n" + "=" * 60)
    print("AGENT LOOP - Testing tool calls via Anthropic API")
    print("=" * 60)

    for iteration in range(max_iterations):
        print(f"\n--- Iteration {iteration + 1} ---")

        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            system=system_prompt,
            tools=TOOLS,
            messages=messages,
        )

        print(f"  Stop reason: {response.stop_reason}")
        print(f"  Content blocks: {len(response.content)}")

        # If Claude is done, break
        if response.stop_reason == "end_turn":
            # Extract final text
            for block in response.content:
                if block.type == "text":
                    print(f"\n  Final response: {block.text[:200]}...")
            break

        # Extract tool use blocks
        tool_use_blocks = [b for b in response.content if b.type == "tool_use"]

        if not tool_use_blocks:
            print("  No tool calls, agent is done.")
            break

        # Append assistant's response (includes tool_use blocks)
        messages.append({"role": "assistant", "content": response.content})

        # Execute each tool and collect results
        tool_results = []
        for tool_block in tool_use_blocks:
            tool_name = tool_block.name
            tool_input = tool_block.input

            print(f"  Tool call: {tool_name}({json.dumps(tool_input)[:100]})")
            tool_calls_made.append({"name": tool_name, "input": tool_input})

            # Execute tool
            if use_live_server:
                result = execute_tool_live(tool_name, tool_input, port)
            else:
                result = execute_tool_simulated(tool_name, tool_input)

            print(f"  Result: {result[:120]}...")

            tool_results.append({
                "type": "tool_result",
                "tool_use_id": tool_block.id,
                "content": result,
            })

        # Send tool results back
        messages.append({"role": "user", "content": tool_results})

    return {
        "iterations": iteration + 1,
        "tool_calls": tool_calls_made,
        "tool_names_called": list({tc["name"] for tc in tool_calls_made}),
    }


# ─── Assertions ──────────────────────────────────────────────────────────────

def verify_results(results: dict) -> bool:
    """Verify that the agent called the expected tools."""
    print("\n" + "=" * 60)
    print("TEST RESULTS")
    print("=" * 60)

    tool_names = results["tool_names_called"]
    total_calls = len(results["tool_calls"])

    print(f"\n  Total iterations: {results['iterations']}")
    print(f"  Total tool calls: {total_calls}")
    print(f"  Unique tools called: {tool_names}")

    passed = True
    checks = [
        ("graph_continue called", "graph_continue" in tool_names),
        ("graph_read called", "graph_read" in tool_names),
        ("At least 2 tool calls made", total_calls >= 2),
        ("Agent completed (didn't hit max iterations)", results["iterations"] < 10),
    ]

    print("\n  Checks:")
    for label, ok in checks:
        status = "PASS" if ok else "FAIL"
        print(f"    [{status}] {label}")
        if not ok:
            passed = False

    print(f"\n  {'ALL TESTS PASSED' if passed else 'SOME TESTS FAILED'}")
    return passed


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Test MCP agent tool calling via Anthropic API")
    parser.add_argument("--port", type=int, default=9876, help="Port for MCP server")
    parser.add_argument("--no-server", action="store_true", help="Skip starting MCP server, use simulated responses")
    args = parser.parse_args()

    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("[ERROR] Set ANTHROPIC_API_KEY environment variable")
        sys.exit(1)

    use_live_server = not args.no_server
    server_proc = None

    if use_live_server:
        print(f"[INFO] Starting MCP server on port {args.port}...")
        server_proc = start_mcp_server(args.port)
        if server_proc is None:
            print("[INFO] Falling back to simulated tool responses")
            use_live_server = False

    try:
        results = run_agent_test(args.port, use_live_server)
        passed = verify_results(results)
        sys.exit(0 if passed else 1)
    finally:
        if server_proc:
            server_proc.terminate()
            server_proc.wait(timeout=5)
            print("\n[INFO] MCP server stopped.")


if __name__ == "__main__":
    main()
