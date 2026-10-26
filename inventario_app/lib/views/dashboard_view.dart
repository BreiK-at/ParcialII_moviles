import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../themes/app_theme.dart';
import '../widgets/estado_widgets.dart';
import '../widgets/producto_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ProductoService _service = ProductoService();
  InventarioStats? _stats;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final stats = await _service.obtenerEstadisticas();
      if (mounted) setState(() => _stats = stats);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatValor(double valor) {
    if (valor >= 1000000) {
      return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    }
    if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(0)}K';
    }
    return '\$${valor.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'InventarioApp',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    'Gestion de Inventario',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen del inventario',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onBackground,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_cargando) ...[
                    const SizedBox(
                      height: 140,
                      child: LoadingWidget(mensaje: 'Cargando datos...'),
                    ),
                  ] else if (_error != null) ...[
                    SizedBox(
                      height: 140,
                      child: ErrorDisplayWidget(
                        mensaje: _error!,
                        onReintentar: _cargarEstadisticas,
                      ),
                    ),
                  ] else if (_stats != null) ...[
                    StatCard(
                      titulo: 'Total de productos',
                      valor: _stats!.totalProductos.toString(),
                      icono: Icons.category_outlined,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      titulo: 'Unidades en inventario',
                      valor: _stats!.totalUnidades.toString(),
                      icono: Icons.inventory_outlined,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      titulo: 'Valor total del inventario',
                      valor: _formatValor(_stats!.valorTotalInventario),
                      icono: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Acciones rapidas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onBackground,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _AccionCard(
                    titulo: 'Ver productos',
                    subtitulo: 'Lista completa del inventario',
                    icono: Icons.list_alt_rounded,
                    color: AppTheme.primary,
                    onTap: () => context.go('/productos'),
                  ),
                  const SizedBox(height: 10),
                  _AccionCard(
                    titulo: 'Registrar producto',
                    subtitulo: 'Agregar un nuevo articulo al inventario',
                    icono: Icons.add_box_outlined,
                    color: const Color(0xFF2E7D32),
                    onTap: () => context.go('/productos/nuevo'),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Michael Stiven Vasco Cardenas - 230231047\nElectiva Profesional I - UCEVA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.brown.shade300,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _AccionCard({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.onBackground,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF85736A),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
