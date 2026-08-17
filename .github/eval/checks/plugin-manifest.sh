#!/usr/bin/env bash
# =============================================================================
# plugin-manifest.sh — Validate the Agent Plugins 1.0 package
# =============================================================================
# The repo ships .github/ as an Agent Plugin. The spec's root manifest is a
# CLOSED object: adding a convenience key like "hooks" or "mcpServers" at the
# top level makes the package invalid, and clients reject it silently. This
# check catches that before it reaches a marketplace.
#
# Validates:
#   1. plugin.json parses and declares the 1.0.0 $schema
#   2. Only spec-permitted top-level fields are present
#   3. `name` matches the spec pattern (lowercase alnum, hyphen, period; 1-64)
#   4. Every skills/*/ directory contains a SKILL.md
#   5. Each SKILL.md `name` matches its parent directory
#   6. mcp.json (if present) parses, declares mcpServers, and uses valid
#      server types with the fields those types require
#   7. ${PLUGIN_ROOT}/${PLUGIN_DATA} placeholders are not used in `command`
#
# USAGE: bash .github/eval/checks/plugin-manifest.sh [plugin-root]
# EXIT:  0 = valid, 1 = spec violations found
# =============================================================================
set -euo pipefail

ROOT="${1:-.github}"

if [[ ! -f "${ROOT}/plugin.json" ]]; then
  echo "── No plugin.json at ${ROOT} — skipping Agent Plugins check ──"
  exit 0
fi

echo "── Validating Agent Plugins 1.0 package at ${ROOT} ──"

python3 - "$ROOT" <<'PY'
import json, os, re, sys

root = sys.argv[1]
errors = 0
warnings = 0

def fail(msg):
    global errors
    print(f"FAIL: {msg}")
    errors += 1

def warn(msg):
    global warnings
    print(f"WARN: {msg}")
    warnings += 1

# ── 1. plugin.json parses ────────────────────────────────────────────────────
plugin_path = os.path.join(root, "plugin.json")
try:
    with open(plugin_path) as f:
        plugin = json.load(f)
except json.JSONDecodeError as e:
    fail(f"{plugin_path} — invalid JSON: {e}")
    sys.exit(1)

schema = plugin.get("$schema", "")
if "agent-plugins.org/schemas/1.0.0" not in schema:
    warn(f"{plugin_path} — $schema is '{schema}', expected the 1.0.0 plugin schema")

# ── 2. closed top-level field set ────────────────────────────────────────────
PERMITTED = {
    "$schema", "name", "version", "description", "author",
    "homepage", "repository", "license", "keywords", "extensions",
}
extra = set(plugin) - PERMITTED
if extra:
    fail(
        f"{plugin_path} — non-permitted top-level field(s): {', '.join(sorted(extra))}. "
        "The root manifest is closed; client-specific data belongs under "
        "extensions[\"<reverse.domain>\"]."
    )

# ── 3. name pattern ──────────────────────────────────────────────────────────
name = plugin.get("name")
if not name:
    fail(f"{plugin_path} — missing required field 'name'")
elif not re.fullmatch(r"[a-z0-9.-]{1,64}", name):
    fail(
        f"{plugin_path} — name '{name}' must be 1-64 chars of lowercase "
        "letters, digits, hyphens, or periods"
    )

# ── 4/5. skills ──────────────────────────────────────────────────────────────
skills_dir = os.path.join(root, "skills")
skill_count = 0
if os.path.isdir(skills_dir):
    for entry in sorted(os.listdir(skills_dir)):
        d = os.path.join(skills_dir, entry)
        if not os.path.isdir(d):
            continue
        skill_md = os.path.join(d, "SKILL.md")
        if not os.path.isfile(skill_md):
            warn(f"{d} — directory has no SKILL.md, so it is not a discoverable skill")
            continue
        skill_count += 1
        with open(skill_md, encoding="utf-8") as f:
            head = f.read(4096)
        if not re.fullmatch(r"[a-z0-9-]{1,64}", entry):
            warn(
                f"{d} — skill name must be 1-64 chars of lowercase letters, "
                "digits, or hyphens. Renaming changes the /command users type, "
                "so this is a warning rather than a hard failure."
            )
        m = re.search(r"^name:\s*(.+?)\s*$", head, re.M)
        if not m:
            fail(f"{skill_md} — missing required frontmatter field 'name'")
        elif m.group(1).strip().strip('"\'') != entry:
            fail(
                f"{skill_md} — frontmatter name '{m.group(1).strip()}' "
                f"does not match its directory '{entry}'"
            )
        if not re.search(r"^description:\s*\S", head, re.M):
            fail(f"{skill_md} — missing required frontmatter field 'description'")
else:
    warn(f"{skills_dir} — no skills/ directory; the plugin exports no portable skills")

# ── 6/7. mcp.json ────────────────────────────────────────────────────────────
mcp_path = os.path.join(root, "mcp.json")
server_count = 0
if os.path.isfile(mcp_path):
    try:
        with open(mcp_path) as f:
            mcp = json.load(f)
    except json.JSONDecodeError as e:
        fail(f"{mcp_path} — invalid JSON: {e}")
        mcp = None

    if mcp is not None:
        servers = mcp.get("mcpServers")
        if not isinstance(servers, dict):
            fail(f"{mcp_path} — missing required 'mcpServers' object")
        else:
            for sname, cfg in servers.items():
                server_count += 1
                stype = cfg.get("type")
                if stype == "stdio":
                    if not cfg.get("command"):
                        fail(f"{mcp_path}:{sname} — stdio server requires 'command'")
                    elif "${" in str(cfg["command"]):
                        fail(
                            f"{mcp_path}:{sname} — placeholders do not expand in "
                            "'command'; use them only in args, env, or cwd"
                        )
                elif stype in ("streamable-http", "sse"):
                    url = cfg.get("url", "")
                    if not url.startswith(("http://", "https://")):
                        fail(f"{mcp_path}:{sname} — {stype} server requires an absolute http(s) 'url'")
                else:
                    fail(
                        f"{mcp_path}:{sname} — type '{stype}' is not one of "
                        "stdio, streamable-http, sse"
                    )
                if "tools" in cfg:
                    warn(
                        f"{mcp_path}:{sname} — 'tools' is a Copilot cloud-agent field, "
                        "not part of the portable schema"
                    )

print()
print(f"Plugin '{name}' — {skill_count} skill(s), {server_count} MCP server(s)")
if errors:
    print(f"FAIL: {errors} spec violation(s), {warnings} warning(s)")
    sys.exit(1)
if warnings:
    print(f"PASS (with warnings): {warnings} warning(s)")
    sys.exit(0)
print("PASS: Agent Plugins 1.0 package is valid")
PY
