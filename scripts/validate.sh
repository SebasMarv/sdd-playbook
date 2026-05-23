#!/usr/bin/env bash
#
# validate.sh — Chequeos estructurales del setup OpenSpec + playbook
# extensions en un proyecto.
#
# Corre desde la raíz del proyecto destino:
#   bash /path/a/sdd-playbook/scripts/validate.sh
#
# Check manual, sin CI. Útil tras setup + en cualquier momento para
# detectar drift.

set -uo pipefail

PROJECT_ROOT="$(pwd)"
FAIL=0
WARN=0

pass() { echo "  [OK]   $1"; }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $1"; WARN=$((WARN+1)); }

echo "=== sdd-playbook: validate ==="
echo "Project: $PROJECT_ROOT"
echo ""

# ─── 1. Estructura OpenSpec ─────────────────────────────────────────────
echo "[Estructura OpenSpec]"
[ -d "$PROJECT_ROOT/openspec" ] && pass "openspec/ existe" || fail "openspec/ no existe"
[ -f "$PROJECT_ROOT/openspec/config.yaml" ] && pass "openspec/config.yaml existe" || fail "openspec/config.yaml falta"
[ -d "$PROJECT_ROOT/openspec/specs" ] && pass "openspec/specs/ existe" || fail "openspec/specs/ falta"
[ -d "$PROJECT_ROOT/openspec/changes" ] && pass "openspec/changes/ existe" || fail "openspec/changes/ falta"

# ─── 2. Claude integration (OpenSpec instala 4 commands + 4 skills) ─────
echo ""
echo "[Claude integration]"
[ -d "$PROJECT_ROOT/.claude/commands/opsx" ] && pass ".claude/commands/opsx/ existe" || warn ".claude/commands/opsx/ falta (ejecutaste 'openspec init --tools claude'?)"
for cmd in propose apply archive explore; do
  [ -f "$PROJECT_ROOT/.claude/commands/opsx/$cmd.md" ] && pass "  /opsx:$cmd command" || warn "  /opsx:$cmd command FALTA"
done

# ─── 3. config.yaml content (las 7 extensiones del playbook) ────────────
echo ""
echo "[openspec/config.yaml content]"
if [ -f "$PROJECT_ROOT/openspec/config.yaml" ]; then
  # context con Architectural Invariants
  if grep -q "Architectural Invariants" "$PROJECT_ROOT/openspec/config.yaml"; then
    pass "config.yaml#context tiene 'Architectural Invariants'"
    if grep -qE "\[INVARIANT [0-9N]+" "$PROJECT_ROOT/openspec/config.yaml"; then
      warn "config.yaml#context tiene placeholders [INVARIANT X] sin llenar"
    fi
  else
    warn "config.yaml#context NO menciona Architectural Invariants (¿está vacío?)"
  fi

  # rules.proposal
  if grep -q "proposal:" "$PROJECT_ROOT/openspec/config.yaml"; then
    pass "config.yaml#rules.proposal definido"
    grep -q "User Stories" "$PROJECT_ROOT/openspec/config.yaml" && pass "  ↳ extension 1: User Stories" || warn "  ↳ extension 1 (User Stories) NO codificada"
    grep -q "Pre-propose analysis" "$PROJECT_ROOT/openspec/config.yaml" && pass "  ↳ extension 4: Pre-propose analysis" || warn "  ↳ extension 4 NO codificada"
  else
    fail "config.yaml#rules.proposal falta"
  fi

  # rules.specs
  grep -q "specs:" "$PROJECT_ROOT/openspec/config.yaml" && pass "config.yaml#rules.specs (EARS Scenarios)" || warn "config.yaml#rules.specs FALTA (extension 2 — EARS)"

  # rules.design Verification trazable
  grep -q "User Story → Scenarios cubiertos → Test" "$PROJECT_ROOT/openspec/config.yaml" && pass "config.yaml#rules.design (Verification trazable)" || warn "config.yaml#rules.design SIN Verification trazable (extension 3)"

  # rules.tasks post-apply review
  grep -q "post-apply conflict review" "$PROJECT_ROOT/openspec/config.yaml" && pass "config.yaml#rules.tasks (Post-apply review)" || warn "config.yaml#rules.tasks SIN Post-apply review (extension 6)"

  # preferences session_level
  grep -q "session_level_default" "$PROJECT_ROOT/openspec/config.yaml" && pass "config.yaml#preferences (session_level)" || warn "config.yaml#preferences SIN session_level (extension 5)"
fi

# ─── 4. progress/ ───────────────────────────────────────────────────────
echo ""
echo "[progress/]"
[ -d "$PROJECT_ROOT/progress" ] && pass "progress/ existe" || fail "progress/ falta"
[ -f "$PROJECT_ROOT/progress/current.md" ] && pass "progress/current.md existe" || warn "progress/current.md falta"
[ -f "$PROJECT_ROOT/progress/history.md" ] && pass "progress/history.md existe" || warn "progress/history.md falta"

# ─── 5. .local/ + .gitignore ────────────────────────────────────────────
echo ""
echo "[.local/ + gitignore]"
[ -d "$PROJECT_ROOT/.local" ] && pass ".local/ existe" || warn ".local/ no existe (¿corriste setup?)"
[ -f "$PROJECT_ROOT/.local/credentials.md" ] && pass ".local/credentials.md existe" || warn ".local/credentials.md falta"
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  grep -qxF '.local/' "$PROJECT_ROOT/.gitignore" && pass ".gitignore incluye .local/" || fail ".gitignore NO incluye .local/ (RIESGO: secrets pueden commitearse)"
  grep -qxF 'commit_msg.txt' "$PROJECT_ROOT/.gitignore" && pass ".gitignore incluye commit_msg.txt" || warn ".gitignore NO incluye commit_msg.txt"
fi

# ─── 6. CLAUDE.md ───────────────────────────────────────────────────────
echo ""
echo "[CLAUDE.md]"
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  pass "CLAUDE.md existe en root"
  grep -q "openspec/config.yaml" "$PROJECT_ROOT/CLAUDE.md" && pass "  ↳ apunta a openspec/config.yaml (source of truth)" || warn "  ↳ NO menciona openspec/config.yaml — podría ser CLAUDE.md viejo"
  grep -q "Session Start Protocol" "$PROJECT_ROOT/CLAUDE.md" && pass "  ↳ tiene Session Start Protocol (extension 5)" || warn "  ↳ NO tiene Session Start Protocol"
else
  warn "CLAUDE.md no existe (Claude no tendrá pointer)"
fi

# ─── 7. Active changes — validar estructura ─────────────────────────────
echo ""
echo "[Active changes en openspec/changes/]"
if [ -d "$PROJECT_ROOT/openspec/changes" ]; then
  HAS_ACTIVE=0
  for change_dir in "$PROJECT_ROOT/openspec/changes"/*/; do
    [ -d "$change_dir" ] || continue
    case "$(basename "$change_dir")" in
      archive) continue ;;
    esac
    HAS_ACTIVE=1
    name="$(basename "$change_dir")"
    echo "  Change: $name"
    [ -f "$change_dir/proposal.md" ] && pass "  ↳ proposal.md presente" || fail "  ↳ proposal.md falta"
    [ -f "$change_dir/design.md" ] && pass "  ↳ design.md presente" || warn "  ↳ design.md falta"
    [ -f "$change_dir/tasks.md" ] && pass "  ↳ tasks.md presente" || warn "  ↳ tasks.md falta"
    [ -d "$change_dir/specs" ] && pass "  ↳ specs/ deltas presentes" || warn "  ↳ specs/ deltas faltan"

    # Validar secciones obligatorias de las extensiones
    if [ -f "$change_dir/proposal.md" ]; then
      grep -q "## Pre-propose analysis" "$change_dir/proposal.md" && pass "  ↳ proposal.md tiene Pre-propose analysis" || warn "  ↳ proposal.md SIN Pre-propose analysis (extension 4)"
      grep -q "## User Stories" "$change_dir/proposal.md" && pass "  ↳ proposal.md tiene User Stories" || warn "  ↳ proposal.md SIN User Stories (extension 1)"
      grep -q "## Architectural Impact" "$change_dir/proposal.md" && pass "  ↳ proposal.md tiene Architectural Impact" || warn "  ↳ proposal.md SIN Architectural Impact"
    fi
    if [ -f "$change_dir/design.md" ]; then
      grep -q "## Verification" "$change_dir/design.md" && pass "  ↳ design.md tiene Verification" || warn "  ↳ design.md SIN Verification (extension 3)"
    fi
  done
  [ $HAS_ACTIVE -eq 0 ] && echo "  (ningún change activo)"
fi

# ─── 8. Resumen ─────────────────────────────────────────────────────────
echo ""
echo "=== Resumen ==="
echo "  Fallos: $FAIL"
echo "  Warnings: $WARN"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "Setup INCOMPLETO. Revisar fallos arriba."
  exit 1
fi

if [ $WARN -gt 0 ]; then
  echo ""
  echo "Setup OK pero con warnings. Revisalos cuando puedas."
fi
exit 0
