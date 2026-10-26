class Producto {
  final int? id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final double precio;
  final int cantidad;
  final String categoria;
  final String? createdAt;
  final String? updatedAt;

  const Producto({
    this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.precio,
    required this.cantidad,
    required this.categoria,
    this.createdAt,
    this.updatedAt,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
      categoria: json['categoria'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'codigo': codigo,
      if (descripcion != null) 'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
    };
  }

  double get valorTotal => precio * cantidad;

  Producto copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? descripcion,
    double? precio,
    int? cantidad,
    String? categoria,
    String? createdAt,
    String? updatedAt,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      categoria: categoria ?? this.categoria,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Producto(id: $id, nombre: $nombre, codigo: $codigo, precio: $precio, cantidad: $cantidad, categoria: $categoria)';
}

class InventarioStats {
  final int totalProductos;
  final int totalUnidades;
  final double valorTotalInventario;

  const InventarioStats({
    required this.totalProductos,
    required this.totalUnidades,
    required this.valorTotalInventario,
  });

  factory InventarioStats.fromJson(Map<String, dynamic> json) {
    return InventarioStats(
      totalProductos: (json['total_productos'] as num?)?.toInt() ?? 0,
      totalUnidades: (json['total_unidades'] as num?)?.toInt() ?? 0,
      valorTotalInventario:
          (json['valor_total_inventario'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static InventarioStats empty() => const InventarioStats(
        totalProductos: 0,
        totalUnidades: 0,
        valorTotalInventario: 0.0,
      );
}
