import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Inicio de sesión sin contraseña: Supabase manda un código al correo
// y la app lo verifica. La primera vez se crea el perfil automáticamente
// (trigger crear_perfil en 01_esquema.sql).
class AuthService {
  static final _auth = Supabase.instance.client.auth;
  static final _db = Supabase.instance.client;

  static User? get usuario => _auth.currentUser;
  static bool get haySesion => usuario != null;

  // Avisa cada vez que se inicia o se cierra sesión
  static Stream<AuthState> get cambios => _auth.onAuthStateChange;

  static bool esCorreoTec(String correo) =>
      RegExp(r'^[^@\s]+@tec\.mx$', caseSensitive: false).hasMatch(correo.trim());

  static Future<void> enviarCodigo(String correo) {
    return _auth.signInWithOtp(email: correo.trim().toLowerCase());
  } // enviarCodigo()

  static Future<void> verificarCodigo(String correo, String codigo) {
    return _auth.verifyOTP(
      type: OtpType.email,
      email: correo.trim().toLowerCase(),
      token: codigo.trim(),
    );
  } // verificarCodigo()

  static Future<void> cerrarSesion() => _auth.signOut();

  // {correo, rol} del usuario actual, o null si no hay sesión
  static Future<Map<String, dynamic>?> perfil() async {
    final id = usuario?.id;
    if (id == null) return null;
    return _db.from('perfiles').select('correo, rol').eq('id', id).maybeSingle();
  } // perfil()

  // Convierte los errores de Supabase en mensajes para el usuario
  static String mensajeDeError(Object error) {
    debugPrint('[Auth] $error'); // detalle para depurar en la consola
    if (error is AuthException) {
      final m = error.message.toLowerCase();
      if (error.statusCode == '429' || m.contains('rate limit') || m.contains('security purposes')) {
        return 'Se pidieron demasiados códigos. Espera unos minutos e inténtalo de nuevo.';
      }
      // El correo de Supabase de fábrica solo envía a miembros del equipo
      if (m.contains('not authorized')) {
        return 'Este correo todavía no puede recibir códigos (la app está en pruebas).';
      }
      if (m.contains('expired') || m.contains('invalid')) {
        return 'El código no es válido o ya expiró. Revisa el correo más reciente o pide uno nuevo.';
      }
    } // if
    return 'No se pudo completar. Revisa tu conexión e inténtalo de nuevo.';
  } // mensajeDeError()
} // AuthService
