import 'package:app_peluqueria_mobile/services/Autenticacion/AutenticacionService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

class AutenticacionRepository {
  final AutenticacionService _authService = AutenticacionService();

  Future<Map<String, dynamic>> login(String identificacion) async {
    try {
      Map<String, dynamic> response = await _authService.loginCliente(identificacion);

      final String token = response['data'] as String;

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      final Map<String, dynamic> clientInfo = {
        'id_cliente': decodedToken['id_cliente'],
        'nombre': decodedToken['nombre'],
        'apellido': decodedToken['apellido'],
        'identificacion': decodedToken['identificacion']
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clienteData', json.encode(clientInfo));
      await prefs.setString('token', token);

      return response;
    } catch (e) {
      rethrow; 
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clienteData');
    await prefs.remove('token');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('clienteData');
    if (userDataString != null) {
      return json.decode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }
}
