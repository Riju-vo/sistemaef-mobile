enum TipoRol {
  registrador,
  autorizador,
  administrador,
  tecnicoInterno,
  proveedor,
}

TipoRol? tipoRolFromInt(int? value) {
  switch (value) {
    case 1:
      return TipoRol.registrador;
    case 2:
      return TipoRol.autorizador;
    case 3:
      return TipoRol.administrador;
    case 4:
      return TipoRol.tecnicoInterno;
    case 5:
      return TipoRol.proveedor;
    default:
      return null;
  }
}

int? tipoRolToInt(TipoRol? rol) {
  switch (rol) {
    case TipoRol.registrador:
      return 1;
    case TipoRol.autorizador:
      return 2;
    case TipoRol.administrador:
      return 3;
    case TipoRol.tecnicoInterno:
      return 4;
    case TipoRol.proveedor:
      return 5;
    default:
      return null;
  }
}

String tipoRolLabel(TipoRol? rol) {
  switch (rol) {
    case TipoRol.registrador:
      return 'Registrador';
    case TipoRol.autorizador:
      return 'Autorizador';
    case TipoRol.administrador:
      return 'Administrador';
    case TipoRol.tecnicoInterno:
      return 'Tecnico interno';
    case TipoRol.proveedor:
      return 'Proveedor';
    default:
      return 'Sin rol';
  }
}
