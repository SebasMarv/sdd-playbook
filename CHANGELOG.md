# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versionado: SemVer.

## [0.2.0] - 2026-05-23

Corrección crítica del baseline + las 7 extensiones validadas en proyecto piloto.
v0.1.0 tenía asunciones incorrectas sobre cómo funciona OpenSpec v1.3.1.

### Removed (baseline incorrecto de v0.1.0)
- `baseline/openspec/project.template.md` — OpenSpec NO usa project.md separado, todo va en `openspec/config.yaml#context`.
- `baseline/openspec/AGENTS.template.md` — OpenSpec NO usa AGENTS.md separado, las skills/commands viven en `.claude/commands/opsx/` (instalado por openspec init).
- `baseline/openspec/changes/proposal.template.md` — los templates oficiales vienen del npm package y se influencian vía `rules:` en config.yaml, no sobrescribiendo.
- `baseline/openspec/changes/design.template.md` — idem.
- `baseline/openspec/changes/tasks.template.md` — idem.

### Added
- `baseline/openspec/config.template.yaml` — config completo con context (invariants en blanco) + rules (7 extensiones precargadas) + preferences (session_level).
- `baseline/.local/credentials.template.md` — template para secrets locales gitignored.
- `docs/05-sdd-extensions.md` — documentación detallada de las 7 extensiones:
  1. User Stories priorizadas (P1/P2/P3)
  2. EARS Scenarios WHEN/THEN obligatorios
  3. Verification trazable triple (US → Scenario → Test)
  4. Pre-propose analysis MANDATORY
  5. session_level configurable (quick/standard/deep)
  6. Post-apply conflict review
  7. E2E como change explícito (no mezclar con feature work)
- Convenciones bonus: auto commit + push tras apply/archive, SSH-first debugging.

### Changed
- `scripts/setup-new-project.sh` — reescrito:
  - Llama `openspec init --tools claude --force` (era interactivo y colgaba en non-interactive).
  - NO copia los templates muertos (project.md, AGENTS.md, changes/*).
  - SÍ copia `config.template.yaml` → `openspec/config.yaml` del proyecto destino.
  - Crea `.local/credentials.md` desde template.
  - Actualiza `.gitignore` del proyecto destino con `.local/` y `commit_msg.txt`.
- `scripts/setup-existing-project.sh` — actualizado para coincidir con setup-new + scaffolding brownfield mejorado (placeholder con formato OpenSpec Requirement + Scenario en vez de free-form).
- `baseline/CLAUDE.md.template` — reescrito apuntando a `openspec/config.yaml` en lugar de `openspec/project.md`, con Session Start Protocol + Pre-propose analysis behavior + Post-apply conflict review.
- `README.md` — refleja v0.2.0, las 7 extensiones, flujo día a día actualizado.

### Validated in pilot
- OpenSpec v1.3.1 setup hands-on en proyecto real (Gesttio P2P TWM, brownfield Go+React+Postgres).
- Las 7 extensiones codificadas en el `openspec/config.yaml` del piloto y commiteadas a producción.
- Workflow auto commit + push validado.

## [0.1.0] - 2026-05-23 (DEPRECATED — wrong assumptions)

### Added
- Investigación comparativa Spec-Kit vs OpenSpec vs harness-sdd (`docs/01-comparativa.md`).
- Árbol de decisión por escala/tipo proyecto (`docs/02-decision-tree.md`).
- Convenciones de uso día a día (`docs/03-conventions-betta-tech.md`).
- Roadmap de validación tras piloto (`docs/04-roadmap-validar.md`).
- Templates v0 en `baseline/openspec/` (REMOVIDOS en v0.2.0 — asumían estructura incorrecta).
- Templates de `progress/` (`current.md`, `history.md`).
- `CLAUDE.md.template` (REESCRITO en v0.2.0).
- Scripts en `scripts/` (REESCRITOS en v0.2.0).
- MIT LICENSE.
- Renamed `sdd-toolkit` → `sdd-playbook`.

### Why deprecated
v0.1.0 fue creada antes de instalar OpenSpec hands-on. Las asunciones sobre
la estructura de OpenSpec (project.md, AGENTS.md, override de templates)
resultaron incorrectas al testearlo en un proyecto real. v0.2.0 corrige.

## [0.1.0] - 2026-05-23

### Added
- Investigación comparativa Spec-Kit vs OpenSpec vs harness-sdd (`docs/01-comparativa.md`).
- Árbol de decisión por escala/tipo proyecto (`docs/02-decision-tree.md`).
- Convenciones de uso día a día (`docs/03-conventions-betta-tech.md`).
- Roadmap de validación tras piloto (`docs/04-roadmap-validar.md`).
- Templates v0 en `baseline/openspec/`:
  - `project.template.md` con sección Architectural Invariants.
  - `AGENTS.template.md` para instrucciones a agentes AI.
  - `changes/proposal.template.md`, `design.template.md`, `tasks.template.md` con secciones obligatorias propias.
- Templates de `progress/` (`current.md`, `history.md`) idea robada de harness-sdd.
- `CLAUDE.md.template` apuntando a project.md como source of truth.
- Scripts en `scripts/`:
  - `setup-new-project.sh` para greenfield.
  - `setup-existing-project.sh` para brownfield.
  - `validate.sh` para chequeos estructurales sin CI.

### Pending validation
- Workflow real en proyecto Gesttio (piloto previsto sprint actual).
- Ajustes a templates según lecciones del piloto.
