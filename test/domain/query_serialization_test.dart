import 'package:sistemaef_mobile/features/clientes/domain/cliente_models.dart';
import 'package:sistemaef_mobile/features/pdvs/domain/pdv_models.dart';
import 'package:test/test.dart';

void main() {
  group('ClientesQuery', () {
    test('serializes only active filters', () {
      const query = ClientesQuery(
        page: 2,
        limit: 20,
        nombre: 'ACME',
        codigoCliente: '123',
        activo: true,
        categoriaSofia: CategoriaSofia.b,
      );

      expect(query.toQueryParameters(), {
        'page': 2,
        'limit': 20,
        'nombre': 'ACME',
        'codigo_cliente': '123',
        'activo': true,
        'categoria_sofia': 'B',
      });
    });
  });

  group('PdvsQuery', () {
    test('serializes enum filters to backend format', () {
      const query = PdvsQuery(
        nombreNegocio: 'Kiosko Norte',
        supracanal: Supracanal.offPremise,
        idTipoCanal: 4,
      );

      expect(query.toQueryParameters(), {
        'page': 1,
        'limit': 20,
        'nombre_negocio': 'Kiosko Norte',
        'id_tipo_canal': 4,
        'supracanal': 'OffPremise',
        'activo': true,
      });
    });
  });
}
