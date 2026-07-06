# Mobile Backlog

Fecha base: 2026-07-05

## Prioridad 1

- [x] Alinear roles mobile con backend: 5 roles
- [x] Corregir dashboard para usar `meta.total`
- [x] Documentar brecha backend/web/mobile en `BACKEND_ALIGNMENT_AUDIT.md`
- [x] Implementar `tickets` como modulo real
  - [x] Modelos tipados
  - [x] Repositorio de listado
  - [x] Pantalla de listado conectada al backend
  - [x] Detalle de ticket
  - [x] Crear ticket
  - [x] Aprobar / rechazar ticket
  - [x] Iniciar atencion
  - [x] Cerrar ticket
  - [x] Filtros completos

## Prioridad 2

- [x] Migrar `activos` de vista generica a feature real
  - [x] Modelos tipados
  - [x] Repositorio
  - [x] Listado tipado
  - [x] Detalle
  - [x] Contexto operativo
  - [x] Crear / editar
  - [x] Cambio de estado

## Prioridad 3

- [x] Migrar `asignaciones` a feature real
  - [x] Listado tipado
  - [x] Crear asignacion
  - [x] Finalizar asignacion
  - [x] Validaciones de negocio en UI

## Prioridad 4

- [x] Migrar `clientes` a feature real
  - [x] CRUD
  - [x] Carga masiva
- [x] Migrar `pdvs` a feature real
  - [x] CRUD
  - [x] Flujo `con-cliente`

## Prioridad 5

- [x] Migrar `usuarios` a feature real
- [x] Mejorar `catalogos` con tipado y mutaciones admin
- [x] Mejorar `bitacora` con filtros reales

## Transversal

- [x] Reducir dependencia de `ModuleListPage`
- [x] Crear contratos tipados por modulo
- [x] Homogeneizar paginacion
- [x] Mejorar mensajes de error
- [x] Agregar validacion estatica estable (`dart analyze`)
- [x] Agregar pruebas base de serializacion y errores
