# Project: [PROJECT_NAME]

Este archivo es la **fuente de verdad arquitectónica del proyecto**. Lo leen tanto humanos nuevos al equipo como agentes AI (Claude, Cursor, Copilot) antes de cualquier propuesta de cambio.

Estructura obligatoria — no eliminar secciones, completarlas o marcar como N/A.

---

## Stack & Versiones

- **Lenguaje backend:** [e.g. Go 1.24, Node 20, Python 3.12]
- **Framework backend:** [e.g. Gin, FastAPI, Express]
- **ORM / data layer:** [e.g. GORM, Prisma, SQLAlchemy]
- **DB:** [e.g. PostgreSQL 16]
- **Frontend framework:** [e.g. React 18 + Vite, Next.js 15, Svelte]
- **UI library:** [e.g. Ant Design v6, shadcn/ui, Tailwind]
- **Tests:** [e.g. Go test + Playwright E2E]
- **Otros:** [e.g. Redis, Airflow, MinIO, Keycloak]

## Estructura del repo

```
[completar con tree del proyecto a alto nivel]
```

## Convenciones de código

- **Lenguaje de docs / mensajes user-facing:** [Spanish / English / both]
- **Naming:** [snake_case en Go / camelCase en JS / etc.]
- **Branching:** [trunk-based / GitFlow / direct to main]
- **Commit message style:** [conventional commits / free / etc.]
- **Co-Authored-By en commits:** [SÍ / NO]
- **Emojis en código y commits:** [SÍ / NO]

## Architectural Invariants (NON-NEGOTIABLE)

**Estas son las reglas que ningún cambio puede violar sin justificación explícita en `proposal.md` y aprobación previa.**

1. [INVARIANT 1 — ej: "Hexagonal estricto: services nunca tocan adapters directamente, sólo via interfaces (ports)"]
2. [INVARIANT 2 — ej: "Multi-país: prohibido `if country == 'PE'` o cualquier hardcoding de país. Usar countryResolver.Get(code).<method>()"]
3. [INVARIANT 3 — ej: "Source tracking obligatorio: toda entidad de dominio debe tener source_system, source_id, external_refs JSONB"]
4. [INVARIANT 4 — ej: "Idempotencia adapters: clave (source_system, source_id) única; replay seguro"]
5. [INVARIANT N — ...]

Si un cambio necesita violar una invariante:
- Documentar en `changes/<name>/proposal.md` sección "Architectural Impact" con justificación.
- Marcar el change como **breaking architectural** y proponer una enmienda a este documento como parte del mismo PR/commit.
- La invariante violada se actualiza acá ANTES de mergear el cambio.

## Operacional

- **Entornos:** [local docker-compose / staging / prod]
- **Deploy:** [manual / auto via Dokploy / GitHub Actions / etc.]
- **Validación post-deploy:** [URL prod / SSH a VPS / etc.]
- **Hooks especiales:** [restart Keycloak post-deploy / etc.]

## Security baseline

- **Manejo de secrets:** [.env local / vault / etc. NUNCA en commits]
- **Auth en endpoints:** [JWT / session / Keycloak / etc.]
- **Multi-tenancy:** [single-tenant / multi-tenant via org_id middleware / etc.]
- **Roles:** [definir cuáles existen y su scope]
- **Compliance aplicable:** [GDPR / LGPD / SUNAT / SBS / N/A]

## Integraciones externas

| Sistema | Propósito | Modo | Quién lo mantiene |
|---------|-----------|------|-------------------|
| [SUNAT/SIRE] | [ingesta facturas] | [DAG Airflow] | [autor] |
| ... | ... | ... | ... |

## Decisiones arquitectónicas con histórico

- **YYYY-MM-DD:** [decisión 1 y por qué]
- **YYYY-MM-DD:** [decisión 2 y por qué]

(Mantener fechado para futuras referencias. NO borrar decisiones antiguas; marcarlas como "superseded by [otra decisión]" si cambian.)
