# Design: [CHANGE_NAME]

**Input:** `proposal.md` aprobada de este change + `openspec/project.md` + `openspec/specs/<capabilities>/`.

---

## Approach

[El enfoque técnico. Cómo se va a resolver lo que pide `proposal.md`.]

## Alternatives considered

[Qué otras formas se evaluaron y por qué se descartaron. Mínimo 1 alternativa rechazada. Si no hay alternativa real, decir "no se evaluaron alternativas porque [razón]".]

---

## Components affected

| Área | Archivos / módulos | Tipo de cambio |
|------|--------------------|----------------|
| Backend | `backend/internal/X/` | new file / modify / delete |
| Frontend | `frontend/src/features/Y/` | new file / modify / delete |
| DB | `backend/migrations/00NN_*.sql` | new migration |
| Infra | `docker-compose.yml` / `Dockerfile` | modify |

## Data model changes

[Si hay cambios en schema, declararlos:]

- **New entities:** [Entity1 con campos clave]
- **Modified entities:** [Entity2 + qué se le añade/quita]
- **New columns:** [tabla.columna : tipo]
- **Removed columns:** [tabla.columna] — preservar 1-2 sprints antes de drop

## API contract changes

[Si hay endpoints nuevos/modificados:]

- `POST /api/v1/X` — [descripción]
- `PUT /api/v1/Y/:id` — [descripción]

(Considerar publicar OpenAPI en `contracts/` si el cambio es grande.)

---

## Verification (REQUIRED)

**Mapeo Requirement → Test.** Cada Requirement declarado en `proposal.md` y/o `tasks.md` debe tener al menos un test que lo verifique.

| Requirement | Test | Tipo | Notas |
|-------------|------|------|-------|
| R1 — [breve descripción] | `backend/internal/X/X_test.go::TestThing` | Unit | — |
| R2 — [breve descripción] | `tests/integration/Y_test.go::TestFlow` | Integration | — |
| R3 — [breve descripción] | Manual via `quickstart.md` paso 4 | Manual | Pendiente automatizar |

Si algún requirement no tiene test mapeable, justificar acá:

- **Sin test automatizado:** [razón]

---

## Risks & mitigations

| Risk | Probabilidad | Impacto | Mitigación |
|------|:------------:|:-------:|------------|
| [riesgo 1] | Alta/Media/Baja | Alto/Medio/Bajo | [plan B] |

## Rollback plan

[Si esto se mergea y rompe algo, ¿cómo se revierte?]

- Migración: [reversible vía .down.sql? sí/no]
- Código: `git revert <sha>` + redeploy
- Datos: [si hay datos generados que no se pueden recuperar, declararlo]

---

## Open questions

[Cosas que quedaron sin resolver y necesitan respuesta antes de o durante apply. Marcar con `[NEEDS DECISION]`.]

- `[NEEDS DECISION]` ¿X o Y?
- `[NEEDS DECISION]` ¿Aplicamos esto para todos los países o sólo PE?
