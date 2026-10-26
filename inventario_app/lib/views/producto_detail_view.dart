import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../themes/app_theme.dart';
import '../widgets/estado_widgets.dart';

class ProductoDetailView extends StatefulWidget {
  final int productoId;

  const ProductoDetailView({super.key, required this.productoId});

  @override
  State<ProductoDetailView> createState() => _ProductoDetailViewState();
}

class _ProductoDetailViewState extends State<ProductoDetailView> {
  final ProductoService _service = ProductoService();
  Producto? _producto;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final p = await _service.obtenerProductoPorId(widget.productoId);
      if (mounted) setState(() => _producto = p);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
            '¿Deseas eliminar "${_producto?.nombre}"? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _service.eliminarProducto(widget.productoId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado exitosamente')),
          );
          context.go('/productos');
        }
      } on ApiException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.message}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_producto?.nombre ?? 'Detalle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/productos'),
        ),
        actions: [
          if (_producto != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () async {
                await context.push(
                  '/productos/${_producto!.id}/editar',
                  extra: _producto,
                );
                _cargar();
              },
            ),
          if (_producto != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.white,
              tooltip: 'Eliminar',
              onPressed: _eliminar,
            ),
        ],
      ),
      body: Builder(builder: (context) {
        if (_cargando) {
          return const LoadingWidget(mensaje: 'Cargando detalle...');
        }
        if (_error != null) {
          return ErrorDisplayWidget(mensaje: _error!, onReintentar: _cargar);
        }
        if (_producto == null) {
          return const EmptyWidget(titulo: 'Producto no encontrado');
        }

        final p = _producto!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.categoria,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          p.codigo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (p.descripcion != null && p.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        p.descripcion!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Datos numericos
              Row(
                children: [
                  Expanded(
                    child: _DataCard(
                      titulo: 'Precio unitario',
                      valor: '\$${_formatPrecio(p.precio)}',
                      icono: Icons.attach_money_rounded,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DataCard(
                      titulo: 'Unidades',
                      valor: p.cantidad.toString(),
                      icono: Icons.inventory_outlined,
                      color: p.cantidad > 0
                          ? AppTheme.primary
                          : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DataCard(
                titulo: 'Valor total en inventario',
                valor: '\$${_formatPrecio(p.valorTotal)}',
                icono: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF6A1B9A),
                ancho: true,
              ),
              const SizedBox(height: 20),
              // Info adicional
              _InfoSection(titulo: 'ID del producto', valor: '#${p.id}'),
              _InfoSection(titulo: 'Codigo', valor: p.codigo),
              _InfoSection(titulo: 'Categoria', valor: p.categoria),
              if (p.createdAt != null)
                _InfoSection(titulo: 'Registrado el', valor: _formatFecha(p.createdAt!)),
              if (p.updatedAt != null)
                _InfoSection(titulo: 'Ultima actualizacion', valor: _formatFecha(p.updatedAt!)),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  String _formatPrecio(double precio) {
    final formatted = precio.toStringAsFixed(0);
    final buffer = StringBuffer();
    final chars = formatted.split('').reversed.toList();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write('.');
      buffer.write(chars[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  String _formatFecha(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _DataCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final bool ancho;

  const _DataCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.ancho = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style:
                        TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
                Text(valor,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String titulo;
  final String valor;

  const _InfoSection({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF85736A),
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(valor,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onBackground,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
