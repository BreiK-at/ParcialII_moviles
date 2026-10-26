import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inventario_app/models/producto.dart';

void main() {
  group('Modelo Producto', () {
    test('fromJson parsea correctamente todos los campos', () {
      final json = {
        'id': 1,
        'nombre': 'Laptop Lenovo',
        'codigo': 'PRD-001',
        'descripcion': 'Laptop de prueba',
        'precio': 3500000.0,
        'cantidad': 10,
        'categoria': 'Computadores',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };
      final producto = Producto.fromJson(json);
      expect(producto.id, 1);
      expect(producto.nombre, 'Laptop Lenovo');
      expect(producto.codigo, 'PRD-001');
      expect(producto.descripcion, 'Laptop de prueba');
      expect(producto.precio, 3500000.0);
      expect(producto.cantidad, 10);
      expect(producto.categoria, 'Computadores');
    });

    test('toJson serializa correctamente los campos', () {
      final producto = Producto(
        id: 2,
        nombre: 'Mouse Logitech',
        codigo: 'PRD-002',
        precio: 120000.0,
        cantidad: 5,
        categoria: 'Perifericos',
      );
      final json = producto.toJson();
      expect(json['nombre'], 'Mouse Logitech');
      expect(json['codigo'], 'PRD-002');
      expect(json['precio'], 120000.0);
      expect(json['cantidad'], 5);
      expect(json['categoria'], 'Perifericos');
    });

    test('valorTotal calcula precio x cantidad', () {
      final producto = Producto(
        nombre: 'Monitor',
        codigo: 'PRD-003',
        precio: 1000000.0,
        cantidad: 3,
        categoria: 'Pantallas',
      );
      expect(producto.valorTotal, 3000000.0);
    });

    test('copyWith reemplaza solo los campos especificados', () {
      final original = Producto(
        id: 1,
        nombre: 'Teclado',
        codigo: 'PRD-004',
        precio: 200000.0,
        cantidad: 20,
        categoria: 'Perifericos',
      );
      final copia = original.copyWith(precio: 250000.0, cantidad: 15);
      expect(copia.nombre, original.nombre);
      expect(copia.codigo, original.codigo);
      expect(copia.precio, 250000.0);
      expect(copia.cantidad, 15);
    });
  });

  group('Modelo InventarioStats', () {
    test('fromJson parsea estadisticas correctamente', () {
      final json = {
        'total_productos': 12,
        'total_unidades': 350,
        'valor_total_inventario': 45000000.0,
      };
      final stats = InventarioStats.fromJson(json);
      expect(stats.totalProductos, 12);
      expect(stats.totalUnidades, 350);
      expect(stats.valorTotalInventario, 45000000.0);
    });

    test('empty() devuelve valores en cero', () {
      final stats = InventarioStats.empty();
      expect(stats.totalProductos, 0);
      expect(stats.totalUnidades, 0);
      expect(stats.valorTotalInventario, 0.0);
    });
  });
}
