# SistemaEF Mobile (Flutter)

Implementacion Sprint 1 mobile alineada al backend NestJS/Prisma.

## Run

1. Instalar Flutter SDK.
2. Ejecutar:
   - `flutter pub get`
   - `flutter run --dart-define=API_BASE_URL=http://localhost:3000`

## Alcance implementado

- Arquitectura base por features + core/shared.
- Auth con login, refresh automatico, logout y persistencia de refresh token.
- Navegacion protegida por sesion y visibilidad por rol.
- Modulos Sprint 1 conectados a API:
  - dashboard
  - activos
  - clientes
  - pdvs
  - catalogos
  - asignaciones
  - bitacora
  - usuarios (admin)
  - mi sesion
  - placeholders tickets/reportes