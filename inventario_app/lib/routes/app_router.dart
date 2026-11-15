import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../services/session_service.dart';
import '../views/login_view.dart';
import '../views/dashboard_view.dart';
import '../views/session_view.dart';
import '../views/productos_list_view.dart';
import '../views/producto_detail_view.dart';
import '../views/producto_form_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String session = '/sesion';
  static const String productos = '/productos';
  static const String productoDetalle = '/productos/:id';
  static const String productoNuevo = '/productos/nuevo';
  static const String productoEditar = '/productos/:id/editar';
}

// Rutas que no requieren autenticacion
const _publicRoutes = [AppRoutes.login];

GoRouter createRouter({String initialLocation = AppRoutes.dashboard}) {
  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final esPublica = _publicRoutes.contains(state.matchedLocation);
      final haySesion = await SessionService.haySesionActiva();

      // Si no hay sesion y la ruta es protegida, redirige al login
      if (!haySesion && !esPublica) {
        return AppRoutes.login;
      }
      // Si hay sesion y el usuario intenta ir al login, redirige al dashboard
      if (haySesion && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const SessionView(),
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
