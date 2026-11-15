import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'session_service.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: 10000),
        receiveTimeout: const Duration(milliseconds: 10000),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  AuthException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const AuthException('La solicitud tardo demasiado. Verifica tu conexion.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const AuthException(
          'No se pudo conectar al servidor. Verifica que el backend este activo.');
    }
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final mensaje =
        data is Map ? (data['error'] ?? 'Error desconocido') : 'Error desconocido';
    if (statusCode == 401) {
      return AuthException(mensaje.toString(), statusCode: 401);
    }
    if (statusCode == 422) {
      return AuthException(mensaje.toString(), statusCode: 422);
    }
    return AuthException(
      'Error HTTP ${statusCode ?? "desconocido"}: $mensaje',
      statusCode: statusCode,
    );
  }

  // Realiza el login, persiste la sesion y retorna los datos del usuario
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final usuario = data['usuario'] as Map<String, dynamic>;
      await SessionService.guardarSesion(
        token: token,
        nombre: usuario['nombre'] as String,
        email: usuario['email'] as String,
      );
      return usuario;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Cierra sesion eliminando todos los datos locales
  Future<void> logout() async {
    await SessionService.cerrarSesion();
  }
}
