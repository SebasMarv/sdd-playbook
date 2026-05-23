#!/usr/bin/env bash
#
# validate.sh — Chequeos estructurales del setup OpenSpec + baseline en un proyecto.
#
# Corre desde la raíz del proyecto:
#   bash /path/a/sdd-toolkit/scripts/validate.sh
#
# No requiere CI. Es un check manual para confirmar que el setup quedó OK
# o detectar drift después de un tiempo de uso.

set -uo pipefail

PROJECT_ROOT="$(pwd)"
FAIL=0
WARN=0

pass() { echo "  [OK]   $1"; }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $1"; WARN=$((WARN+1)); }

echo "=== sdd-toolkit: validate ==="
echo "Project: $PROJECT_ROOT"
echo ""

# 1. Estructura básica de OpenSpec
echo "[Estructura OpenSpec]"
[ -d "$PROJECT_ROOT/openspec" ] && pass "openspec/ existe" || fail "openspec/ no existe"
[ -f "$PROJECT_ROOT/openspec/project.md" ] && pass "openspec/project.md existe" || fail "openspec/project.md falta"
[ -d "$PROJECT_ROOT/openspec/specs" ] && pass "openspec/specs/ existe" || fail "openspec/specs/ falta"
[ -d "$PROJECT_ROOT/openspec/changes" ] && pass "openspec/changes/ existe" || fail "openspec/changes/ falta"

# 2. project.md tiene Architectural Invariants
echo ""
echo "[project.md content]"
if grep -q "## Architectural Invariants" "$PROJECT_ROOT/openspec/project.md" 2>/dev/null; then
  pass "project.md tiene sección 'Architectural Invariants'"

  # Detectar placeholders sin llenar
  if grep -E "\[INVARIANT [0-9N]+" "$PROJECT_ROOT/openspec/project.md" > /dev/null; then
    warn "project.md todavía tiene placeholders [INVARIANT X] sin llenar"
  fi
else
  fail "project.md NO tiene sección 'Architectural Invariants'"
fi

# 3. AGENTS.md presente
echo ""
echo "[AGENTS.md]"
if [ -f "$PROJECT_ROOT/openspec/AGENTS.md" ]; then
  pass "openspec/AGENTS.md existe"
else
  warn "openspec/AGENTS.md falta — agentes no tendrán instrucciones explícitas"
fi

# 4. progress/ presente
echo ""
echo "[progress/]"
[ -d "$PROJECT_ROOT/progress" ] && pass "progress/ existe" || fail "progress/ falta"
[ -f "$PROJECT_ROOT/progress/current.md" ] && pass "progress/current.md existe" || warn "progress/current.md falta"
[ -f "$PROJECT_ROOT/progress/history.md" ] && pass "progress/history.md existe" || warn "progress/history.md falta"

# 5. CLAUDE.md presente
echo ""
echo "[CLAUDE.md]"
[ -f "$PROJECT_ROOT/CLAUDE.md" ] && pass "CLAUDE.md existe en root" || warn "CLAUDE.md no existe (Claude no tendrá pointer)"

# 6. Validar changes activos
echo ""
echo "[Active changes]"
if [ -d "$PROJECT_ROOT/openspec/changes" ]; then
  for change_dir in "$PROJECT_ROOT/openspec/changes"/*/; do
    [ -d "$change_dir" ] || continue
    case "$(basename "$change_dir")" in
      archive) continue ;;
    esac
    name="$(basename "$change_dir")"
    echo "  Change: $name"
    [ -f "$change_dir/proposal.md" ] && pass "  ↳ proposal.md presente" || fail "  ↳ proposal.md falta"
    [ -f "$change_dir/design.md" ] && pass "  ↳ design.md presente" || warn "  ↳ design.md falta"
    [ -f "$change_dir/tasks.md" ] && pass "  ↳ tasks.md presente" || warn "  ↳ tasks.md falta"

    # Validar que design.md tenga sección Verification
    if [ -f "$change_dir/design.md" ]; then
      if grep -q "## Verification" "$change_dir/design.md" 2>/dev/null; then
        pass "  ↳ design.md tiene sección 'Verification'"
      else
        warn "  ↳ design.md NO tiene sección 'Verification' (sin R↔test mapping)"
      fi
    fi

    # Validar que proposal.md tenga sección Architectural Impact
    if [ -f "$change_dir/proposal.md" ]; then
      if grep -q "## Architectural Impact" "$change_dir/proposal.md" 2>/dev/null; then
        pass "  ↳ proposal.md tiene sección 'Architectural Impact'"
      else
        warn "  ↳ proposal.md NO tiene sección 'Architectural Impact'"
      fi
    fi
  done
fi

# 7. Resumen
echo ""
echo "=== Resumen ==="
echo "  Fallos: $FAIL"
echo "  Warnings: $WARN"

if [ $FAIL -gt 0 ]; then
  exit 1
fi

if [ $WARN -gt 0 ]; then
  echo ""
  echo "Setup OK pero con warnings. Revisalos cuando puedas."
fi
exit 0
