# Convenciones de uso día a día

Cómo se usa este kit (OpenSpec + las 3 prácticas) en un proyecto real. Lectura para alguien que va a abrir un proyecto con esto y no sabe por dónde arrancar.

---

## Setup inicial (una vez por proyecto)

### Greenfield (proyecto nuevo)

```bash
cd /path/al/proyecto-nuevo
npm install -g @fission-ai/openspec@latest    # si no está global
bash /path/a/sdd-toolkit/scripts/setup-new-project.sh
```

El script:
1. Corre `openspec init` (crea `openspec/specs/` y `openspec/changes/` vacíos).
2. Sobrescribe `openspec/project.md` con tu template robusto (sección Architectural Invariants incluida en blanco).
3. Sobrescribe los templates default de `changes/` con los customs.
4. Crea `progress/current.md` y `progress/history.md`.
5. Añade `CLAUDE.md` apuntando a `openspec/project.md` como source of truth.

Después del script, tu primera tarea humana es llenar `openspec/project.md` con stack real + invariants reales.

### Brownfield (proyecto existente)

```bash
cd /path/al/proyecto-existente
npm install -g @fission-ai/openspec@latest
bash /path/a/sdd-toolkit/scripts/setup-existing-project.sh
```

Idéntico al anterior, **más** un prompt al final que te recuerda: tu primer sprint debe documentar las capabilities actuales en `openspec/specs/<capability>/spec.md` antes de proponer cualquier change. Esto es lo que evita que el sistema mienta sobre sí mismo.

---

## El día a día — flujo principal

### Empezar un cambio

```
/opsx:propose "tax_codes multi-país con override por tenant"
```

OpenSpec crea `openspec/changes/add-tax-codes-multipais/` con:
- `proposal.md` (template custom: rationale + Architectural Impact)
- `design.md` (template custom: enfoque técnico + Verification mapa R↔test)
- `tasks.md` (template custom: checklist con tags [BE]/[FE]/[DB]/[INFRA])
- `specs/` (deltas ADDED/MODIFIED/REMOVED por capability)

Llenás cada uno. Tiempo típico para un change mediano: 30-60 min.

### Implementar

```
/opsx:apply
```

Claude lee `tasks.md` + `design.md` + `project.md` (incluyendo Architectural Invariants) + `progress/current.md` y ejecuta. Vos vas marcando `[x]` o lo hace el agente.

### Cerrar

```
/opsx:archive
```

OpenSpec mueve la carpeta a `openspec/changes/archive/YYYY-MM-DD-add-tax-codes-multipais/` y **fusiona los deltas** en `openspec/specs/`. A partir de este momento, `openspec/specs/master-data/` refleja la realidad nueva.

### Append a history.md

Al final de cada sesión (manual o pedile a Claude):

```bash
echo "## 2026-05-23 — tax_codes multi-país archivado" >> progress/history.md
echo "- Closed change add-tax-codes-multipais" >> progress/history.md
echo "- Updated capability master-data" >> progress/history.md
```

---

## Cuándo SALTAR el flujo (válido)

El SDD a medias es peor que no tener SDD. Pero el SDD perfecto es peor que no terminar.

Permitido saltar:
- **Typos / fix de docs:** commit directo. No amerita change.
- **Fix de 1-2 líneas con root cause obvia y no impacta arquitectura:** commit directo, anotar en `progress/history.md`.
- **Rename de variable / refactor que no cambia comportamiento:** commit directo.
- **Bumping de dependencia minor/patch sin breaking changes:** commit directo.

NO permitido saltar:
- Feature nueva, por chica que sea.
- Cualquier cambio que toque algo en `project.md#architectural-invariants`.
- Cambios en schema de BD.
- Cambios en contratos de API públicos.
- Cualquier cambio que en 6 meses vas a olvidar por qué hiciste.

---

## Cómo se cargan los templates customs en OpenSpec

OpenSpec usa templates internos cuando hacés `/opsx:propose`. Para que use los nuestros, los scripts copian los archivos `*.template.md` desde `baseline/openspec/changes/` a la ubicación que OpenSpec espera (chequear su doc oficial — esta ubicación puede cambiar entre versiones).

**Nota v0:** este punto está pendiente de validar en piloto. Si OpenSpec no permite override fácil de templates, el plan B es no usar `/opsx:propose` y crear los archivos a mano usando los templates. Más fricción pero garantizado funciona.

---

## El rol de `progress/`

Carpeta append-only fuera de `openspec/`. Dos archivos:

### `progress/current.md`

Estado actual de la sesión. Se sobrescribe cada vez que cambia el foco.

```markdown
# Current Work

## Active change
- add-tax-codes-multipais (sin archivar)

## Last session: 2026-05-23 14:00
- Completed: T001 (model), T002 (repository)
- Next: T003 (service layer)
- Blockers: ninguno

## Notes for next session
- Recordar revisar el handling de país EC vs CL
- Tests pending: T010, T011
```

Cuando volvés tras context reset / nueva sesión Claude / día siguiente, leés esto primero. Sobrevive cualquier compaction de chat.

### `progress/history.md`

Append-only. Una entrada por sesión productiva.

```markdown
# History

## 2026-05-23
- Archived add-payment-terms-multipais
- Started add-tax-codes-multipais

## 2026-05-22
- Implemented T001-T005 of add-payment-terms-multipais
- Found bug in countryResolver, fixed in same change
```

Esto es tu "log de ingeniería". A los 6 meses te sirve para reconstruir qué hiciste cuándo, mejor que git log porque está en lenguaje de negocio.

---

## Onboardear a un dev nuevo en un proyecto con este kit

Tiempo objetivo: 30-60 minutos.

1. Que clone el repo del proyecto.
2. Que lea (en orden):
   - `CLAUDE.md` (5 min) — apunta a project.md.
   - `openspec/project.md` (10 min) — stack, conventions, invariants.
   - `openspec/specs/` (10-20 min según tamaño) — la verdad actual del sistema.
   - `progress/current.md` (2 min) — qué se está haciendo ahora.
3. Demo en vivo: `/opsx:propose` un change trivial, llenarlo juntos, no aplicarlo.
4. Que lea `openspec/changes/archive/` (los últimos 3-5 cerrados) para ver patterns reales.

Si el dev ya conoce SDD, el ramp-up es la mitad.

---

## Multi-proyecto: el patrón "betta-tech"

Yo (autor) tengo varios proyectos con este kit. La consistencia se mantiene así:

- Cada proyecto tiene su `openspec/project.md` con stack propio + invariants propios.
- Los templates en `baseline/openspec/changes/` son los MISMOS en todos los proyectos (forzados por los scripts).
- `progress/` es local por proyecto, nunca compartido.
- Cuando aprendo algo nuevo (mejoro un template, ajusto un workflow), actualizo el kit central y los scripts se encargan de propagarlo en el próximo `setup-*`.

Esto te da: mismo workflow en proyecto A, B, C. Onboarding rápido cuando cambiás de proyecto cada mes.

---

## Cuándo este workflow se siente mal

Señales de que algo no encaja:

- **"Tengo 5 changes en `archive/` por una sola feature."** Estás partiendo demasiado fino. Agrupá.
- **"Nunca llené `progress/history.md`."** Pedile a Claude que lo haga al final de cada sesión. O reducí su scope.
- **"El agente ignora `project.md#architectural-invariants`."** Confirmá que `CLAUDE.md` lo referencia explícitamente. Sumá un prompt en `AGENTS.md`.
- **"Tengo muchos cambios sin documentar porque eran 'chiquitos'."** Bajá tu umbral de "chiquito" o aceptá que es debt.

Estos son patterns para discutir y ajustar en `04-roadmap-validar.md` post-piloto.
