# Comparativa Spec-Kit vs OpenSpec vs harness-sdd

Investigación realizada en mayo 2026 con instalación real de Spec-Kit (v0.8.13) en un proyecto para verificar workflow contra docs oficiales.

---

## Las 3 opciones, lo más resumido posible

### GitHub Spec-Kit (`github/spec-kit`)
- **Qué es:** CLI tool empaquetado, mantenido por GitHub.
- **Filosofía:** flujo lineal estricto con gates entre capas. Spec.md no puede tocar tecnología; plan.md la decide; tasks.md la ejecuta.
- **Instalación:** `uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z` + `specify init --here --integration claude`.
- **Slash invocations:** skills en `.claude/skills/speckit-*` con guion (`/speckit-constitution`, `/speckit-specify`, etc.). 14 skills instaladas en v0.8.13 (9 core + 5 git extension).
- **Artefacto clave:** `.specify/memory/constitution.md` con **Constitution Check** como gate explícito en plan.md.
- **Sweet spot:** greenfield, multi-módulo con invariantes arquitectónicas fuertes, equipos 5+.

### OpenSpec (`Fission-AI/OpenSpec`)
- **Qué es:** CLI tool empaquetado, mantenido por Fission-AI.
- **Filosofía:** brownfield-first. `specs/` = la verdad actual del sistema (viva); `changes/` = propuestas activas; `archive/` = histórico fechado.
- **Instalación:** `npm install -g @fission-ai/openspec@latest` + `openspec init`.
- **Slash invocations:** comandos `/opsx:*` (`/opsx:propose`, `/opsx:apply`, `/opsx:archive` + perfil expandido con `new`, `continue`, `ff`, `verify`, etc.). Skills comunitarias opcionales en `openspec-skills` repo.
- **Artefacto clave:** `openspec/specs/<capability>/` se va actualizando al archivar cada change.
- **Sweet spot:** brownfield, solo dev / equipo chico, multi-proyecto consistency.

### harness-sdd (`betta-tech/harness-sdd`)
- **Qué es:** Repo de referencia / template educativo (NO es un tool empaquetado).
- **Filosofía:** multi-rol agente con human gate explícito antes de implementar; estado durable en `progress/` para sobrevivir context resets.
- **Instalación:** clonar/forkear y adaptar manualmente al stack del proyecto (~4-8h).
- **Integración Claude:** 4 archivos en `.claude/agents/` (leader, spec_author, implementer, reviewer) + hooks en `.claude/settings.json`.
- **Artefacto clave:** `feature_list.json` con WIP=1 estricto + `progress/` directory + R↔test obligatorio.
- **Maturity:** 5 commits, 0 releases, sin license. Experimental.

---

## Matriz de dimensiones que importan

Verde = mejor, amarillo = aceptable, rojo = peor. Para el caso de uso del autor (1-2 devs, multi-proyecto).

| Dimensión | Spec-Kit | OpenSpec | harness-sdd |
|-----------|:--------:|:--------:|:-----------:|
| **Control AI drift** | 🟢 Constitution Check + templates rígidos | 🟡 project.md + tasks, sin gate formal | 🟢 Reviewer agent + R↔test obligatorio |
| **Recuperación de spec equivocado** | 🔴 Re-correr clarify+plan+tasks | 🟢 Edits in place | 🟡 Vuelve a spec_ready |
| **Recuperación de context reset** | 🟡 Lees plan.md + tasks.md | 🟡 Lees changes/<active>/tasks.md | 🟢 `progress/current.md` diseñado para esto |
| **Costo de bug de 1 línea** | 🔴 5-7 pasos absurdos | 🟢 propose ligero o ni se usa | 🔴 4 pasos + human approval |
| **Costo de feature grande** | 🟢 Ceremonia justificada | 🟡 Funciona pero menos guía | 🟢 Justificada con gates |
| **"Qué hace el sistema HOY"** | 🔴 Reconstruir de N features cerradas + git log | 🟢 `openspec/specs/` literalmente | 🟡 `specs/` + `progress/history.md` |
| **"Qué se cambió cuándo"** | 🟡 Git log + commits | 🟢 `changes/archive/YYYY-MM-DD-*` fechado | 🟢 `progress/history.md` append-only |
| **Brownfield fit** | 🔴 Greenfield-first; specs retrospectivos forzados | 🟢 Brownfield-first by design | 🟡 Conceptualmente bien |
| **Curva de aprendizaje** | 🔴 Vocabulario denso | 🟢 3 conceptos (changes/specs/archive) | 🔴 Multi-rol + EARS + R↔test |
| **Adoption cost real** | 🟢 1 min install + 1h aprender | 🟢 1 min install + 30 min | 🔴 4-8h adaptar template |
| **Maturity / riesgo** | 🟢 GitHub-respaldado | 🟢 Fission-AI activo | 🔴 5 commits, sin license |
| **Per-feature branching forzado** | 🔴 Sí (choca con "directo a main") | 🟢 No | 🔴 Indirectamente sí |

---

## Veredictos por escala

### Solo dev (1 persona + Claude)
**Ganador: OpenSpec.** La ceremonia de Spec-Kit no se paga; la rigidez de harness-sdd tampoco. OpenSpec da lo justo: estructura para no perderse + bajo overhead para usar siempre. Agregar prácticas de `progress/` y `project.md` con invariants cierra los gaps.

### Equipo chico (2-4 devs)
**Ganador: OpenSpec con rituales mínimos.** Mismo razonamiento que solo dev, pero con un peer review informal del `design.md` antes del `/opsx:apply`. Sin CI ni PR templates pesados.

### Equipo mediano (5-10 devs)
**Tie: depende del trade-off.** Spec-Kit reduce variance entre devs por sus templates rígidos (bueno con mix juniors/seniors). OpenSpec da más velocidad pero exige más disciplina cultural. Si hay mix de seniorities, Spec-Kit gana. Si todos son seniors, OpenSpec.

### Equipo grande (10+) o compliance fuerte
**Probablemente Spec-Kit o custom.** Spec-Kit por la rigidez y Constitution Check; o custom con ideas de harness-sdd (multi-rol agentes, R↔test obligatorio, WIP limits) si compliance lo justifica.

### Compliance (SOX, HIPAA, ISO 27001)
**Ninguno completo out-of-the-box.** Requiere traceabilidad automatizada, no convención. Harness-sdd tiene las ideas correctas (R↔test obligatorio, reviewer separado) pero hay que armarlo. Considerar tooling propietario o agregar capa custom a OpenSpec/Spec-Kit.

---

## Errores comunes en docs de internet

Verifiqué hands-on contra Spec-Kit v0.8.13 y encontré que mucha documentación externa (incluso conversaciones con LLMs recientes) tiene info desfasada:

- ❌ "Slash commands son `/speckit.constitution` con punto" → en v0.8.13 es **guion**: `/speckit-constitution`.
- ❌ "Spec-Kit instala comandos en `.claude/commands/`" → en v0.8.13 son **skills** en `.claude/skills/speckit-*/`. El directorio `.claude/commands/` no se crea.
- ❌ "Hay un plugin opcional que añade skills" → en v0.8.13 las skills vienen **por defecto** con el `--integration claude`. No hay plugin separado.

Si encontrás docs de SDD escritas antes de mayo 2026, asumí que pueden estar desactualizadas y verificá contra la versión actual del CLI.

---

## Recomendación general

Para 1-2 devs (caso del autor):

1. **OpenSpec como base.**
2. **`project.md` robusto con sección Architectural Invariants** (compensa la falta de Constitution Check).
3. **Templates customs para `changes/`** (compensa la falta de rigidez de Spec-Kit).
4. **`progress/` directory** (robada de harness-sdd, sobrevive context resets).

Esto es lo que materializa `baseline/` de este kit.
