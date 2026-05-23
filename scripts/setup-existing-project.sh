#!/usr/bin/env bash
#
# setup-existing-project.sh — Adopta OpenSpec en un proyecto YA EXISTENTE
# (brownfield). Misma mecánica que setup-new + advertencias sobre primer
# sprint de documentación de capabilities actuales.
#
# Uso (desde la raíz del proyecto destino):
#   bash /path/a/sdd-playbook/scripts/setup-existing-project.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Delegamos en setup-new-project.sh para no duplicar lógica
echo "=== Reusando setup-new-project.sh como base..."
bash "$SCRIPT_DIR/setup-new-project.sh"

PROJECT_ROOT="$(pwd)"

echo ""
echo "============================================================"
echo "=== Modo BROWNFIELD: pasos adicionales ==="
echo "============================================================"
echo ""
echo "Este es un proyecto EXISTENTE. ANTES de proponer cambios nuevos,"
echo "tu primer trabajo (1 sprint dedicado) es documentar las capabilities"
echo "actuales en openspec/specs/<capability>/spec.md para que reflejen el"
echo "estado REAL del sistema hoy."
echo ""
echo "Sugerencias para arrancar:"
echo ""
echo "  1. Listá los módulos top-level de tu repo:"
echo "       ls backend/internal/  o  ls src/modules/"
echo ""
echo "  2. Por cada módulo grande, creá openspec/specs/<modulo>/spec.md"
echo "     describiendo qué hace HOY (no qué debería hacer)."
echo "     Usar formato OpenSpec: ### Requirement + #### Scenario WHEN/THEN."
echo ""
echo "  3. Si hay docs/ o wiki/ con info arquitectónica, migrá las invariants"
echo "     a openspec/config.yaml#context y los detalles operacionales del"
echo "     sistema a openspec/specs/<capability>/."
echo ""
echo "  4. Inicializá progress/history.md con la primera entrada:"
echo "     '## YYYY-MM-DD — adopted sdd-playbook'"
echo ""

# Pregunta opcional: ¿inicializar specs/ con scaffolding desde subdirectorios comunes?
read -p "¿Querés que cree carpetas placeholder en openspec/specs/ para módulos detectados? (yes/no): " do_scaffold

if [ "$do_scaffold" = "yes" ]; then
  echo ""
  echo "Buscando módulos típicos..."

  # Heurística simple: subcarpetas en directorios de código típicos
  CANDIDATE_DIRS=()
  for parent in "backend/internal" "src/modules" "internal" "src/features" "apps"; do
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
      # Skip carpetas no-relevantes (shared, libs, etc.)
      case "$mod" in
        shared|common|utils|lib|tmp|bin|vendor|node_modules|dist|build) continue ;;
      esac
      mkdir -p "$PROJECT_ROOT/openspec/specs/$mod"
      cat > "$PROJECT_ROOT/openspec/specs/$mod/spec.md" <<EOF
# Capability: $mod

**Status:** documenting (brownfield seed) | **Updated:** $(date +%Y-%m-%d)

## Purpose

[Qué hace este módulo HOY. Lenguaje de negocio.]

## ADDED Requirements

<!--
  Estas son requirements del sistema EXISTENTE (no del futuro).
  Documentá lo que ya está implementado tal como funciona.
  Si vas a cambiarlo, hacelo en un /opsx:propose dedicado.
-->

### Requirement: [Nombre del comportamiento principal]

[Descripción del comportamiento actual en lenguaje de negocio.]

#### Scenario: [escenario-descriptivo-en-kebab-case]

- **WHEN** [condición o trigger]
- **THEN** [comportamiento observable]

## Known limitations / debt

[Bugs conocidos, edge cases no manejados, deuda técnica documentada.]

## External dependencies

[Sistemas externos con los que habla este módulo.]
EOF
      echo "    creado openspec/specs/$mod/spec.md (placeholder)"
    done
  fi
fi

echo ""
echo "=== Done ==="
echo ""
echo "Tu primer sprint con SDD: completar openspec/specs/ con la realidad"
echo "actual de cada capability. Después, /opsx:propose para cambios nuevos."
echo ""
