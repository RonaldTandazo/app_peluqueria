import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CitaService {
  final String _baseUrl = dotenv.env['BACKEND_URL']!;

  Future<Map<String, dynamic>> getCitasByCliente(int idCliente) async {
    final url = Uri.parse('$_baseUrl/citas/clientes/$idCliente');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'}
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

  Future<Map<String, dynamic>> cancelCita(int idCita) async {
    final url = Uri.parse('$_baseUrl/citas/delete/$idCita');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      Map<String, dynamic> data = json.decode(response.body);

      if (!data['ok']) {
        throw Exception(data['message'] ?? 'Error al cancelar la cita');
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCita(int idCita, int idCliente, String fecha, TimeOfDay hora) async {
    final url = Uri.parse('$_baseUrl/citas/update/$idCita');
    try {
      final String horaFormateada = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00';
      fecha = fecha.split(' ')[0];

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id_cliente': idCliente, 'fecha': fecha, 'hora': horaFormateada, 'estado': 'Agendada'})
      );

      Map<String, dynamic> data = json.decode(response.body);

      if (!data['ok']) {
        throw Exception(data['message'] ?? 'Error al reagendar la cita');
      }
      
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> storeCita(dataCita) async {
    final url = Uri.parse('$_baseUrl/citas/store');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'data_cita': dataCita})
      );

      Map<String, dynamic> data = json.decode(response.body);

      if (!data['ok']) {
        throw Exception(data['message'] ?? 'Error al agendar la cita');
      }
      
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
