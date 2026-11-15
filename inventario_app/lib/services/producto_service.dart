import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/producto.dart';
import 'session_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ProductoService {
  late final Dio _dio;

  ProductoService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor: adjunta el Bearer token en cada peticion
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionService.obtenerToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException e, handler) {
          handler.reject(e);
        },
      ),
    );
  }

  ApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException('La solicitud tardo demasiado. Verifica tu conexion.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(
          'No se pudo conectar al servidor. Verifica que el backend este activo.');
    }
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final mensaje =
        data is Map ? (data['error'] ?? 'Error desconocido') : 'Error desconocido';
    switch (statusCode) {
      case 401:
        return ApiException(
            'Sesion expirada o no autorizada. Inicia sesion nuevamente.',
            statusCode: 401);
      case 404:
        return ApiException(mensaje as String, statusCode: 404);
      case 409:
        return ApiException(mensaje as String, statusCode: 409);
      case 422:
        return ApiException(mensaje as String, statusCode: 422);
      case 500:
        return ApiException('Error interno del servidor. Intenta mas tarde.',
            statusCode: 500);
      default:
        return ApiException(
          'Error HTTP ${statusCode ?? "desconocido"}: $mensaje',
          statusCode: statusCode,
        );
    }
  }

  Future<InventarioStats> obtenerEstadisticas() async {
    try {
      final response = await _dio.get('/productos/stats');
      return InventarioStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await _dio.get('/productos');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => Producto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Producto> obtenerProductoPorId(int id) async {
    try {
      final response = await _dio.get('/productos/$id');
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Producto> crearProducto(Map<String, dynamic> datos) async {
    try {
      final response = await _dio.post('/productos', data: datos);
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Producto> actualizarProducto(
      int id, Map<String, dynamic> datos) async {
    try {
      final response = await _dio.put('/productos/$id', data: datos);
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      await _dio.delete('/productos/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
