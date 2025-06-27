import 'package:app_peluqueria_mobile/screens/Autenticacion/login_cliente.dart';
import 'package:app_peluqueria_mobile/screens/Cita/cita_agendar.dart';
import 'package:app_peluqueria_mobile/screens/Cita/cita_detalle.dart';
import 'package:app_peluqueria_mobile/services/Cita/CitaService.dart';
import 'package:app_peluqueria_mobile/utils/AutenticacionRepository.dart';
import 'package:flutter/material.dart';

class CitaScreen extends StatefulWidget {
  const CitaScreen({super.key});

  @override
  State<CitaScreen> createState() => _CitaScreenState();
}

class _CitaScreenState extends State<CitaScreen> {
  late Future<List<Map<String, dynamic>>> _citasFuture;
  int? _clienteId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final AutenticacionRepository authRepository = AutenticacionRepository();
    final userData = await authRepository.getCurrentUser();
    if (userData != null && userData['id_cliente'] != null) {
      setState(() {
        _clienteId = userData['id_cliente'] as int?;
        if (_clienteId != null) {
          _citasFuture = CitaService().getCitasByCliente(_clienteId!).then((response) => response['data'].cast<Map<String, dynamic>>());
        }
      });
    } else {
      
    }
  }

  void _refreshAppointments() {
    if (_clienteId != null) {
      setState(() {
        _citasFuture = CitaService().getCitasByCliente(_clienteId!).then((response) => response['data'].cast<Map<String, dynamic>>());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: AutenticacionRepository().getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (userSnapshot.hasError) {
            return Center(child: Text('Error al cargar datos del usuario: ${userSnapshot.error}'));
          } else if (userSnapshot.hasData && userSnapshot.data != null) {
            final clienteData = userSnapshot.data!;
            if (_clienteId == null) {
              _clienteId = clienteData['id_cliente'] as int?;
              if (_clienteId == null) {
                return const Center(child: Text('ID de cliente no disponible.'));
              }
              _citasFuture = CitaService().getCitasByCliente(_clienteId!).then((response) => response['data'].cast<Map<String, dynamic>>());
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text.rich(
                      TextSpan(
                        text: 'Cliente: ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${clienteData['nombre']} ${clienteData['apellido']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text.rich(
                      TextSpan(
                        text: 'Identificación: ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${clienteData['identificacion']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sus Próximas Citas:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _citasFuture,
                      builder: (context, appointmentSnapshot) {
                        if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (appointmentSnapshot.hasError) {
                          return Center(child: Text('Error al cargar citas: ${appointmentSnapshot.error}\nPor favor, intente de nuevo.'));
                        } else if (appointmentSnapshot.hasData && appointmentSnapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            itemCount: appointmentSnapshot.data!.length,
                            itemBuilder: (context, index) {
                              final cita = appointmentSnapshot.data![index];

                              Color iconColor;
                              final DateTime citaDate = DateTime.parse(cita['fecha']);
                              final bool isPastCita = citaDate.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));

                              if (cita['estado'] == 'Cancelada' || cita['estado'] == 'No Asistió' || isPastCita) {
                                iconColor = Colors.red;
                              } else if (cita['estado'] == 'Completada') {
                                iconColor = Colors.green;
                              } else {
                                iconColor = Colors.blue;
                              }

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                key: ValueKey<int?>(cita['id_cita'] as int?),
                                elevation: 3,
                                child: ListTile(
                                  leading: Icon(Icons.calendar_today, color: iconColor),
                                  title: Text(
                                    '${cita['estado']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Fecha: ${cita['fecha']} \nHora: ${cita['hora']}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                                    onPressed: () async {
                                      final bool? result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CitaDetalle(cita: cita),
                                        ),
                                      );

                                      if (result == true) {
                                        _refreshAppointments();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text('No tiene citas programadas.'));
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No se encontraron datos de usuario. Por favor, inicie sesión.'));
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'createCitaBtn',
            onPressed: () async {
              if (_clienteId != null) {
                final bool? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CitaAgendar(clienteId: _clienteId!),
                  ),
                );
                if (result == true) {
                  _refreshAppointments();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No se pudo obtener el ID del cliente para crear una cita.')),
                );
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'logoutBtn',
            onPressed: () async {
              final AutenticacionRepository authRepository = AutenticacionRepository();
              await authRepository.logout();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginCliente()),
              );
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}