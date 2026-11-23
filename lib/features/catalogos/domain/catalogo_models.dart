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
  roles,
}

String catalogRoutePath(CatalogRoute route) {
  switch (route) {
    case CatalogRoute.roles:
      return 'roles';
  }
}

String catalogRouteLabel(CatalogRoute route) {
  switch (route) {
    case CatalogRoute.roles:
      return 'Roles';
  }
}

bool catalogRouteCanCreate(CatalogRoute route) {
  return false;
}
