import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Gestiona el almacenamiento local de sesion:
//   - flutter_secure_storage para el access_token (dato sensible cifrado)
//   - shared_preferences para datos de usuario y fallback
class SessionService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'access_token';
  static const _keyNombre = 'session_nombre';
  static const _keyEmail = 'session_email';

  // Guarda token en almacenamiento seguro y datos de usuario en prefs
  static Future<void> guardarSesion({
    required String token,
    required String nombre,
    required String email,
  }) async {
    try {
      await _storage
          .write(key: _keyToken, value: token)
          .timeout(const Duration(seconds: 1));
    } catch (_) {
      // Ignora error de llavero en entornos Linux sin daemon
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNombre, nombre);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyToken, token);
  }

  // Retorna el token almacenado o null si no existe
  static Future<String?> obtenerToken() async {
    try {
      final token = await _storage
          .read(key: _keyToken)
          .timeout(const Duration(seconds: 1), onTimeout: () => null);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      // En caso de que el llavero de Linux este bloqueado o no disponible
    }

    // Fallback con SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Retorna nombre y email guardados en prefs
  static Future<Map<String, String?>> obtenerDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nombre': prefs.getString(_keyNombre),
      'email': prefs.getString(_keyEmail),
    };
  }

  // Verifica si existe una sesion activa
  static Future<bool> haySesionActiva() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  // Elimina todos los datos de sesion (logout)
  static Future<void> cerrarSesion() async {
    try {
      await _storage
          .delete(key: _keyToken)
          .timeout(const Duration(seconds: 1));
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyToken);
  }
}
