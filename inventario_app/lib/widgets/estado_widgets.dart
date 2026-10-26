import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? mensaje;

  const LoadingWidget({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 3,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF52443C),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorDisplayWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;

  const ErrorDisplayWidget({
    super.key,
    required this.mensaje,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppTheme.errorColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Algo salio mal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.onBackground,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF52443C),
                    height: 1.5,
                  ),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final IconData icono;
  final VoidCallback? onAccion;
  final String? labelAccion;

  const EmptyWidget({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.icono = Icons.inventory_2_outlined,
    this.onAccion,
    this.labelAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: AppTheme.primary, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onBackground,
                  ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF52443C),
                    ),
              ),
            ],
            if (onAccion != null && labelAccion != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAccion,
                child: Text(labelAccion!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
