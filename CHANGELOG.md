# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versionado: SemVer.

## [Unreleased]

### Changed
- Renamed project `sdd-toolkit` → `sdd-playbook` (mejor posicionamiento: "playbook curado", no framework nuevo).
- README intro reescrito para reflejar el rename y el posicionamiento público.
- Paths absolutos personales en README reemplazados por placeholders genéricos.

### Added
- MIT LICENSE.

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
