# sdd-playbook

Playbook pragmático para adoptar **Spec-Driven Development** en proyectos
nuevos o existentes con bajo overhead, usando **OpenSpec** como base + **7
extensiones validadas** que mejoran control, trazabilidad y durabilidad de
sesión.

No es un framework nuevo — es una **guía curada de decisión + baseline
reutilizable + 7 reglas que elevan el workflow** sobre el ecosistema SDD
existente (Spec-Kit, OpenSpec, harness-sdd).

**Status:** v0.2.0 — baseline + extensiones validadas en proyecto piloto.
Pendiente para v1.0: 3+ proyectos usando el kit y generalización post-uso.

**Autor:** SebasMarv — destilado de investigación comparativa entre
Spec-Kit, OpenSpec y harness-sdd (mayo 2026).

---

## TL;DR — Por qué este kit existe

Probé/investigué los tres frameworks SDD relevantes en 2026:

| Framework | Veredicto rápido |
|-----------|------------------|
| **GitHub Spec-Kit** | Mejor para greenfield + arquitecturas multi-módulo con invariantes fuertes y equipo 5+. Ceremonia alta. |
| **OpenSpec** (Fission-AI) | Mejor para brownfield + solo dev / equipo chico. Bajo overhead, "verdad viva" en `specs/`. |
| **harness-sdd** (betta-tech) | Repo de referencia, no tool. Ideas brillantes (multi-rol, R↔test, progress/) pero adoption cost alto y maturity baja. |

**Para mi caso real** (1-2 devs por proyecto, mix brownfield/greenfield,
multi-proyecto, multi-país arquitectura matters): **OpenSpec + 7
extensiones**. Ver `docs/02-decision-tree.md` si tu caso difiere.

---

## Estructura del repo

```
sdd-playbook/
├── README.md                          ← este archivo
├── CHANGELOG.md
├── LICENSE                            ← MIT
├── docs/
│   ├── 01-comparativa.md              ← Spec-Kit vs OpenSpec vs harness-sdd
│   ├── 02-decision-tree.md            ← Cuándo usar cuál según escala/tipo
│   ├── 03-conventions-betta-tech.md   ← Workflow día a día con OpenSpec + ext.
│   ├── 04-roadmap-validar.md          ← Qué falta validar / qué ya validamos
│   └── 05-sdd-extensions.md           ← ⭐ Las 7 extensiones detalladas
├── baseline/                          ← lo que se copia a un proyecto destino
│   ├── openspec/
│   │   └── config.template.yaml       ← config con context + rules + preferences
│   ├── progress/
│   │   ├── current.md.template
│   │   └── history.md.template
│   ├── .local/
│   │   └── credentials.template.md    ← template para secrets locales
│   └── CLAUDE.md.template             ← operational guide template
├── scripts/
│   ├── setup-new-project.sh           ← greenfield: init clean
│   ├── setup-existing-project.sh      ← brownfield: init + brownfield seed
│   └── validate.sh                    ← chequeos estructurales sin CI
└── examples/                          ← se llena con casos reales post-pilotos
```

---

## Las 7 extensiones que añade sobre OpenSpec puro

| # | Extensión | Qué hace |
|---|-----------|----------|
| 1 | User Stories P1/P2/P3 en proposal | MVP-first thinking obligatorio |
| 2 | EARS Scenarios WHEN/THEN obligatorios | 1 Scenario = 1 test |
| 3 | Verification trazable triple | US → Scenario → Test en design.md |
| 4 | Pre-propose analysis MANDATORY | Detecta gaps/conflicts antes de proponer |
| 5 | session_level (quick/standard/deep) | Vocabulario por nivel (default quick) |
| 6 | Post-apply conflict review | Detecta regresiones antes del commit |
| 7 | E2E como change explícito | No mezclar E2E con feature work |

Detalle completo en `docs/05-sdd-extensions.md`.

---

## Cómo usarlo — proyecto NUEVO (greenfield)

```bash
cd /path/al/proyecto/nuevo
npm install -g @fission-ai/openspec@latest
bash /path/a/sdd-playbook/scripts/setup-new-project.sh
```

El script ejecuta:
1. `openspec init --tools claude --force` (instala 4 commands + 4 skills).
2. Copia `openspec/config.yaml` con context (invariants a llenar) + rules
   (las 7 extensiones precargadas) + preferences (session_level).
3. Crea `progress/current.md` + `history.md`.
4. Crea `.local/credentials.md` template (gitignored).
5. Crea `CLAUDE.md` si no existe.
6. Actualiza `.gitignore` con `.local/` y `commit_msg.txt`.

Después:
- Editás `openspec/config.yaml` (llenás invariants reales + ajustás context).
- Editás `.local/credentials.md` con valores reales.
- Editás `CLAUDE.md` con particularidades del entorno.
- `git commit` + push.
- Primer `/opsx:propose "<tu feature>"` y arrancás.

---

## Cómo usarlo — proyecto EXISTENTE (brownfield)

```bash
cd /path/al/proyecto/existente
npm install -g @fission-ai/openspec@latest
bash /path/a/sdd-playbook/scripts/setup-existing-project.sh
```

Hace todo lo del greenfield + opcionalmente scaffolea
`openspec/specs/<modulo>/spec.md` placeholders detectando módulos comunes
(backend/internal/, src/modules/, etc.).

**Primer sprint dedicado:** documentar capabilities actuales en
`openspec/specs/` antes de proponer cambios. Esto es lo que evita que el
sistema "mienta sobre sí mismo".

---

## El flujo día a día (resumido)

```
Vos: "Quiero <feature>"

Claude (Paso 0 — Pre-propose analysis):
  ├─ Lee openspec/specs/ relacionados + archive/ con changes históricos.
  ├─ Imagina flow end-to-end + edge cases + conflictos.
  └─ Te muestra análisis + preguntas dirigidas (en vocabulario session_level).

Vos: respondés en chat.

Claude (Paso 1 — /opsx:propose):
  ├─ Crea changes/<name>/ con proposal/design/tasks/specs.
  ├─ Llena con User Stories + EARS Scenarios + Verification trazable.
  └─ Te muestra: "Listo, ¿/opsx:apply?"

Vos: "dale" (o pedís ajustes).

Claude (Paso 2 — /opsx:apply):
  ├─ Implementa código + tests siguiendo tasks.md.
  ├─ Post-apply conflict review (releer specs/ tocadas).
  └─ Última task [GIT]: commit + push automático.

Claude (Paso 3 — /opsx:archive):
  ├─ Fusiona deltas en openspec/specs/<capability>/spec.md.
  ├─ Move change a openspec/changes/archive/YYYY-MM-DD-<name>/.
  └─ Segundo commit + push automático.

Vos: validás en URL prod tras Dokploy auto-deploy (o equivalente).
```

Detalle completo en `docs/03-conventions-betta-tech.md`.

---

## Lo que NO incluye este kit

- CI scripts elaboradas (overhead innecesario para 1-2 devs).
- PR templates (no uso PRs en MVPs).
- Multi-agent roles formales (irrelevante para solo dev; ver
  `docs/01-comparativa.md` si escalás a equipo).
- Lock-in con tooling propietario (todo es markdown + bash + npm).

---

## Roadmap

- **v0 (2026-05-23, deprecated)**: investigación + templates draft con
  asunciones incorrectas sobre OpenSpec.
- **v0.2.0 (2026-05-23, actual)**: ⭐ corrección de baseline + las 7
  extensiones validadas en proyecto piloto (Gesttio P2P TWM).
- **v1.0 (futuro)**: tras 3+ proyectos usando el kit, generalización
  post-uso real.

Ver `docs/04-roadmap-validar.md` para detalles.

---

## License

MIT — ver [LICENSE](./LICENSE).
