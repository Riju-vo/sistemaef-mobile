class CatalogItem {
  final int id;
  final String nombre;

  const CatalogItem({
    required this.id,
    required this.nombre,
  });

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: (json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? '') as String,
    );
  }
}

enum CatalogRoute {
  tiposActivo,
  estadosActivo,
  descripcionesEquipo,
  tiposCanal,
  roles,
}

String catalogRoutePath(CatalogRoute route) {
  switch (route) {
    case CatalogRoute.tiposActivo:
      return 'tipos-activo';
    case CatalogRoute.estadosActivo:
      return 'estados-activo';
    case CatalogRoute.descripcionesEquipo:
      return 'descripciones-equipo';
    case CatalogRoute.tiposCanal:
      return 'tipos-canal';
    case CatalogRoute.roles:
      return 'roles';
  }
}

String catalogRouteLabel(CatalogRoute route) {
  switch (route) {
    case CatalogRoute.tiposActivo:
      return 'Tipos de activo';
    case CatalogRoute.estadosActivo:
      return 'Estados de activo';
    case CatalogRoute.descripcionesEquipo:
      return 'Descripciones de equipo';
    case CatalogRoute.tiposCanal:
      return 'Tipos de canal';
    case CatalogRoute.roles:
      return 'Roles';
  }
}

bool catalogRouteCanCreate(CatalogRoute route) {
  return route != CatalogRoute.roles;
}
