## Plan de Implementación Sprint 1 Mobile (Flutter) - SistemaEF

### Resumen
Construiremos `sistemaef-mobile` en **Flutter** con alcance Sprint 1 en módulos operativos reales del sistema: `auth`, `dashboard`, `activos`, `clientes`, `pdvs`, `asignaciones`, `catalogos`, `bitacora`, `mi sesión`, excluyendo lógica de `tickets/reportes` (solo existen como placeholder web).  
El plan replica reglas de negocio del backend (Nest + Prisma) y mantiene consistencia visual con frontend web (UI sobria, fondos claros, paneles, estados, badges, filtros y flujos CRUD con confirmaciones).

### Cambios clave de implementación
1. **Arquitectura y patrones (escalable)**
- Estructura por features + capas: `core/`, `features/`, `shared/`.
- Patrón recomendado: `Clean Architecture ligera` (presentation/domain/data) por módulo, evitando sobreingeniería.
- Gestión de estado: `Riverpod` (providers tipados, testables, desacoplados de UI).
- Networking: `Dio` + interceptores para auth/refresh + manejo de errores normalizado.
- Navegación: `go_router` con guards por sesión/rol.
- Modelado: DTOs tipados por endpoint con `freezed` + `json_serializable`.
- Resultado/errores: `Result<T, Failure>` para no propagar excepciones crudas a UI.

2. **Fundación técnica mobile**
- Bootstrap del proyecto Flutter en `sistemaef-mobile`.
- Configuración por ambiente (`dev/stage/prod`) y `API_BASE_URL`.
- Cliente HTTP con:
  - `Authorization: Bearer`.
  - Refresh automático en `401` contra `/auth/refresh`.
  - Logout forzado si refresh falla.
- Persistencia segura:
  - `refresh_token` en `flutter_secure_storage`.
  - `access_token` en memoria.
- Módulo `auth`:
  - `login`, `logout`, `me`, bootstrap de sesión al abrir app.
  - Matriz de roles: `Registrador(1)`, `Autorizador(2)`, `Administrador(3)`.

3. **Módulos funcionales Sprint 1**
- `Dashboard`: métricas rápidas (activos/clientes/pdvs/catálogos) con cards.
- `Activos`: listado paginado + filtros (`etiqueta`, `provincia`, `modelo`, `fabricante`, `id_descripcion_equipo`, `id_estado_activo`, `activo`), crear/editar, cambio de estado, vista contexto operativo (`/activos/:id/contexto-operativo`).
- `Clientes`: CRUD + softdelete (`activo=false`), validando `tipo_cliente` A/B/C, geodatos opcionales.
- `PDVs`: CRUD + softdelete, validando `id_cliente` activo, `id_tipo_canal`, `supracanal` On/OffPremise.
- `Asignaciones`: crear/listar/finalizar; reglas críticas:
  - un activo no puede tener 2 asignaciones activas,
  - no asignar entidades inactivas,
  - si hay `id_pdv`, debe pertenecer al cliente,
  - finalizar exige `id_estado_activo`.
- `Catálogos`: consulta de todos; mutaciones restringidas a admin.
- `Bitácora`: listado con filtros por acción/entidad/usuario/rango fechas.
- `Usuarios` (admin): CRUD con softdelete.
- `Mi sesión`: datos de token payload y usuario actual.
- `Tickets/Reportes`: solo entrada de navegación tipo “Próximamente”, sin lógica backend.

4. **Consistencia de diseño (alineada a frontend web)**
- Sistema visual mobile con Design Tokens:
  - superficie clara, bordes suaves, `panel/card` con sombra ligera.
  - color primario azul para acciones principales.
  - estados `success/muted/danger`.
- Componentes base reutilizables:
  - `AppScaffold`, `PageHeader`, `PrimaryButton/OutlineButton/GhostButton/DangerButton`,
  - `TextField/Select/DateField`,
  - `StatusBadge`,
  - `DataCard` (sustituto móvil de tablas),
  - `FilterBottomSheet`, `ConfirmDialog`, `ErrorBanner`, `PaginationFooter`.
- UX mobile-first:
  - listas en cards (no tablas),
  - filtros en bottom sheet,
  - acciones por fila con menú contextual,
  - formularios en pantalla dedicada o modal full-screen según complejidad.

5. **Plan por fases de entrega**
- Fase 1: Base app, auth, navegación protegida, tema/tokens, infraestructura HTTP.
- Fase 2: Dashboard + catálogos de soporte + componentes de listas/form.
- Fase 3: Clientes + PDVs.
- Fase 4: Activos + contexto operativo.
- Fase 5: Asignaciones + finalizar con nuevo estado.
- Fase 6: Bitácora + Usuarios + Mi sesión + placeholders tickets/reportes.
- Fase 7: hardening (errores, loading states, accesibilidad, QA final).

### APIs/interfaces públicas y contratos
- No se proponen cambios a backend en Sprint 1 mobile; se consume API existente:
  - `/auth/*`, `/activos*`, `/clientes*`, `/pdvs*`, `/asignaciones*`, `/catalogos/*`, `/bitacora`, `/usuarios*`.
- En mobile se define contrato interno estable:
  - `AuthRepository`, `ActivosRepository`, `ClientesRepository`, `PdvsRepository`, `AsignacionesRepository`, `CatalogosRepository`, `BitacoraRepository`, `UsuariosRepository`.
- Convención de IDs: manejar como `String` en UI/domain mobile (aunque en DB sean `BigInt`).

### Plan de pruebas y criterios de aceptación
- **Unit tests**
  - validadores y mappers DTO↔domain.
  - casos de uso por módulo (incluyendo reglas de negocio críticas).
  - auth interceptor (refresh success/failure).
- **Widget tests**
  - login, guard de sesión, formularios con validación.
  - render de estados vacíos/error/loading.
- **Integration tests**
  - flujos: login → dashboard, crear cliente, crear pdv, crear/finalizar asignación, cambio estado activo.
- **Aceptación funcional**
  - paridad operativa con frontend web Sprint 1.
  - permisos por rol respetados.
  - errores de backend mostrados de forma usable.
  - navegación estable con sesión persistente.

### Supuestos y decisiones tomadas
- Stack confirmado: **Flutter**.
- Alcance confirmado: **solo módulos operativos** + placeholders simples para tickets/reportes.
- Sin modo offline en Sprint 1 (online-first).
- Sin push notifications en Sprint 1.
- Fuente de verdad funcional y de negocio: `prisma/schema.prisma` + reglas actuales de casos de uso backend.
- Archivo objetivo del plan al ejecutar implementación: `sistemaef-mobile/implementation_plan_mobile_sprint1.md`.
