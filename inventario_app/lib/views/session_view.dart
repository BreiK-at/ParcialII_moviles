import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../routes/app_router.dart';

class SessionView extends StatefulWidget {
  const SessionView({super.key});

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  final _authService = AuthService();

  String? _nombre;
  String? _email;
  String? _tokenPreview;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await SessionService.obtenerDatosUsuario();
    final token = await SessionService.obtenerToken();
    if (mounted) {
      setState(() {
        _nombre = datos['nombre'];
        _email = datos['email'];
        _tokenPreview = token != null
            ? '${token.substring(0, 20)}...${token.substring(token.length - 10)}'
            : null;
        _cargando = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('Esta accion eliminara los datos de sesion locales. Debes volver a iniciar sesion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _authService.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informacion de sesion'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionCard(
                  title: 'Estado de autenticacion',
                  child: Row(
                    children: [
                      Icon(
                        _tokenPreview != null
                            ? Icons.verified_user_outlined
                            : Icons.no_accounts_outlined,
                        color: _tokenPreview != null
                            ? Colors.green
                            : colorScheme.error,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _tokenPreview != null ? 'Sesion activa' : 'Sin sesion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _tokenPreview != null
                              ? Colors.green
                              : colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Datos del usuario',
                  child: Column(
                    children: [
                      _DataRow(
                          icon: Icons.person_outline,
                          label: 'Nombre',
                          value: _nombre ?? 'No disponible'),
                      const SizedBox(height: 8),
                      _DataRow(
                          icon: Icons.email_outlined,
                          label: 'Correo',
                          value: _email ?? 'No disponible'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Token almacenado',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _tokenPreview != null
                                ? Icons.key_outlined
                                : Icons.key_off_outlined,
                            color: _tokenPreview != null
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _tokenPreview != null
                                ? 'Token presente'
                                : 'Sin token',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _tokenPreview != null
                                  ? colorScheme.primary
                                  : colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      if (_tokenPreview != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _tokenPreview!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'El token completo no se muestra por seguridad.',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesion',
                        style: TextStyle(fontSize: 16)),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DataRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(value, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
