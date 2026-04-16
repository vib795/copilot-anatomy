#!/usr/bin/env bash
# =============================================================================
# copilot-discover.sh — Find the right Copilot asset for a task
# =============================================================================
# Maps common tasks to prompts, skills, agents, and chat modes in ≤3 steps.
#
# USAGE:
#   bash copilot-discover.sh                    # Interactive menu
#   bash copilot-discover.sh search <keyword>   # Keyword search
#   bash copilot-discover.sh list               # List all assets by type
# =============================================================================
set -euo pipefail

BOLD='\033[1m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ─── Asset index (task → asset mapping) ──────────────────────────────────────
# Format: "keyword|type|name|description"
TASK_INDEX=(
  "review|prompt|/review|Code review with structured feedback"
  "code review|prompt|/review|Code review with structured feedback"
  "pr review|prompt|/review|Code review with structured feedback"
  "bug|prompt|/fix-issue|Fix a bug from issue description"
  "fix|prompt|/fix-issue|Fix a bug from issue description"
  "issue|prompt|/fix-issue|Fix a bug from issue description"
  "deploy|prompt|/deploy|Pre-deployment checklist"
  "deployment|prompt|/deploy|Pre-deployment checklist"
  "release|prompt|/deploy|Pre-deployment checklist"
  "architecture|prompt|/architect|System design and trade-off analysis"
  "design|prompt|/architect|System design and trade-off analysis"
  "trade-off|prompt|/architect|System design and trade-off analysis"
  "security|prompt|/security-scan|OWASP security audit"
  "vulnerability|prompt|/security-scan|OWASP security audit"
  "owasp|prompt|/security-scan|OWASP security audit"
  "pentest|prompt|/security-scan|OWASP security audit"
  "helm|skill|helm-upgrade|Deploy, upgrade, or roll back Kubernetes services"
  "kubernetes|skill|helm-upgrade|Deploy, upgrade, or roll back Kubernetes services"
  "k8s|skill|helm-upgrade|Deploy, upgrade, or roll back Kubernetes services"
  "pod|skill|debug-eks|Debug crashing or stuck pods in EKS"
  "eks|skill|debug-eks|Debug crashing or stuck pods in EKS"
  "crashloop|skill|debug-eks|Debug crashing or stuck pods in EKS"
  "oomkilled|skill|debug-eks|Debug crashing or stuck pods in EKS"
  "terraform|skill|terraform-plan|Plan, apply, or review Terraform changes"
  "tofu|skill|terraform-plan|Plan, apply, or review Terraform changes"
  "infrastructure|skill|terraform-plan|Plan, apply, or review Terraform changes"
  "incident|skill|incident-triage|Production incident triage and postmortem"
  "outage|skill|incident-triage|Production incident triage and postmortem"
  "postmortem|skill|incident-triage|Production incident triage and postmortem"
  "plan|agent|plan|Create implementation plans from feature requests"
  "implement|agent|implement|Execute plans step by step with code changes"
  "code|agent|implement|Execute plans step by step with code changes"
  "review agent|agent|review|Thorough code review and PR description"
  "chat|chatmode|code-reviewer|Back-and-forth code review conversation"
  "conversation|chatmode|code-reviewer|Back-and-forth code review conversation"
  "security chat|chatmode|security-auditor|Deep security analysis session"
  "audit|chatmode|security-auditor|Deep security analysis session"
  "devops|chatmode|devops-engineer|Infrastructure and deployment help"
  "ops|chatmode|devops-engineer|Infrastructure and deployment help"
  "architect chat|chatmode|architect|System design conversation session"
  "codebase|chatmode|large-codebase-reader|Read and understand large codebases"
  "large file|chatmode|large-codebase-reader|Read and understand large codebases"
  "brainstorm|skill|brainstorming|Explore approaches before implementing"
  "think through|skill|brainstorming|Explore approaches before implementing"
  "debug|skill|gstack-investigate|Systematic debugging with root cause analysis"
  "root cause|skill|gstack-investigate|Systematic debugging with root cause analysis"
  "ship|skill|gstack-ship|Ship workflow: tests, review, PR creation"
  "pr|skill|gstack-ship|Ship workflow: tests, review, PR creation"
  "push|skill|gstack-ship|Ship workflow: tests, review, PR creation"
)

# ─── Functions ────────────────────────────────────────────────────────────────

search_assets() {
  local query
  query=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  local found=0
  local seen=""

  echo -e "\n${BOLD}Results for '${1}':${NC}\n"

  for entry in "${TASK_INDEX[@]}"; do
    IFS='|' read -r keyword type name desc <<< "$entry"
    local kw_lower desc_lower name_lower
    kw_lower=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
    desc_lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')
    name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    if [[ "$kw_lower" == *"$query"* || "$desc_lower" == *"$query"* || "$name_lower" == *"$query"* ]]; then
      # Deduplicate by name
      if echo "$seen" | grep -qF "|${name}|"; then
        continue
      fi
      seen="${seen}|${name}|"
      case "$type" in
        prompt)   echo -e "  ${GREEN}[prompt]${NC}    ${BOLD}${name}${NC} — ${desc}" ;;
        skill)    echo -e "  ${BLUE}[skill]${NC}     ${BOLD}${name}${NC} — ${desc}" ;;
        agent)    echo -e "  ${YELLOW}[agent]${NC}     ${BOLD}${name}${NC} — ${desc}" ;;
        chatmode) echo -e "  ${BOLD}[chatmode]${NC}  ${BOLD}${name}${NC} — ${desc}" ;;
      esac
      found=$((found + 1))
    fi
  done

  if [[ $found -eq 0 ]]; then
    echo "  No matches found. Try a broader keyword or run: bash copilot-discover.sh list"
  else
    echo -e "\n  ${found} result(s) found"
  fi
}

list_assets() {
  echo -e "\n${BOLD}All available Copilot assets:${NC}"

  for asset_type in prompt skill agent chatmode; do
    case "$asset_type" in
      prompt)   echo -e "\n  ${GREEN}${BOLD}Prompts (slash commands):${NC}" ;;
      skill)    echo -e "\n  ${BLUE}${BOLD}Skills (auto-discovered):${NC}" ;;
      agent)    echo -e "\n  ${YELLOW}${BOLD}Agents (autonomous workflows):${NC}" ;;
      chatmode) echo -e "\n  ${BOLD}Chat modes (persona sessions):${NC}" ;;
    esac

    local listed=""
    for entry in "${TASK_INDEX[@]}"; do
      IFS='|' read -r keyword type name desc <<< "$entry"
      if [[ "$type" == "$asset_type" ]]; then
        if echo "$listed" | grep -qF "|${name}|"; then
          continue
        fi
        listed="${listed}|${name}|"
        echo "    ${name} — ${desc}"
      fi
    done
  done
  echo ""
}

interactive_menu() {
  echo -e "\n${BOLD}What do you need help with?${NC}\n"
  echo "  1) Write or review code"
  echo "  2) Deploy or release"
  echo "  3) Debug a problem"
  echo "  4) Security and compliance"
  echo "  5) Architecture and planning"
  echo "  6) Infrastructure (Terraform, Kubernetes)"
  echo "  7) Production incident"
  echo "  8) Search by keyword"
  echo ""
  read -rp "  Enter choice [1-8]: " choice

  case "$choice" in
    1)
      echo -e "\n${BOLD}Code writing and review:${NC}\n"
      echo -e "  ${GREEN}/review${NC}              — Quick code review (type in chat)"
      echo -e "  ${GREEN}/fix-issue${NC}           — Fix a bug from issue description"
      echo -e "  ${YELLOW}implement agent${NC}      — Full implementation from a plan"
      echo -e "  ${BOLD}code-reviewer mode${NC}  — Extended review conversation"
      echo ""
      echo "  Model tip: claude-sonnet-4-5 for code gen, claude-opus-4-5 for thorough review"
      ;;
    2)
      echo -e "\n${BOLD}Deployment and release:${NC}\n"
      echo -e "  ${GREEN}/deploy${NC}              — Pre-deployment checklist"
      echo -e "  ${BLUE}helm-upgrade skill${NC}  — Kubernetes Helm deployments"
      echo -e "  ${BLUE}gstack-ship skill${NC}   — Full ship workflow (tests → PR)"
      echo -e "  ${BOLD}devops-engineer mode${NC} — Interactive deployment help"
      echo ""
      echo "  Model tip: gpt-4.1 for fast CLI output"
      ;;
    3)
      echo -e "\n${BOLD}Debugging:${NC}\n"
      echo -e "  ${BLUE}debug-eks skill${NC}         — Pod/container issues in EKS"
      echo -e "  ${BLUE}gstack-investigate skill${NC} — Root cause analysis"
      echo -e "  ${GREEN}/fix-issue${NC}               — Fix from bug description"
      echo ""
      echo "  Model tip: claude-sonnet-4-5 for targeted fixes"
      ;;
    4)
      echo -e "\n${BOLD}Security and compliance:${NC}\n"
      echo -e "  ${GREEN}/security-scan${NC}           — OWASP security audit"
      echo -e "  ${BLUE}gstack-cso skill${NC}         — Full security officer review"
      echo -e "  ${BOLD}security-auditor mode${NC}    — Deep security conversation"
      echo ""
      echo "  Model tip: claude-opus-4-5 for maximum thoroughness"
      ;;
    5)
      echo -e "\n${BOLD}Architecture and planning:${NC}\n"
      echo -e "  ${GREEN}/architect${NC}               — System design analysis"
      echo -e "  ${YELLOW}plan agent${NC}               — Structured implementation plan"
      echo -e "  ${BLUE}brainstorming skill${NC}      — Explore approaches first"
      echo -e "  ${BOLD}architect mode${NC}           — Extended design conversation"
      echo ""
      echo "  Model tip: o3 for deep reasoning, gemini-2.5-pro for large codebases"
      ;;
    6)
      echo -e "\n${BOLD}Infrastructure:${NC}\n"
      echo -e "  ${BLUE}terraform-plan skill${NC}     — Terraform/OpenTofu changes"
      echo -e "  ${BLUE}helm-upgrade skill${NC}       — Kubernetes Helm operations"
      echo -e "  ${BLUE}debug-eks skill${NC}          — EKS pod debugging"
      echo -e "  ${BOLD}devops-engineer mode${NC}     — Infrastructure conversation"
      echo ""
      echo "  Model tip: gpt-4.1 for DevOps commands"
      ;;
    7)
      echo -e "\n${BOLD}Production incident:${NC}\n"
      echo -e "  ${BLUE}incident-triage skill${NC}    — Structured triage + postmortem"
      echo -e "  ${BLUE}debug-eks skill${NC}          — Container/pod issues"
      echo -e "  ${BOLD}devops-engineer mode${NC}     — Quick infrastructure help"
      echo ""
      echo "  Start with: incident-triage skill (auto-detected by context)"
      ;;
    8)
      echo ""
      read -rp "  Enter search keyword: " keyword
      search_assets "$keyword"
      ;;
    *)
      echo "  Invalid choice"
      ;;
  esac
  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
case "${1:-}" in
  search)
    if [[ -z "${2:-}" ]]; then
      echo "Usage: bash copilot-discover.sh search <keyword>"
      exit 1
    fi
    search_assets "$2"
    ;;
  list)
    list_assets
    ;;
  *)
    interactive_menu
    ;;
esac
