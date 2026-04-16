#!/usr/bin/env bash
# =============================================================================
# copilot-onboarding.sh — Guided onboarding for Copilot contributors
# =============================================================================
# Verifies local prerequisites, offers role-based quick starts, and validates
# the first workflow execution. Designed for <15 minute first-time setup.
#
# USAGE:  bash copilot-onboarding.sh [--role <role>] [--check-only]
#
# Roles:  developer  — daily coding with prompts, skills, and chat modes
#         reviewer   — code review workflows and security scanning
#         platform   — asset governance, eval checks, CI workflows
#         all        — full setup with all capabilities
#
# Flags:  --check-only   Run prerequisite checks without interactive setup
# =============================================================================
set -euo pipefail

# ─── Colors and formatting ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No color

pass()  { echo -e "  ${GREEN}✓${NC} $1"; }
fail()  { echo -e "  ${RED}✗${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
info()  { echo -e "  ${BLUE}ℹ${NC} $1"; }
header(){ echo -e "\n${BOLD}── $1 ──${NC}"; }

ERRORS=0
WARNINGS=0
ROLE=""
CHECK_ONLY=false

# ─── Parse arguments ─────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --role)    ROLE="$2"; shift 2 ;;
    --check-only) CHECK_ONLY=true; shift ;;
    -h|--help)
      echo "Usage: bash copilot-onboarding.sh [--role developer|reviewer|platform|all] [--check-only]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   GitHub Copilot — Guided Onboarding             ║"
echo "╚══════════════════════════════════════════════════╝"

# ─── Phase 1: Prerequisites ──────────────────────────────────────────────────
header "Phase 1: Prerequisite checks"

# VS Code
if command -v code &>/dev/null; then
  VSCODE_VERSION=$(code --version 2>/dev/null | head -1)
  pass "VS Code installed (${VSCODE_VERSION})"
else
  fail "VS Code not found — install from https://code.visualstudio.com"
  ERRORS=$((ERRORS + 1))
fi

# GitHub Copilot extension
if command -v code &>/dev/null; then
  if code --list-extensions 2>/dev/null | grep -qi "github.copilot"; then
    pass "GitHub Copilot extension installed"
  else
    fail "GitHub Copilot extension not installed — run: code --install-extension GitHub.copilot"
    ERRORS=$((ERRORS + 1))
  fi

  if code --list-extensions 2>/dev/null | grep -qi "github.copilot-chat"; then
    pass "GitHub Copilot Chat extension installed"
  else
    warn "Copilot Chat extension not found separately — may be bundled with Copilot in newer VS Code"
    WARNINGS=$((WARNINGS + 1))
  fi
fi

# Git
if command -v git &>/dev/null; then
  GIT_VERSION=$(git --version | awk '{print $3}')
  pass "Git installed (${GIT_VERSION})"
else
  fail "Git not found"
  ERRORS=$((ERRORS + 1))
fi

# Node.js (for MCP servers)
if command -v node &>/dev/null; then
  NODE_VERSION=$(node --version)
  pass "Node.js installed (${NODE_VERSION})"
else
  warn "Node.js not found — needed for some MCP tool servers"
  WARNINGS=$((WARNINGS + 1))
fi

# Python (for eval checks)
if command -v python3 &>/dev/null; then
  PY_VERSION=$(python3 --version | awk '{print $2}')
  pass "Python 3 installed (${PY_VERSION})"
else
  warn "Python 3 not found — needed for governance eval checks"
  WARNINGS=$((WARNINGS + 1))
fi

# Workspace files
if [[ -f ".github/copilot-instructions.md" ]]; then
  pass "Team instructions found (.github/copilot-instructions.md)"
else
  fail "Team instructions missing — run: bash copilot-setup.sh"
  ERRORS=$((ERRORS + 1))
fi

if [[ -f ".vscode/settings.json" ]]; then
  pass "VS Code settings found (.vscode/settings.json)"
else
  fail "VS Code settings missing — run: bash copilot-setup.sh"
  ERRORS=$((ERRORS + 1))
fi

if [[ -f ".github/copilot-asset-manifest.json" ]]; then
  pass "Asset manifest found"
else
  warn "Asset manifest missing — governance checks will not run"
  WARNINGS=$((WARNINGS + 1))
fi

if [[ -f ".github/model-compatibility.json" ]]; then
  pass "Model compatibility matrix found"
else
  warn "Model compatibility matrix missing"
  WARNINGS=$((WARNINGS + 1))
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
header "Prerequisite summary"
if [[ $ERRORS -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}All prerequisites met${NC} (${WARNINGS} warning(s))"
else
  echo -e "  ${RED}${BOLD}${ERRORS} prerequisite(s) missing${NC} (${WARNINGS} warning(s))"
  echo "  Fix the issues above before continuing."
  if $CHECK_ONLY; then exit 1; fi
fi

if $CHECK_ONLY; then
  exit 0
fi

# ─── Phase 2: Role selection ─────────────────────────────────────────────────
header "Phase 2: Role-based quick start"

if [[ -z "$ROLE" ]]; then
  echo ""
  echo "  Choose your primary role:"
  echo ""
  echo "    1) developer  — Daily coding: prompts, skills, chat modes"
  echo "    2) reviewer   — Code review and security scanning"
  echo "    3) platform   — Asset governance, eval checks, CI"
  echo "    4) all        — Everything"
  echo ""
  read -rp "  Enter choice [1-4, default=1]: " choice
  case "${choice:-1}" in
    1|developer)  ROLE="developer" ;;
    2|reviewer)   ROLE="reviewer" ;;
    3|platform)   ROLE="platform" ;;
    4|all)        ROLE="all" ;;
    *)            ROLE="developer" ;;
  esac
fi

echo -e "\n  Selected role: ${BOLD}${ROLE}${NC}"

# ─── Phase 3: Role-specific guidance ─────────────────────────────────────────
header "Phase 3: Getting started as ${ROLE}"

case "$ROLE" in
  developer)
    echo ""
    echo "  ${BOLD}Your daily tools:${NC}"
    echo ""
    echo "  Slash commands (type in Copilot Chat):"
    echo "    /review       — Code review with structured feedback"
    echo "    /fix-issue    — Fix a bug from issue description"
    echo "    /deploy       — Pre-deployment checklist"
    echo "    /architect    — System design and trade-off analysis"
    echo ""
    echo "  Chat modes (select from VS Code mode picker):"
    echo "    code-reviewer     — Back-and-forth review conversation"
    echo "    devops-engineer   — Infrastructure and deployment help"
    echo "    architect         — System design sessions"
    echo ""
    echo "  Auto-discovered skills (triggered by context):"
    echo "    helm-upgrade      — Kubernetes deployments"
    echo "    terraform-plan    — Infrastructure changes"
    echo "    debug-eks         — Pod/container debugging"
    echo "    incident-triage   — Production incident response"
    echo ""
    echo "  ${BOLD}Try it now:${NC}"
    echo "    1. Open VS Code in this repository"
    echo "    2. Open Copilot Chat (Ctrl+Shift+I / Cmd+Shift+I)"
    echo "    3. Type: /review and select a file to review"
    echo ""
    ;;
  reviewer)
    echo ""
    echo "  ${BOLD}Your review tools:${NC}"
    echo ""
    echo "  Primary commands:"
    echo "    /review           — Structured code review"
    echo "    /security-scan    — OWASP security audit"
    echo ""
    echo "  Chat modes for extended sessions:"
    echo "    code-reviewer         — Line-by-line review"
    echo "    security-auditor      — Deep security analysis"
    echo ""
    echo "  Model selection for review tasks:"
    echo "    claude-sonnet-4-5     — Standard code review"
    echo "    claude-opus-4-5       — Security audit (most thorough)"
    echo ""
    echo "  ${BOLD}Try it now:${NC}"
    echo "    1. Open VS Code and switch to the security-auditor chat mode"
    echo "    2. Ask: 'Review the copilot-setup.sh for security issues'"
    echo ""
    ;;
  platform)
    echo ""
    echo "  ${BOLD}Your governance tools:${NC}"
    echo ""
    echo "  Eval checks (run locally or via CI):"
    echo "    bash .github/eval/checks/naming.sh        — Naming conventions"
    echo "    bash .github/eval/checks/frontmatter.sh   — Required frontmatter"
    echo "    bash .github/eval/checks/model-refs.sh    — Model references"
    echo "    bash .github/eval/checks/manifest-sync.sh — Manifest ↔ filesystem"
    echo "    bash .github/eval/checks/governance.sh    — Governance metadata"
    echo ""
    echo "  Policy checks (warn-only mode):"
    echo "    bash .github/hooks/scripts/destructive-commands.sh"
    echo "    bash .github/hooks/scripts/broad-permissions.sh"
    echo "    bash .github/hooks/scripts/secret-hygiene.sh"
    echo ""
    echo "  Key files:"
    echo "    .github/copilot-asset-manifest.json   — Asset registry"
    echo "    .github/model-compatibility.json       — Model matrix"
    echo "    .github/GOVERNANCE.md                  — Checklist for new assets"
    echo "    .github/copilot-mcp-profiles.json      — MCP security profiles"
    echo ""
    echo "  ${BOLD}Try it now:${NC}"
    echo "    1. Run all eval checks:"
    echo "       for c in naming frontmatter model-refs manifest-sync governance; do"
    echo "         bash .github/eval/checks/\$c.sh"
    echo "       done"
    echo ""
    ;;
  all)
    echo ""
    echo "  ${BOLD}Full capability overview:${NC}"
    echo ""
    echo "  See COPILOT-CHEATSHEET.md for the complete reference."
    echo "  See .github/GOVERNANCE.md for asset governance rules."
    echo ""
    echo "  Quick validation — run all checks:"
    echo "    for c in naming frontmatter model-refs manifest-sync governance; do"
    echo "      bash .github/eval/checks/\$c.sh"
    echo "    done"
    echo ""
    echo "  ${BOLD}Key commands to know:${NC}"
    echo "    /review, /fix-issue, /deploy, /architect, /security-scan"
    echo ""
    echo "  ${BOLD}Key chat modes:${NC}"
    echo "    code-reviewer, security-auditor, architect, devops-engineer"
    echo ""
    ;;
esac

# ─── Phase 4: Validation ─────────────────────────────────────────────────────
header "Phase 4: Validation"

if [[ "$ROLE" == "platform" || "$ROLE" == "all" ]]; then
  echo "  Running eval check suite..."
  echo ""
  ALL_PASS=true
  for check in naming frontmatter model-refs manifest-sync governance; do
    if bash ".github/eval/checks/$check.sh" > /dev/null 2>&1; then
      pass "$check"
    else
      fail "$check"
      ALL_PASS=false
    fi
  done
  echo ""
  if $ALL_PASS; then
    echo -e "  ${GREEN}${BOLD}All eval checks pass — governance is healthy${NC}"
  else
    echo -e "  ${YELLOW}Some checks failed — review output above${NC}"
  fi
fi

if [[ "$ROLE" == "developer" || "$ROLE" == "reviewer" || "$ROLE" == "all" ]]; then
  # Verify key files exist for the role
  ROLE_READY=true
  if [[ -d ".github/prompts" ]]; then
    PROMPT_COUNT=$(find .github/prompts -name "*.prompt.md" 2>/dev/null | wc -l | tr -d ' ')
    pass "${PROMPT_COUNT} prompt(s) available"
  else
    fail "No prompts directory"
    ROLE_READY=false
  fi

  if [[ -d ".github/chatmodes" ]]; then
    MODE_COUNT=$(find .github/chatmodes -name "*.chatmode.md" 2>/dev/null | wc -l | tr -d ' ')
    pass "${MODE_COUNT} chat mode(s) available"
  else
    warn "No chatmodes directory"
  fi

  if [[ -d ".github/skills" ]]; then
    SKILL_COUNT=$(find .github/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    pass "${SKILL_COUNT} skill(s) available"
  else
    warn "No skills directory"
  fi

  if $ROLE_READY; then
    echo -e "\n  ${GREEN}${BOLD}Ready to use Copilot — open VS Code and try a slash command${NC}"
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Onboarding complete. Next steps:"
echo "    • Read COPILOT-CHEATSHEET.md for the full reference"
echo "    • Read .github/GOVERNANCE.md before adding new assets"
echo "    • Run copilot-onboarding.sh --check-only anytime to verify"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
