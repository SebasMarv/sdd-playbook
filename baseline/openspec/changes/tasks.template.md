# Tasks: [CHANGE_NAME]

**Input:** `design.md` aprobado.

**Format:** `- [ ] TNNN [TAG] [REQ] description`
- `[TAG]`: `[BE]` backend / `[FE]` frontend / `[DB]` migration / `[INFRA]` infra / `[DOC]` docs / `[TEST]` tests-only
- `[REQ]`: requirement reference (R1, R2, ...) para traceabilidad. Opcional para tareas de setup.

Orden recomendado: DB → Backend → Tests → Frontend → Docs → Verify.

---

## Phase 1: Setup / Foundation

- [ ] T001 [INFRA] [Setup task: ej. añadir dependencia, configurar env var]
- [ ] T002 [DB] [Migration NNNNNN_description.up.sql + .down.sql]

## Phase 2: Backend

- [ ] T010 [BE] [R1] Modelo en `backend/internal/X/model.go`
- [ ] T011 [BE] [R1] Repository en `backend/internal/X/repository.go`
- [ ] T012 [BE] [R1] Service en `backend/internal/X/service.go`
- [ ] T013 [BE] [R2] Handler en `backend/internal/X/handler.go`
- [ ] T014 [BE] [R2] Route registration en `backend/internal/X/routes.go`

## Phase 3: Tests Backend

- [ ] T020 [TEST] [R1] Unit test para model/service
- [ ] T021 [TEST] [R2] Integration test para endpoint

## Phase 4: Frontend

- [ ] T030 [FE] [R3] API client en `frontend/src/services/X.ts`
- [ ] T031 [FE] [R3] Types en `frontend/src/types/X.ts`
- [ ] T032 [FE] [R4] Página/componente en `frontend/src/features/X/`

## Phase 5: Tests Frontend / E2E

- [ ] T040 [TEST] [R4] E2E test si aplica

## Phase 6: Docs & Verify

- [ ] T050 [DOC] Actualizar README o CLAUDE.md si hay nuevo flow user-facing
- [ ] T051 Verificar contra `design.md#verification` que todos los R<n> tienen test pasando
- [ ] T052 Quickstart manual end-to-end según `quickstart.md` si existe

---

## Notes

- Marcar `[x]` al completar cada task.
- Si una task descubre que hay que cambiar el `design.md`, PAUSAR, ajustar design, retomar.
- Si una task se hace innecesaria, marcarla `[~]` (skipped) con nota inline del por qué.
- Si aparecen tasks nuevas durante apply, añadirlas con número TNNN+1 y avisar al humano.
