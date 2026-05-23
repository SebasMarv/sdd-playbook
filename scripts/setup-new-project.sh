#!/usr/bin/env bash
#
# setup-new-project.sh — Inicializa OpenSpec + baseline templates + progress/ en un proyecto NUEVO (greenfield).
#
# Uso (desde la raíz del proyecto destino):
#   bash /path/a/sdd-playbook/scripts/setup-new-project.sh
#
# Asume:
#   - OpenSpec ya instalado globalmente (npm install -g @fission-ai/openspec@latest)
#   - Estás en el directorio del proyecto destino (no del kit)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASELINE="$KIT_ROOT/baseline"
PROJECT_ROOT="$(pwd)"

echo "=== sdd-playbook: setup-new-project ==="
echo "Kit:     $KIT_ROOT"
echo "Project: $PROJECT_ROOT"
echo ""

# 1. Verificar que OpenSpec esté instalado
if ! command -v openspec &> /dev/null; then
  echo "ERROR: 'openspec' CLI no encontrado en PATH."
  echo "Instalar con: npm install -g @fission-ai/openspec@latest"
  exit 1
fi

# 2. Verificar que no esté ya inicializado
if [ -d "$PROJECT_ROOT/openspec" ]; then
  echo "WARNING: openspec/ ya existe en este proyecto."
  read -p "¿Sobrescribir? (yes/no): " confirm
  if [ "$confirm" != "yes" ]; then
    echo "Abortado."
    exit 0
  fi
fi

# 3. openspec init
echo "[1/5] Inicializando OpenSpec..."
openspec init || { echo "openspec init falló"; exit 1; }

# 4. Sobrescribir project.md con template del kit
echo "[2/5] Copiando project.template.md..."
cp "$BASELINE/openspec/project.template.md" "$PROJECT_ROOT/openspec/project.md"

# 5. Crear AGENTS.md
echo "[3/5] Copiando AGENTS.template.md..."
cp "$BASELINE/openspec/AGENTS.template.md" "$PROJECT_ROOT/openspec/AGENTS.md"

# 6. Sobrescribir templates de changes/ — guardamos en una carpeta de "templates kit"
#    para que cuando hagas /opsx:propose, OpenSpec los use (validar mecánica exacta).
echo "[4/5] Copiando templates de changes/..."
mkdir -p "$PROJECT_ROOT/openspec/.kit-templates"
cp "$BASELINE/openspec/changes/proposal.template.md" "$PROJECT_ROOT/openspec/.kit-templates/proposal.md"
cp "$BASELINE/openspec/changes/design.template.md" "$PROJECT_ROOT/openspec/.kit-templates/design.md"
cp "$BASELINE/openspec/changes/tasks.template.md" "$PROJECT_ROOT/openspec/.kit-templates/tasks.md"

# 7. Crear progress/ + CLAUDE.md
echo "[5/5] Creando progress/ y CLAUDE.md..."
mkdir -p "$PROJECT_ROOT/progress"
cp "$BASELINE/progress/current.md.template" "$PROJECT_ROOT/progress/current.md"
cp "$BASELINE/progress/history.md.template" "$PROJECT_ROOT/progress/history.md"

if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo "      CLAUDE.md ya existe — NO sobrescribo. Reviewá manualmente si querés usar el template del kit."
else
  cp "$BASELINE/CLAUDE.md.template" "$PROJECT_ROOT/CLAUDE.md"
fi

echo ""
echo "=== Listo. Próximos pasos ==="
echo ""
echo "1. Editá openspec/project.md con stack real + Architectural Invariants reales."
echo "2. Editá CLAUDE.md con particularidades de entorno (si copió el template)."
echo "3. Cuando hagas /opsx:propose, usá los archivos en openspec/.kit-templates/"
echo "   como referencia para llenar proposal/design/tasks."
echo "4. Commiteá: git add openspec/ progress/ CLAUDE.md && git commit -m 'chore: sdd-playbook baseline'"
echo ""
