#!/usr/bin/env bash
#
# setup-existing-project.sh — Adopta OpenSpec en un proyecto YA EXISTENTE (brownfield).
#
# Misma mecánica que setup-new-project.sh, pero:
#   - Advierte sobre el primer sprint de documentación de capabilities actuales.
#   - Sugiere un punto de partida para seedear openspec/specs/.
#
# Uso (desde la raíz del proyecto destino):
#   bash /path/a/sdd-toolkit/scripts/setup-existing-project.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Delegamos en setup-new-project.sh para no duplicar lógica
echo "=== Reusando setup-new-project.sh como base..."
bash "$SCRIPT_DIR/setup-new-project.sh"

PROJECT_ROOT="$(pwd)"

echo ""
echo "=== Modo BROWNFIELD: pasos adicionales ==="
echo ""
echo "Este es un proyecto existente. ANTES de proponer cambios nuevos,"
echo "tu primer trabajo es documentar las capabilities actuales en"
echo "openspec/specs/<capability>/spec.md para que reflejen el estado REAL"
echo "del sistema hoy."
echo ""
echo "Sugerencias para arrancar:"
echo ""
echo "  1. Listá los módulos top-level de tu repo:"
echo "     ls backend/internal/  o  ls src/modules/"
echo ""
echo "  2. Por cada módulo grande, creá openspec/specs/<modulo>/spec.md"
echo "     describiendo qué hace HOY (no qué debería hacer)."
echo ""
echo "  3. Si hay docs/ o wiki/ con info de arquitectura, migrá lo útil a"
echo "     openspec/project.md (Architectural Invariants) y openspec/specs/."
echo ""
echo "  4. Inicializá progress/history.md con:"
echo "     '## YYYY-MM-DD — adopted sdd-toolkit'"
echo ""

# Pregunta opcional: ¿inicializar specs/ a partir de subdirectorios comunes?
read -p "¿Querés que cree carpetas vacías en openspec/specs/ para módulos detectados? (yes/no): " do_scaffold

if [ "$do_scaffold" = "yes" ]; then
  echo ""
  echo "Buscando módulos típicos..."

  # Heurística simple: subcarpetas en backend/internal/ o src/modules/
  CANDIDATE_DIRS=()
  for parent in "backend/internal" "src/modules" "internal" "src"; do
    if [ -d "$PROJECT_ROOT/$parent" ]; then
      while IFS= read -r dir; do
        CANDIDATE_DIRS+=("$(basename "$dir")")
      done < <(find "$PROJECT_ROOT/$parent" -mindepth 1 -maxdepth 1 -type d)
    fi
  done

  if [ ${#CANDIDATE_DIRS[@]} -eq 0 ]; then
    echo "  No se detectaron módulos típicos. Creá las carpetas a mano según tu estructura."
  else
    echo "  Detectados: ${CANDIDATE_DIRS[*]}"
    for mod in "${CANDIDATE_DIRS[@]}"; do
      # Skip carpetas no-relevantes
      case "$mod" in
        shared|common|utils|lib|tmp|bin|vendor|node_modules) continue ;;
      esac
      mkdir -p "$PROJECT_ROOT/openspec/specs/$mod"
      cat > "$PROJECT_ROOT/openspec/specs/$mod/spec.md" <<EOF
# Capability: $mod

**Status:** documenting (brownfield seed) | **Updated:** $(date +%Y-%m-%d)

## Purpose

[Qué hace este módulo HOY. Lenguaje de negocio.]

## Current behavior

[Describir comportamiento actual. Lo que ves en el código.]

## Known limitations

[Cosas que no funcionan, bugs conocidos, deuda técnica.]

## External dependencies

[Sistemas externos con los que habla este módulo.]
EOF
      echo "    creado openspec/specs/$mod/spec.md (placeholder)"
    done
  fi
fi

echo ""
echo "=== Done. Tu primer sprint con SDD: completar openspec/specs/ ==="
echo ""
