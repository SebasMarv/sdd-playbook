# sdd-toolkit

Kit personal para adoptar **Spec-Driven Development** en proyectos nuevos o existentes con bajo overhead, usando OpenSpec como base + 3 prácticas adicionales que mejoran control y durabilidad de sesión.

**Status:** v0 (draft, pendiente validar con piloto en Gesttio antes de promover a v1).

**Autor:** SebasMarv — kit destilado de investigación comparativa entre Spec-Kit, OpenSpec y harness-sdd (mayo 2026).

---

## TL;DR — Por qué este kit existe

Probé/investigué los tres frameworks SDD relevantes en 2026:

| Framework | Veredicto rápido |
|-----------|------------------|
| **GitHub Spec-Kit** | Mejor para greenfield + arquitecturas multi-módulo con invariantes fuertes y equipo 5+. Ceremonia alta. |
| **OpenSpec** (Fission-AI) | Mejor para brownfield + solo dev / equipo chico. Bajo overhead, "verdad viva" en `specs/`. |
| **harness-sdd** (betta-tech) | Repo de referencia, no tool. Ideas brillantes (multi-rol, R↔test, progress/) pero adoption cost alto y maturity baja. |

**Para mi caso real** (1-2 devs por proyecto, mix brownfield/greenfield, multi-proyecto, multi-país arquitectura matters): OpenSpec + 3 prácticas (project.md robusto con invariants, templates customs, `progress/` directory). Ver `docs/02-decision-tree.md` si tu caso difiere.

---

## Estructura del repo

```
sdd-toolkit/
├── README.md                          ← este archivo
├── CHANGELOG.md
├── docs/
│   ├── 01-comparativa.md              ← Spec-Kit vs OpenSpec vs harness-sdd, matriz completa
│   ├── 02-decision-tree.md            ← Cuándo usar cuál según escala/tipo proyecto
│   ├── 03-conventions-betta-tech.md   ← El workflow día a día
│   └── 04-roadmap-validar.md          ← Qué falta validar tras pilotos
├── baseline/                          ← lo que se copia a un proyecto
│   ├── openspec/
│   │   ├── project.template.md        ← invariants en blanco para llenar
│   │   ├── AGENTS.template.md         ← instrucciones para agentes AI
│   │   └── changes/
│   │       ├── proposal.template.md   ← override del default de OpenSpec
│   │       ├── design.template.md     ← con sección Verification obligatoria
│   │       └── tasks.template.md      ← con tags [BE]/[FE]/[DB]/[INFRA]
│   ├── progress/
│   │   ├── current.md.template
│   │   └── history.md.template
│   └── CLAUDE.md.template
├── scripts/
│   ├── setup-new-project.sh           ← greenfield: init clean
│   ├── setup-existing-project.sh      ← brownfield: init + prompt para seed specs
│   └── validate.sh                    ← chequeos estructurales sin CI
└── examples/                          ← se llena con casos reales post-piloto
```

---

## Cómo usarlo — proyecto nuevo (greenfield)

```bash
cd /path/al/proyecto/nuevo
npm install -g @fission-ai/openspec@latest
bash /mnt/d/Users/AMARQUEZ/Documents/sdd-toolkit/scripts/setup-new-project.sh
# editás openspec/project.md con stack real + invariants
```

Después de eso, tu día a día es:
- `/opsx:propose "feature X"` → llenás proposal/design/tasks
- `/opsx:apply` → Claude implementa
- `/opsx:archive` → fusiona en `openspec/specs/`

Más detalle en `docs/03-conventions-betta-tech.md`.

---

## Cómo usarlo — proyecto existente (brownfield)

```bash
cd /path/al/proyecto/existente
npm install -g @fission-ai/openspec@latest
bash /mnt/d/Users/AMARQUEZ/Documents/sdd-toolkit/scripts/setup-existing-project.sh
# primer sprint: documentar capabilities actuales en openspec/specs/
# después: workflow normal de propose → apply → archive
```

El script de existing-project te guía para crear specs iniciales que reflejen el estado **actual** del sistema antes de proponer cambios.

---

## Las 3 prácticas adicionales que añade este kit sobre OpenSpec puro

1. **`openspec/project.md` con sección "Architectural Invariants"** — las reglas no-negociables del proyecto (equivalente a Constitution de Spec-Kit, pero como guía documental, no gate automático). Claude las lee y respeta.

2. **Templates customs en `openspec/changes/`** — sobrescriben los defaults para forzar:
   - `proposal.md` con sección **Architectural Impact** (¿toca alguna invariant?)
   - `design.md` con sección **Verification** (mapa requirement R<n> ↔ test)
   - `tasks.md` con tags `[BE]/[FE]/[DB]/[INFRA]` para repartir trabajo

3. **`progress/` directory** — log durable de sesión que sobrevive resets de contexto del LLM. Contiene `current.md` (qué estás haciendo) e `history.md` (qué hiciste).

Ver `docs/03-conventions-betta-tech.md` para cómo encajan juntas.

---

## Lo que NO incluye este kit

- CI scripts elaboradas (overhead innecesario para 1-2 devs).
- PR templates (no uso PRs en MVPs).
- Definition of Done formal (vos sabés cuándo está done).
- Multi-agent roles (irrelevante para solo dev; ideas en `docs/01-comparativa.md` si escalás a equipo).
- Lock-in con tooling propietario (todo es markdown + bash).

---

## Roadmap

- **v0 (actual)**: investigación + templates draft. Sin uso real validado.
- **v1**: tras piloto en Gesttio (1-2 semanas), ajustar templates con lecciones.
- **v2**: tras 3+ proyectos usando el kit, generalizar lo que se repita.

Ver `docs/04-roadmap-validar.md` para detalles de qué validar.

---

## License

Privado. Sin license formal aún — uso interno.
