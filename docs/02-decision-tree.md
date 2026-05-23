# Árbol de decisión — Qué SDD usar en mi proyecto

Cuándo el kit (OpenSpec + 3 prácticas) NO es la respuesta correcta. Casos en los que conviene desviarse.

---

## Pregunta 1: ¿Cuántos devs trabajarán en este proyecto?

```
1 dev solo                     → OpenSpec + baseline (este kit)
2-4 devs (todos seniors)       → OpenSpec + baseline + peer review informal de design.md
2-4 devs (mix seniors/juniors) → OpenSpec + baseline + revisar PRs con foco en design.md
5-10 devs                      → Considerar Spec-Kit por templates rígidos
10+ devs                       → Spec-Kit, o custom con CI enforcement
```

## Pregunta 2: ¿Greenfield o brownfield?

```
Greenfield, arquitectura simple       → OpenSpec + baseline
Greenfield, arquitectura compleja con
invariantes transversales (multi-país,
multi-tenant, multi-ERP, etc.)        → Spec-Kit (Constitution Check vale la pena)
Brownfield                            → OpenSpec siempre. Sweet spot.
```

## Pregunta 3: ¿Compliance / auditoría regulatoria?

```
Sin compliance                  → OpenSpec + baseline
Compliance leve (auditoría
ocasional de clientes B2B)      → OpenSpec + baseline. archive/ con fechas alcanza.
Compliance fuerte (SOX, HIPAA,
ISO 27001, PCI-DSS)             → No usar este kit tal cual. Construir custom con:
                                   - R↔test obligatorio automatizado (de harness-sdd)
                                   - Reviewer agent separado (de harness-sdd)
                                   - Audit trail en sistema externo (no en repo)
```

## Pregunta 4: ¿Tipo de cambios predominantes?

```
Features nuevas grandes (1-2 sem c/u)  → OpenSpec o Spec-Kit indistinto. SK más útil.
Bugfixes pequeños frecuentes            → OpenSpec sin discusión. SK fricciona demasiado.
Mantenimiento / refactor                → OpenSpec. archive/ documenta lo cerrado.
Mix con muchos cambios pequeños         → OpenSpec (la ceremonia de SK te hace saltar el flujo)
```

## Pregunta 5: ¿Trabajás solo, en pareja, o tu agente AI es tu "pair"?

```
Solo (sin AI)                        → Cualquier framework, pero rinde menos. SDD asume AI.
Solo + Claude/Cursor/Copilot         → OpenSpec + baseline (este kit). Diseñado para esto.
Pair humano                          → OpenSpec. Cualquiera de los dos puede tomar la spec.
Pair humano + AI                     → OpenSpec con review entre los dos antes de apply.
```

---

## Mapa rápido por caso de uso real

| Caso | Recomendación |
|------|---------------|
| Startup MVP, 1 founder dev | OpenSpec + baseline |
| Agencia consultora, varios clientes pequeños | OpenSpec + baseline (multi-proyecto consistency wins) |
| Producto SaaS B2B en growth con 3-5 devs | OpenSpec + baseline + peer review de design.md |
| Banco / fintech con compliance | Custom con ideas de harness-sdd |
| Open source library con contributors externos | Spec-Kit (constitución sirve como contrato a contributors) |
| Migración de monolito a microservicios | OpenSpec (brownfield-first) |
| Hackathon / prototipo desechable | Ninguno. SDD es overhead aquí. |
| Refactor arquitectónico masivo de monolito | Spec-Kit en el módulo refactorado + OpenSpec en el resto |

---

## Cuándo NO uses ningún SDD framework

- **Hackathons o exploración pura:** la velocidad importa más que la corrección. Vibe coding está OK aquí.
- **Scripts one-shot:** un bash de 50 líneas no necesita spec.
- **Prototipos para tirar:** si el código vivirá 1 semana, no inviertas en gobernanza.
- **Cuando el equipo no se compromete a usarlo:** un SDD a medias es peor que no tener uno. La spec divergente del código miente.

---

## Señales de que elegiste mal y conviene cambiar

- Llevás 1 mes con Spec-Kit y todavía las features tardan más por la ceremonia. → Migrá a OpenSpec.
- Llevás 1 mes con OpenSpec y el agente sigue violando invariantes arquitectónicas. → Sumá Constitution Check manual o migrá a Spec-Kit.
- Adoptaste harness-sdd y nadie llena `progress/`. → Volvé a OpenSpec, robá sólo lo que sí usás.
- El equipo creció a 8 personas y la disciplina se rompió. → Sumá CI checks o migrá a Spec-Kit.

Migrar entre frameworks SDD **no es caro** si todo el contenido es markdown (lo es en los 3). Lo que cuesta es la curva de aprender el nuevo.
