import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../themes/app_theme.dart';

class ProductoFormView extends StatefulWidget {
  final Producto? productoEditar;

  const ProductoFormView({super.key, this.productoEditar});

  @override
  State<ProductoFormView> createState() => _ProductoFormViewState();
}

class _ProductoFormViewState extends State<ProductoFormView> {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _service = ProductoService();
  bool _guardando = false;

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _cantidadCtrl;
  late final TextEditingController _categoriaCtrl;

  bool get _esEdicion => widget.productoEditar != null;

  static const List<String> _categorias = [
    'Computadores',
    'Pantallas',
    'Perifericos',
    'Almacenamiento',
    'Componentes',
    'Audio',
    'Mobiliario',
    'Video',
    'Impresion',
    'Redes',
    'Accesorios',
    'Diseno',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.productoEditar;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _codigoCtrl = TextEditingController(text: p?.codigo ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _precioCtrl = TextEditingController(
        text: p != null ? p.precio.toStringAsFixed(2) : '');
    _cantidadCtrl =
        TextEditingController(text: p != null ? p.cantidad.toString() : '');
    _categoriaCtrl = TextEditingController(text: p?.categoria ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _cantidadCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final datos = {
        'nombre': _nombreCtrl.text.trim(),
        'codigo': _codigoCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),
        'precio': double.parse(_precioCtrl.text.trim()),
        'cantidad': int.parse(_cantidadCtrl.text.trim()),
        'categoria': _categoriaCtrl.text.trim(),
      };

      if (_esEdicion) {
        await _service.actualizarProducto(widget.productoEditar!.id!, datos);
      } else {
        await _service.crearProducto(datos);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Producto actualizado exitosamente'
                  : 'Producto registrado exitosamente',
            ),
          ),
        );
        context.go('/productos');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/productos'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionLabel(label: 'Informacion basica'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Codigo del producto',
                  hintText: 'Ej: PRD-001',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El codigo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripcion (opcional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Datos de inventario'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixIcon: Icon(Icons.attach_money_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo requerido';
                        }
                        final num = double.tryParse(v.trim());
                        if (num == null || num < 0) {
                          return 'Precio invalido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        prefixIcon: Icon(Icons.inventory_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Campo requerido';
                        }
                        final num = int.tryParse(v.trim());
                        if (num == null || num < 0) {
                          return 'Cantidad invalida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _categoriaCtrl.text),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) return _categorias;
                  return _categorias.where((c) => c
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (value) {
                  _categoriaCtrl.text = value;
                },
                fieldViewBuilder: (context, ctrl, focusNode, onSubmitted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (ctrl.text != _categoriaCtrl.text) {
                      ctrl.text = _categoriaCtrl.text;
                    }
                  });
                  return TextFormField(
                    controller: ctrl,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'La categoria es obligatoria';
                      }
                      _categoriaCtrl.text = v.trim();
                      return null;
                    },
                    onFieldSubmitted: (_) => onSubmitted(),
                  );
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        _esEdicion ? Icons.save_rounded : Icons.add_rounded,
                      ),
                label: Text(_guardando
                    ? 'Guardando...'
                    : (_esEdicion ? 'Guardar cambios' : 'Registrar producto')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _guardando ? null : () => context.go('/productos'),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.primary,
        letterSpacing: 0.3,
      ),
    );
  }
}
