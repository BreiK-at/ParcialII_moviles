import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../views/dashboard_view.dart';
import '../views/productos_list_view.dart';
import '../views/producto_detail_view.dart';
import '../views/producto_form_view.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String productos = '/productos';
  static const String productoDetalle = '/productos/:id';
  static const String productoNuevo = '/productos/nuevo';
  static const String productoEditar = '/productos/:id/editar';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: AppRoutes.productos,
        builder: (context, state) => const ProductosListView(),
      ),
      GoRoute(
        path: AppRoutes.productoNuevo,
        builder: (context, state) => const ProductoFormView(),
      ),
      GoRoute(
        path: '/productos/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('ID de producto invalido')),
            );
          }
          return ProductoDetailView(productoId: id);
        },
      ),
      GoRoute(
        path: '/productos/:id/editar',
        builder: (context, state) {
          final producto = state.extra as Producto?;
          return ProductoFormView(productoEditar: producto);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Pagina no encontrada')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'La ruta "${state.uri}" no existe',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}
