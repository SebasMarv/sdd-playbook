# Instrucciones para agentes AI (Claude, Cursor, Copilot, etc.)

Este archivo dirige el comportamiento de cualquier agente AI que opere sobre este proyecto.

---

## Reglas no-negociables para el agente

1. **Antes de proponer cualquier change (`/opsx:propose`):**
   - Leer `openspec/project.md` completo, especialmente sección `Architectural Invariants`.
   - Leer `openspec/specs/<capability>/` relevante para entender el estado actual.
   - Leer `progress/current.md` si existe.

2. **Antes de implementar (`/opsx:apply`):**
   - Confirmar que el `design.md` del change activo respeta las Architectural Invariants.
   - Si hay violación: detenerse, marcar en `proposal.md` sección "Architectural Impact", esperar confirmación humana.
   - Confirmar que `tasks.md` tiene tags correctos: `[BE]` / `[FE]` / `[DB]` / `[INFRA]`.
   - Confirmar que `design.md` tiene sección "Verification" con mapa R↔test.

3. **Durante implementación:**
   - Marcar tasks `[x]` conforme avances.
   - NO commitear con `--no-verify` o saltarse hooks salvo instrucción explícita del usuario.
   - NO crear archivos `.md` de "summary" o "progress notes" fuera del workflow oficial. Usar `progress/history.md` si necesitás dejar nota.

4. **Al terminar la sesión:**
   - Append a `progress/history.md` con resumen de qué se hizo.
   - Actualizar `progress/current.md` con next steps si el change no terminó.

5. **Al cerrar un change (`/opsx:archive`):**
   - Confirmar que TODAS las tasks están marcadas.
   - Confirmar que los deltas en `specs/` reflejan la realidad nueva.
   - Mover a archive y actualizar `progress/history.md`.

---

## Reglas de comunicación

- Responder en [Spanish / English / matching user language].
- No usar emojis salvo si el usuario los pide explícito.
- Resúmenes ejecutivos: tablas, bullets, secciones. Evitar texto plano largo.
- Antes de tomar acción destructiva o costosa: confirmar con el usuario.

## Reglas de código

- Seguir convenciones de `openspec/project.md#convenciones-de-código`.
- NUNCA introducir vulnerabilidades (OWASP top 10).
- NO usar fallbacks / try/except / validation para escenarios imposibles. Solo validar en bordes del sistema.
- Comentarios sólo cuando el WHY no es obvio. Nunca explicar el WHAT.

## Skip permitido

Está permitido saltar el flujo formal SDD (no `/opsx:propose`) para:
- Typos en docs.
- Fix de 1-2 líneas con root cause obvia y sin impacto arquitectónico.
- Rename de variables / refactor sin cambio de comportamiento.
- Bump de dependencia minor/patch sin breaking changes.

En esos casos, append a `progress/history.md` con una línea explicando qué se cambió.

---

## Cuándo escalar al humano

Detenerse y preguntar si:
- Una task requiere violar una Architectural Invariant.
- La spec del change tiene contradicciones internas.
- El estado en `openspec/specs/` parece no reflejar lo que el código realmente hace.
- Aparece algo que no estaba en `tasks.md` y parece importante.

Mejor preguntar y perder 30 segundos que asumir y romper algo.
