#!/usr/bin/env bash
#
# setup-new-project.sh — Inicializa OpenSpec + baseline del playbook en un
# proyecto NUEVO (greenfield).
#
# Uso (desde la raíz del proyecto destino, NO del playbook):
#   bash /path/a/sdd-playbook/scripts/setup-new-project.sh
#
# Asume:
#   - OpenSpec instalado globalmente (npm install -g @fission-ai/openspec@latest)
#   - Estás en el directorio del proyecto destino

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

# 2. Verificar/confirmar overwrite si openspec/ ya existe
if [ -d "$PROJECT_ROOT/openspec" ]; then
  echo "WARNING: openspec/ ya existe en este proyecto."
  read -p "¿Sobrescribir openspec/config.yaml con el template del playbook? (yes/no): " confirm
  if [ "$confirm" != "yes" ]; then
    echo "Abortado."
    exit 0
  fi
fi

# 3. openspec init — non-interactive con claude integration
echo "[1/4] Inicializando OpenSpec (claude integration, force mode)..."
openspec init --tools claude --force || { echo "openspec init falló"; exit 1; }

# 4. Sobrescribir openspec/config.yaml con el template del playbook
#    (incluye context con invariants en blanco + rules pre-cargadas
#     + preferences para session_level)
echo "[2/4] Instalando openspec/config.yaml del playbook..."
cp "$BASELINE/openspec/config.template.yaml" "$PROJECT_ROOT/openspec/config.yaml"

# 5. Crear progress/ con templates
echo "[3/4] Creando progress/ con current.md + history.md..."
mkdir -p "$PROJECT_ROOT/progress"
if [ ! -f "$PROJECT_ROOT/progress/current.md" ]; then
  cp "$BASELINE/progress/current.md.template" "$PROJECT_ROOT/progress/current.md"
fi
if [ ! -f "$PROJECT_ROOT/progress/history.md" ]; then
  cp "$BASELINE/progress/history.md.template" "$PROJECT_ROOT/progress/history.md"
fi

# 6. Crear .local/ con template de credenciales (gitignored)
echo "[4/4] Creando .local/ (gitignored) + credentials.md template..."
mkdir -p "$PROJECT_ROOT/.local"
if [ ! -f "$PROJECT_ROOT/.local/credentials.md" ]; then
  cp "$BASELINE/.local/credentials.template.md" "$PROJECT_ROOT/.local/credentials.md"
fi

# 7. CLAUDE.md — sólo si NO existe (no sobrescribir CLAUDE.md de proyectos existentes)
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo "      CLAUDE.md ya existe — NO sobrescribo. Reviewá manualmente si querés"
  echo "      incorporar las secciones del template del playbook."
else
  cp "$BASELINE/CLAUDE.md.template" "$PROJECT_ROOT/CLAUDE.md"
  echo "      CLAUDE.md creado desde template."
fi

# 8. Actualizar .gitignore — agregar .local/ y commit_msg.txt si no están
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
  grep -qxF '.local/' "$PROJECT_ROOT/.gitignore" || echo '.local/' >> "$PROJECT_ROOT/.gitignore"
  grep -qxF 'commit_msg.txt' "$PROJECT_ROOT/.gitignore" || echo 'commit_msg.txt' >> "$PROJECT_ROOT/.gitignore"
  echo "      .gitignore actualizado con .local/ y commit_msg.txt."
else
  cat > "$PROJECT_ROOT/.gitignore" <<EOF
# Local-only artifacts
.local/
commit_msg.txt
EOF
  echo "      .gitignore creado con .local/ y commit_msg.txt."
fi

echo ""
echo "=== Listo. Próximos pasos ==="
echo ""
echo "1. Editá openspec/config.yaml:"
echo "   - context: stack real + Architectural Invariants reales del proyecto."
echo "   - rules: ajustar si querés (User Stories, Scenarios, Verification, etc. ya pre-cargadas)."
echo "   - preferences: session_level_default ya = quick. Cambiar si querés."
echo ""
echo "2. Editá .local/credentials.md con valores reales (NUNCA commitear esto)."
echo ""
echo "3. Editá CLAUDE.md (si se creó) con particularidades de entorno"
echo "   (paths, deploy, MCP tools, etc.)."
echo ""
echo "4. Commit:"
echo "   git add openspec/ progress/ CLAUDE.md .gitignore"
echo "   git commit -m 'chore: bootstrap sdd-playbook baseline'"
echo "   git push"
echo ""
echo "5. Primer cambio:"
echo "   /opsx:propose \"<descripción de tu primera feature>\""
echo ""
