import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AutenticacionService {
  final String _baseUrl = dotenv.env['BACKEND_URL']!;

  Future<Map<String, dynamic>> loginCliente(String identificacion) async {
    final url = Uri.parse('$_baseUrl/auth/login_clientes');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identificacion': identificacion})
      );

      Map<String, dynamic> data = json.decode(response.body);
      if (!data['ok']) {
        throw (data['message'] ?? 'Error al verificar cliente');
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }
}
