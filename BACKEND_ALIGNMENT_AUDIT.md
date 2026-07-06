# SistemaEF Mobile: Backend Alignment Audit

Fecha: 2026-07-05

## Objetivo

Dejar un mapa operativo entre:

- `sistemaef-backend`: superficie REST real y reglas activas
- `sistemaef-frontend`: cliente web ya alineado en varios modulos
- `sistemaef-mobile`: estado actual, huecos y prioridades

Este documento sirve como base para continuar la implementacion mobile sin depender de documentacion desactualizada.

## Resumen ejecutivo

El backend esta mas avanzado de lo que reflejan algunos documentos internos, especialmente en `tickets`.
El frontend web ya consume buena parte de la API real con contratos especificos.
El mobile tiene autenticacion funcional y navegacion base, pero la mayor parte de los modulos todavia estan montados sobre una UI generica de listado y no sobre features tipadas por dominio.

Conclusiones principales:

1. La fuente de verdad para continuar mobile debe ser el backend actual y, como referencia de consumo, el frontend web.
2. `tickets` ya no es placeholder a nivel backend ni web; solo sigue siendolo en mobile.
3. El mobile actual necesita salir del patron generico `ModuleListPage` y pasar a repositorios/modelos/acciones por modulo.
4. El modelo de roles del mobile esta incompleto: backend y frontend ya manejan 5 roles.

## Backend real hoy

Controladores detectados en backend:

- `auth`: `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/me`
- `activos`: CRUD, `contexto-operativo`, carga masiva y estado de importacion
- `clientes`: CRUD, carga masiva y estado de importacion
- `pdvs`: CRUD y `POST /pdvs/con-cliente`
- `asignaciones`: crear, listar, detalle, finalizar
- `catalogos`: tipos-activo, estados-activo, descripciones-equipo, tipos-canal, roles
- `bitacora`: listado filtrable
- `usuarios`: CRUD
- `tickets`: crear, candidatos, responsables, listar, detalle, decidir, iniciar atencion, cerrar

Observacion importante:

- `docs/README.md` todavia presenta `tickets` como algo "en preparacion", pero `AppModule` ya carga `TicketsModule` y el controlador de tickets esta completo.

## Matriz backend -> frontend -> mobile

### Auth

Backend:

- Implementado y consistente.
- Login por `email` + `password`.
- Refresh con `refresh_token`.
- `me` devuelve payload autenticado.

Frontend web:

- Cliente de API con refresh automatico y bridge de sesion.
- Flujo de login alineado al backend.

Mobile:

- Es el modulo mas maduro del proyecto mobile.
- Ya consume `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/me`.
- Tiene refresh automatico con `Dio` y persistencia del `refresh_token`.

Estado:

- Alineado en lo esencial.

Riesgos:

- El modelo de roles del mobile no refleja todos los roles existentes.

### Activos

Backend:

- `GET /activos`
- `GET /activos/:id`
- `GET /activos/:id/contexto-operativo`
- `POST /activos`
- `PATCH /activos/:id`
- `PATCH /activos/:id/estado`
- `POST /activos/carga-masiva`
- `GET /activos/carga-masiva/status/:id`

Frontend web:

- Consume listado, creacion, actualizacion, cambio de estado, contexto operativo e importacion CSV.

Mobile:

- Solo existe una pantalla generica conectada a `GET /activos`.
- Usa filtros manuales con nombres de campo.
- No tiene create/edit/change estado/contexto operativo/importacion.

Estado:

- Conectado parcialmente.

Brecha principal:

- El mobile muestra datos, pero no implementa el flujo operativo real del modulo.

### Clientes

Backend:

- `GET /clientes`
- `GET /clientes/:id`
- `POST /clientes`
- `PATCH /clientes/:id`
- `DELETE /clientes/:id`
- `POST /clientes/carga-masiva`
- `GET /clientes/carga-masiva/status/:id`

Frontend web:

- Consume CRUD e importacion.

Mobile:

- Pantalla generica con `GET /clientes`.
- Sin formularios CRUD ni carga masiva.

Estado:

- Conectado parcialmente.

### PDVs

Backend:

- `GET /pdvs`
- `GET /pdvs/:id`
- `POST /pdvs`
- `POST /pdvs/con-cliente`
- `PATCH /pdvs/:id`
- `DELETE /pdvs/:id`

Frontend web:

- Ya consume el flujo especial `con-cliente`.

Mobile:

- Solo listado generico.
- No cubre alta con cliente existente/nuevo ni edicion ni baja logica.

Estado:

- Conectado parcialmente.

### Asignaciones

Backend:

- `GET /asignaciones`
- `GET /asignaciones/:id`
- `POST /asignaciones`
- `PATCH /asignaciones/:id/finalizar`

Frontend web:

- Consume listado, creacion y finalizacion.

Mobile:

- Solo listado generico.
- No cubre reglas clave del flujo:
  - activo no puede tener 2 asignaciones activas
  - PDV debe pertenecer al cliente
  - finalizar exige nuevo estado del activo

Estado:

- Muy incompleto para operacion real.

### Catalogos

Backend:

- `GET/POST/PATCH` en tipos-activo, estados-activo, descripciones-equipo, tipos-canal
- `GET/PATCH` en roles

Frontend web:

- Consume lectura y mutaciones segun rol.

Mobile:

- Lee catalogos, pero como colecciones crudas.
- No tiene UX real para administracion ni tipado fuerte por catalogo.

Estado:

- Lectura basica disponible.

### Bitacora

Backend:

- `GET /bitacora` con filtros.

Frontend web:

- Consume listado tipado.

Mobile:

- Solo listado generico.

Estado:

- Conectado parcialmente.

### Usuarios

Backend:

- `GET /usuarios`
- `GET /usuarios/:id`
- `POST /usuarios`
- `PATCH /usuarios/:id`
- `DELETE /usuarios/:id`

Frontend web:

- Consume CRUD administrativo completo.

Mobile:

- Solo listado generico.
- No hay create/edit/delete ni formularios.

Estado:

- Muy incompleto para el alcance real del sistema.

### Tickets

Backend:

- `POST /tickets`
- `GET /tickets/candidatos`
- `GET /tickets/responsables`
- `GET /tickets`
- `GET /tickets/:id`
- `PATCH /tickets/:id/decision`
- `PATCH /tickets/:id/iniciar-atencion`
- `PATCH /tickets/:id/cerrar`

Frontend web:

- Ya tiene cliente de API y tipos para contratos de tickets.
- Refleja mejor que la documentacion el estado funcional real del sistema.

Mobile:

- Sigue como placeholder visual de "proximamente".

Estado:

- Mayor desfase actual entre backend y mobile.

Impacto:

- Si el objetivo es "pasar con el mobile", este es el modulo mas visible donde el mobile ya quedo atras.

### Reportes

Backend:

- No se identifico modulo real de reportes.

Frontend web:

- Sigue siendo placeholder de navegacion.

Mobile:

- Placeholder.

Estado:

- Se puede mantener fuera de prioridad inmediata.

## Problemas estructurales del mobile actual

### 1. UI generica en vez de features reales

La mayor parte de las pantallas usan `ModuleListPage`, que:

- hace `GET` generico
- espera `data[]`
- pinta pares clave/valor
- usa filtros por nombre de campo

Eso sirve para explorar datos, pero no para operar el sistema.

### 2. Contratos poco tipados

`ModuleApi` devuelve `List<Map<String, dynamic>>`, lo que:

- oculta diferencias entre respuestas
- debilita validaciones
- dificulta acciones complejas
- hace mas fragiles los cambios en backend

### 3. Roles incompletos

Backend y frontend manejan:

- `Registrador`
- `Autorizador`
- `Administrador`
- `Tecnico interno`
- `Proveedor`

El mobile solo modela los primeros tres.

### 4. Dashboard incorrecto

El dashboard mobile cuenta elementos usando `limit: 1` y el tamano del arreglo, por lo que no refleja el `total` real del backend.

### 5. Plan mobile ya quedo viejo

El `PLAN.md` todavia asume que `tickets/reportes` son placeholder y que solo hay 3 roles.
Ese plan ya no representa el estado real del producto.

## Prioridad recomendada

### Prioridad 1: Base transversal

Hacer primero:

1. Expandir roles mobile a 5 roles.
2. Crear contratos tipados por modulo en lugar de `Map<String, dynamic>`.
3. Definir repositorios por feature.
4. Preparar una capa comun de paginacion y manejo de `meta.total`.
5. Corregir dashboard para usar el `total` de las respuestas paginadas.

Resultado esperado:

- El mobile deja de ser un explorador generico y se vuelve cliente serio de la API.

### Prioridad 2: Tickets

Hacer segundo:

1. Listado de tickets.
2. Listado de candidatos.
3. Creacion de ticket.
4. Decision por autorizador.
5. Inicio de atencion.
6. Cierre.

Motivo:

- Es el modulo con mayor desfase.
- Ya existe backend real.
- Ya existe frontend web como referencia directa de contrato.

### Prioridad 3: Activos

Hacer tercero:

1. Listado tipado con filtros reales.
2. Detalle.
3. Contexto operativo.
4. Crear/editar.
5. Cambio de estado.

Motivo:

- `activos` es central para tickets y asignaciones.

### Prioridad 4: Asignaciones

Hacer cuarto:

1. Listado tipado.
2. Creacion con validaciones de negocio.
3. Finalizacion con seleccion de nuevo estado del activo.

Motivo:

- Tiene reglas importantes y cruza varios modulos.

### Prioridad 5: Clientes y PDVs

Hacer quinto:

1. CRUD de clientes.
2. CRUD de PDVs.
3. Flujo `POST /pdvs/con-cliente`.

Motivo:

- Son dependencias operativas de asignaciones y tickets.

### Prioridad 6: Usuarios, catalogos y bitacora

Hacer sexto:

1. Usuarios administrativos.
2. Catalogos con permisos por rol.
3. Bitacora filtrable.

Motivo:

- Importantes, pero menos urgentes para cerrar la brecha principal.

## Fuente de verdad recomendada por modulo

Usar en este orden:

1. Backend real:
   - controladores
   - DTOs
   - servicios
   - `prisma/schema.prisma`
2. Frontend web:
   - `features/*/api.ts`
   - `shared/types/*`
   - reglas de rol
3. Documentacion markdown:
   - solo como apoyo, nunca como verdad absoluta

## Estado de salud tecnica del backend

Verificaciones hechas:

- `prisma validate`: correcto
- `tsc --noEmit`: correcto
- `jest`: sin tests unitarios detectados en `src`

Riesgos:

- El test e2e base sigue siendo el scaffold original de Nest y no representa la API real.
- La ausencia de pruebas utiles implica que frontend y mobile deben validarse con especial cuidado en integracion real.

## Siguiente paso recomendado

Primer bloque de trabajo para implementar:

1. actualizar modelo de roles en mobile
2. crear contratos tipados y repositorio de `tickets`
3. reemplazar el placeholder de tickets por:
   - listado
   - detalle
   - acciones por rol
4. corregir dashboard usando `meta.total`

## Decision de implementacion sugerida

No seguir ampliando `ModuleListPage` como base central de la app.
Conviene mantenerlo, si acaso, como herramienta temporal de inspeccion.
Para producto real, cada modulo debe migrar a:

- modelos propios
- repositorio propio
- estado propio
- UI propia
- acciones propias

Eso es lo que mejor encaja con el backend actual y con el nivel de avance del frontend web.
