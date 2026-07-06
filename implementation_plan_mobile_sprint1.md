# implementation_plan_mobile_sprint1.md

## Objetivo
Implementar la app mobile de SistemaEF en Flutter para cubrir el Sprint 1 ya operativo en backend/frontend.

## Arquitectura aplicada
- Estructura por capas ligera y por modulos: `core`, `shared`, `features`.
- Estado con `Riverpod`.
- Networking con `Dio` + refresh automático en `401`.
- Sesion: access token en memoria, refresh token en `flutter_secure_storage`.
- IDs manejados como `String` en capa UI/domain mobile.

## Modulos implementados
- `auth`: login, bootstrap, refresh, logout, `/auth/me`.
- `dashboard`: cards de resumen conectadas a API.
- `activos`, `clientes`, `pdvs`, `asignaciones`, `bitacora`, `usuarios`: listado paginado base con filtros.
- `catalogos`: consulta de catalogos maestros vigentes.
- `me`: informacion de sesion actual.
- `tickets/reportes`: placeholders “Proximamente”.

## Consistencia de diseño
- Fondo claro, paneles/cards, bordes suaves, primario azul.
- Enfoque mobile-first con tarjetas de datos y filtros en UI compacta.

## Pendientes de hardening (siguiente iteracion)
- Formularios CRUD completos por modulo (alta/edicion/finalizacion con validaciones exactas de negocio).
- Generacion de modelos con `freezed/json_serializable` (estructura ya preparada).
- Pruebas unitarias/widget/integration por flujo.
- Paginacion avanzada, skeleton loading y manejo de errores por campo.

## Estructura clave
- `lib/core`: config, red, errores, storage.
- `lib/shared`: componentes UI y utilitarios.
- `lib/features/*`: modulos funcionales del sistema.