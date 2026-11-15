import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Gestiona el almacenamiento local de sesion:
//   - flutter_secure_storage para el access_token (dato sensible)
//   - shared_preferences para nombre y email del usuario (datos no sensibles)
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
    await _storage.write(key: _keyToken, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNombre, nombre);
    await prefs.setString(_keyEmail, email);
  }

  // Retorna el token almacenado o null si no existe
  static Future<String?> obtenerToken() async {
    return _storage.read(key: _keyToken);
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
    await _storage.delete(key: _keyToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyEmail);
  }
}
