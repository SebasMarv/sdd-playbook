# Roadmap de validación

Este kit es **v0**. Las decisiones están basadas en investigación + un install hands-on de Spec-Kit, pero **no en uso real de OpenSpec en un proyecto completo todavía**. Lo siguiente lista qué hace falta validar.

---

## Piloto previsto: Gesttio (sprint actual)

Proyecto Gesttio (`mono-repo-app-p2p-twm`) es brownfield ideal para piloto:
- Multi-país en gestación (PE/EC/CL/MX/CO).
- Invariantes arquitectónicas fuertes (Level 2 + JSONB, no hardcoding país, idempotencia adapters).
- 1 dev (SebasMarv) + Claude Code.
- Próximas features bien definidas: SAP fidelity Fase 1 (master data tax_codes + payment_terms).

### Plan del piloto

1. Setup OpenSpec en Gesttio usando `scripts/setup-existing-project.sh`.
2. Llenar `openspec/project.md` con stack + invariants ya conocidos.
3. Seed inicial de `openspec/specs/` documentando capabilities ya implementadas (F1-F4):
   - organizations, purchase-orders, delivery-notes, acceptance-sheets, invoices, matching, admin-ui, tenant-config.
4. Primer change real: `add-tax-codes-multipais` (SAP fidelity Fase 1.1).
5. Segundo change: `add-payment-terms-multipais` (SAP fidelity Fase 1.2).
6. Capturar lecciones durante 1-2 semanas.

### Qué medir durante el piloto

- **Time-to-first-task:** cuánto tarda en arrancar a codear desde que empezás un change.
- **Re-trabajo:** cuántas veces hay que editar proposal/design después de empezar apply.
- **Adherencia:** ¿se respeta el flujo o terminás saltándolo? Cuántos commits directo a main sin change asociado.
- **Útil para retomar?:** ¿`progress/current.md` realmente te ayuda tras context reset, o es burocracia?
- **Invariants respetadas?:** ¿el agente cumple `project.md#architectural-invariants` o las viola?
- **Velocity:** ¿hacés más o menos cosas por sprint que antes?

---

## Preguntas abiertas a resolver con el piloto

### Sobre OpenSpec
- ¿Los templates customs se pueden overridear sin problemas o hay que crear los archivos a mano?
- ¿`/opsx:apply` respeta `project.md` o se distrae?
- ¿`/opsx:archive` fusiona deltas en `specs/` automáticamente, o hay que hacerlo a mano?
- ¿Qué pasa cuando un change toca múltiples capabilities — los deltas quedan limpios?
- ¿El perfil expandido (`/opsx:verify`, `/opsx:ff`, etc.) aporta o es ruido?

### Sobre las 3 prácticas adicionales
- **`project.md` Architectural Invariants:** ¿Claude las respeta con sólo tenerlas documentadas, o hay que mencionarlas explícitamente en cada `/opsx:propose`?
- **Templates customs:** ¿se aplican automáticamente, o requieren copia manual cada vez?
- **`progress/`:** ¿se llena de forma natural, o es disciplina que se olvida? Si se olvida, ¿la culpa es del template o del flujo?

### Sobre el día a día
- ¿La distinción "saltar el flujo para bugs chicos" funciona en práctica o termina siendo "saltar siempre"?
- ¿Cuántas sesiones nuevas en Claude necesitan el `progress/current.md` para no perderse?
- ¿`history.md` se llena de forma orgánica o necesita un script cron?

---

## Promoción v0 → v1

Tras 1-2 semanas de piloto en Gesttio, se promueve v0 → v1 con:

- Templates ajustados a lo que realmente sirvió.
- `docs/03-conventions-betta-tech.md` reescrito con ejemplos reales (no hipotéticos).
- Sección nueva `examples/gesttio/` con:
  - El `project.md` real de Gesttio (con invariants reales).
  - 2-3 changes archivados como referencia de qué se ve "bien hecho".
- Eliminación de los "TBD" en este documento.

---

## Decisiones a re-evaluar tras 3+ proyectos (v2)

Cuando este kit se haya usado en al menos 3 proyectos distintos:

- ¿Los templates son lo suficientemente genéricos o cada proyecto los modifica?
- ¿Aparecen patrones nuevos que valga la pena codificar?
- ¿OpenSpec sigue siendo el ganador, o algún competidor cerró el gap?
- ¿Conviene formalizar la "constitución" como gate automático (acercándonos a Spec-Kit)?
- ¿Hace falta multi-rol agente (acercándonos a harness-sdd) cuando hay más usuarios?

---

## Cosas que ya sé que están desactualizadas o son hipotéticas en v0

- La sección "Cómo se cargan los templates customs" en `03-conventions-betta-tech.md` describe la **intención**, no necesariamente lo que funciona. Pendiente validar.
- El script `setup-new-project.sh` copia templates pero no he validado que OpenSpec los respete después.
- El árbol de decisión asume que mi recomendación (OpenSpec) es óptima para los casos descritos. Si el piloto demuestra lo contrario para algún sub-caso, ajustar.
- La interacción exacta entre `progress/` y el resto del flujo es nueva — la robé de harness-sdd y no tengo experiencia real con ella en proyectos productivos.

---

## Cuándo descartar este kit completo

Si tras el piloto Gesttio:
- El re-trabajo es >50% (proposal/design cambian más de la mitad de las veces durante apply).
- Saltás el flujo en >70% de los commits.
- `progress/` queda abandonado después de 1 semana.
- Las invariants se violan a pesar de estar documentadas.

Entonces: la metodología no encaja con cómo trabajás, no el tool. Considerá:
- Volver a workflow ad-hoc (sin SDD formal) con disciplina personal.
- Probar Spec-Kit por su rigidez.
- Diseñar tu propia metodología minimalista.

No hay vergüenza en descartar un kit que no rinde. La vergüenza es seguir usándolo por inercia mientras no rinde.
