import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../themes/app_theme.dart';
import '../widgets/estado_widgets.dart';
import '../widgets/producto_card.dart';

class ProductosListView extends StatefulWidget {
  const ProductosListView({super.key});

  @override
  State<ProductosListView> createState() => _ProductosListViewState();
}

class _ProductosListViewState extends State<ProductosListView> {
  final ProductoService _service = ProductoService();
  List<Producto> _productos = [];
  List<Producto> _filtrados = [];
  bool _cargando = true;
  String? _error;
  final TextEditingController _busquedaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    _busquedaCtrl.addListener(_filtrar);
  }

  @override
  void dispose() {
    _busquedaCtrl.removeListener(_filtrar);
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _service.obtenerProductos();
      if (mounted) {
        setState(() {
          _productos = lista;
          _filtrados = lista;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _filtrar() {
    final q = _busquedaCtrl.text.toLowerCase();
    setState(() {
      _filtrados = _productos.where((p) {
        return p.nombre.toLowerCase().contains(q) ||
            p.codigo.toLowerCase().contains(q) ||
            p.categoria.toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _confirmarEliminar(Producto producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
            '¿Deseas eliminar "${producto.nombre}"? Esta accion no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _service.eliminarProducto(producto.id!);
        _cargarProductos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado correctamente')),
          );
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
        title: const Text('Productos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargarProductos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/productos/nuevo');
          _cargarProductos();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo'),
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _busquedaCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, codigo o categoria...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: Builder(builder: (context) {
              if (_cargando) {
                return const LoadingWidget(mensaje: 'Cargando productos...');
              }
              if (_error != null) {
                return ErrorDisplayWidget(
                  mensaje: _error!,
                  onReintentar: _cargarProductos,
                );
              }
              if (_filtrados.isEmpty) {
                return EmptyWidget(
                  titulo: _busquedaCtrl.text.isEmpty
                      ? 'No hay productos registrados'
                      : 'Sin resultados para "${_busquedaCtrl.text}"',
                  subtitulo: _busquedaCtrl.text.isEmpty
                      ? 'Agrega tu primer producto con el boton de abajo'
                      : 'Intenta con otro termino de busqueda',
                  icono: Icons.search_off_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: _cargarProductos,
                color: AppTheme.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtrados.length,
                  itemBuilder: (context, index) {
                    final producto = _filtrados[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProductoCard(
                        producto: producto,
                        onTap: () async {
                          await context.push('/productos/${producto.id}');
                          _cargarProductos();
                        },
                        onEditar: () async {
                          await context.push(
                            '/productos/${producto.id}/editar',
                            extra: producto,
                          );
                          _cargarProductos();
                        },
                        onEliminar: () => _confirmarEliminar(producto),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
