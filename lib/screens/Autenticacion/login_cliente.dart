import 'package:flutter/material.dart';
import 'package:app_peluqueria_mobile/utils/AutenticacionRepository.dart';
import 'package:app_peluqueria_mobile/screens/Cita/cita_screen.dart';

class LoginCliente extends StatefulWidget {
  const LoginCliente({super.key});

  @override
  State<LoginCliente> createState() => _LoginCliente();
}

class _LoginCliente extends State<LoginCliente> {
  final TextEditingController _identificacionInput = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AutenticacionRepository _authRepository = AutenticacionRepository();
  bool _isLoading = false;

  void _authenticateClient() async{
    if (_formKey.currentState!.validate()) {
      final String identificacion = _identificacionInput.text.trim();
      
      setState(() {
        _isLoading = true;
      });

      try {
        Map<String, dynamic> clientData = await _authRepository.login(identificacion);
        
        await ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(clientData['message'])),
        ).closed; 

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CitaScreen()), 
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Peluquería Anita', 
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ingresa tu número de cédula para continuar',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  child: TextFormField(
                    controller: _identificacionInput,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.labelMedium,
                    decoration: InputDecoration(
                      labelText: 'Número de Cédula',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu número de documento';
                      }
                      
                      if (value.length < 10 || value.length > 10) {
                        return 'Longitud no válida';
                      }
                      return null;
                    },
                  ),  
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null:_authenticateClient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: _isLoading ? CircularProgressIndicator(color: Colors.white) 
                    : Text(
                      'Ingresar',
                      style: TextStyle(fontSize: 15),
                    )
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}