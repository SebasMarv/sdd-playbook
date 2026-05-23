# Las 7 extensiones que el playbook agrega sobre OpenSpec

OpenSpec out-of-the-box da el 80% del valor SDD: proposal + design + tasks
+ archive con specs fusionados. Este playbook agrega **7 extensiones** que
elevan el workflow a un nivel más profesional sin perder ligereza.

Todas las extensiones viven como **rules** en `openspec/config.yaml` o como
**convenciones** en `CLAUDE.md` del proyecto destino. No requieren modificar
OpenSpec ni instalar plugins.

---

## 1. User Stories priorizadas (P1/P2/P3)

**Qué:** sección obligatoria en `proposal.md` con al menos US1 (P1, MVP).

**Formato:**
```
## User Stories

### US1 — [título] (P1, MVP)
**Como** <rol>, **quiero** <feature>, **para** <beneficio>.

### US2 — [título] (P2)
...
```

**Valor:** te obliga a pensar MVP-first y prioridad. Permite partir un
change en entregas independientes.

**Codificado en:** `openspec/config.yaml#rules.proposal`.

---

## 2. EARS Scenarios mandatorios (WHEN/THEN)

**Qué:** cada `### Requirement:` en spec deltas DEBE tener al menos 1
`#### Scenario:` en formato WHEN/THEN.

**Formato:**
```
### Requirement: payment-terms-multi-tier-resolution

The system SHALL merge payment terms in order
product_defaults → country_pack → tenant_config.

#### Scenario: country-pack-default-applied
- **WHEN** un usuario crea una OC en tenant T con country=EC
- **THEN** el plazo_pago = EC country_pack default
```

**Valor:** 1 Scenario = 1 test ejecutable. Trazabilidad spec → test gratis.

**Variantes:** IF/WHILE/WHERE permitidas si WHEN/THEN no encaja.

**Codificado en:** `openspec/config.yaml#rules.specs`.

---

## 3. Verification trazable triple (US → Scenario → Test)

**Qué:** sección obligatoria en `design.md` con tabla de trazabilidad.

**Formato:**
```
## Verification

| User Story | Scenarios cubiertos                 | Test                        |
|------------|-------------------------------------|-----------------------------|
| US1        | country-pack-default-applied        | tests/payment_terms_test.go::TestCountryPackDefault |
| US1        | no-payment-terms-error              | tests/payment_terms_test.go::TestNoPaymentTermsError |
| US2        | tenant-override-wins                | tests/payment_terms_test.go::TestTenantOverride |
```

**Valor:** auditable. Cliente / QA / vos en 6 meses pueden saber qué tests
validan qué requirement de qué historia.

**Codificado en:** `openspec/config.yaml#rules.design`.

---

## 4. Pre-propose analysis (MANDATORY)

**Qué:** ANTES de invocar `/opsx:propose`, Claude debe:

1. Read related capabilities en `openspec/specs/<related>/spec.md`.
2. Search archive (`openspec/changes/archive/`) por changes relacionados.
3. Mental flow simulation — imaginar end-to-end con actores, datos, edge cases.
4. Identify gaps que el usuario NO especificó.
5. Identify conflicts con specs actuales o changes archivados.
6. Check architectural invariants tocadas.
7. Present analysis + preguntas dirigidas.
8. Tras respuestas → invocar `/opsx:propose`.

**Valor:** evita re-trabajo. Detecta conflictos antes de proponer.

**Codificado en:**
- Behavior en `CLAUDE.md` sección "Adding a New Feature > Paso 0".
- Section obligatoria `## Pre-propose analysis` en `proposal.md`
  (rule en `openspec/config.yaml#rules.proposal`).

---

## 5. session_level configurable (quick / standard / deep)

**Qué:** vocabulario que Claude usa al comunicarse, configurable por sesión.

| Nivel | Vocabulario |
|-------|-------------|
| **quick** (default) | 100% negocio: estados, módulos, campos del portal, cálculos. Cero técnico. |
| **standard** | Negocio + términos del proyecto (nombres de módulos, endpoints, patrones). |
| **deep** | Técnico completo: tablas, columnas, FK, indexes, migrations, archivos. |

**Cómo se decide:** Claude pregunta al inicio de cada sesión nueva. Override
mid-sesión con "modo <nivel>". Override por change crítico permitido.

**Diferencia clave:** el nivel determina **VOCABULARIO** de preguntas/explicaciones,
NO la **cantidad**. La cantidad la determina la ambigüedad del pedido.

**Valor:** trabajo multi-proyecto sin agotar la cabeza con detalle técnico
que no necesitás recordar.

**Codificado en:** `openspec/config.yaml#preferences` + `CLAUDE.md` sección
"Session Start Protocol".

---

## 6. Post-apply conflict review

**Qué:** ANTES del `[GIT]` task final de `/opsx:apply`, Claude debe:

1. Releer `openspec/specs/<capability>/` de cada capability tocada.
2. Verificar que ningún Scenario archivado quede roto por la implementación nueva.
3. Si detecto regresión potencial: PAUSAR commit, reportar al usuario.
4. Si OK: proceder con commit + push.

**Valor:** detecta regresiones antes del deploy. Compensa parcialmente la
falta de E2E tests en MVP iterativo.

**Codificado en:**
- Rule en `openspec/config.yaml#rules.tasks`.
- Behavior en `CLAUDE.md` "Adding a New Feature > Paso 2".

---

## 7. E2E tests como change explícito (no mezclar con feature work)

**Qué:** los tests E2E (Playwright, Cypress, Detox, etc.) NO se mezclan con
el desarrollo iterativo de features. Cuando un módulo se estabiliza (5+
changes archivados sin bugs recientes), se abre un change dedicado:

```
/opsx:propose "add-e2e-tests-<module>"
```

Sesión separada para setear el harness y escribir specs E2E que coincidan
con los Scenarios documentados en `openspec/specs/<module>/spec.md`.

**Valor:** evita el anti-pattern de "tests E2E flakey escritos en paralelo
a features que cambian rápido". E2E es inversión cuando hay estabilidad.

**Codificado en:** `CLAUDE.md` sección "Tests E2E".

---

## Auto commit + push (convención bonus)

Aunque no es una "extensión SDD" propiamente, va de la mano:

**Convención:** la última task de cada `/opsx:apply` es `[GIT]` (commit +
push automático). Y tras `/opsx:archive`, segundo commit + push automático.

**Valor:** vos no pedís git ops manualmente. El workflow es "describe la
feature → mirá el deploy".

**Codificado en:** `openspec/config.yaml#rules.tasks` (rules 3, 4, 5 del bloque).

---

## SSH-first ante problemas en prod (convención bonus)

Si el usuario reporta un problema en prod, Claude debe SSH primero al
server (`.local/credentials.md`), traer evidencia (logs, queries, container
state), y volver con hipótesis informada — no preguntas vagas al usuario.

**Codificado en:** `CLAUDE.md` sección "Deployment Validation".

---

## Resumen — qué cambia vs OpenSpec puro

| Aspecto | OpenSpec puro | OpenSpec + sdd-playbook |
|---------|---------------|--------------------------|
| Proposal structure | Why + What Changes + Capabilities + Impact | + Pre-propose analysis + User Stories P1/P2/P3 + Architectural Impact |
| Spec deltas | Requirements + Scenarios opcional | Requirements + Scenarios WHEN/THEN obligatorios |
| Design verification | No section | Verification tabla US → Scenario → Test |
| Pre-flight | Ninguno | Pre-propose analysis mandatorio |
| Tono de comunicación | Default técnico | session_level (quick/standard/deep) |
| Pre-commit safety | Ninguno | Post-apply conflict review |
| E2E tests | Implícito en cualquier momento | Change explícito dedicado |
| Git ops | Manual | Auto tras apply/archive |
| Prod debugging | Pedir al usuario | SSH-first |

Las 7 extensiones son **opcionales** — podés deshabilitar cualquiera
quitándole la rule del `config.yaml`. Pero juntas conforman un workflow
que reduce re-trabajo y eleva la calidad de los specs.
