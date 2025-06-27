import 'package:flutter/material.dart';
import 'package:app_peluqueria_mobile/services/Cita/CitaService.dart';

class CitaDetalle extends StatefulWidget {
  final Map<String, dynamic> cita;

  const CitaDetalle({super.key, required this.cita});

  @override
  State<CitaDetalle> createState() => _CitaDetalleState();
}

class _CitaDetalleState extends State<CitaDetalle> {
  late int _idCliente;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _dateController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _idCliente = widget.cita['id_cliente'];
    _selectedDate = DateTime.parse(widget.cita['fecha']);
    final List<String> timeParts = widget.cita['hora'].split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    _dateController = TextEditingController(text: _formatDate(_selectedDate));
    _timeController = TextEditingController(text: _formatTime(_selectedTime));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _formatTime(_selectedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDateInPast = _selectedDate.isBefore(DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0
    ));

    final bool canModify = widget.cita['estado'] == 'Agendada' && !isDateInPast;
    final String message = widget.cita['estado'] == 'Cancelada' ? 
      'La cita no puede ser modificada ya que fue cancelada':isDateInPast ? 
      'La cita no puede ser modificada ni cancelada ya que está vencida':widget.cita['estado'] == 'En Proceso' ? 
      'El cliente esta siendo atendido':widget.cita['estado'] == 'No Asistió' ? 
      'El cliente no asistió a la cita':widget.cita['estado'] == 'Completada' ? 'El cliente fue atendido':''; 

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de la Cita',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado: ${widget.cita['estado']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            if (canModify) ...[
              const Text(
                'Editar Fecha y Hora:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha de la Cita',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Hora de la Cita',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 30),
            ] else ...[
              Text(
                'Fecha: ${_formatDate(_selectedDate)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Hora: ${_formatTime(_selectedTime)}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              Text(message,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (canModify)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final int? citaId = widget.cita['id_cita'] as int?;
                          if (citaId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID de cita no disponible para cancelar.')),
                            );
                            return;
                          }

                          await CitaService().cancelCita(citaId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cita cancelada exitosamente!')),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al cancelar la cita: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        'Cancelar Cita',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                    ),
                  ),
                const SizedBox(width: 15),
                if (canModify)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final int? citaId = widget.cita['id_cita'] as int?;
                          if (citaId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ID de cita no disponible para actualizar.')),
                            );
                            return;
                          }

                          await CitaService().updateCita(citaId, _idCliente, _selectedDate.toString(), _selectedTime);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cita actualizada exitosamente!')),
                          );
                          Navigator.pop(context, true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar la cita: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        'Guardar',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}