import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String API_BASE_URL = 'http://127.0.0.1:8000/api/users';

class AuthService {
  //REGISTRO
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final url = Uri.parse('$API_BASE_URL/register/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        }),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registre completat. Ja pots iniciar sessió.',
        };
      } else {
        //Gestionar errores de Django
        final errorData = json.decode(utf8.decode(response.bodyBytes));

        String errorMessage = 'Error al registrar.';
        if (errorData.containsKey('password')) {
          errorMessage = 'Error de Contrasenya: ${errorData['password'][0]}';
        } else if (errorData.containsKey('username')) {
          errorMessage = 'L\'usuari ja existeix.';
        } else if (errorData.containsKey('email')) {
          errorMessage = "Correu electrònic invàlid o en ús.";
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de connexió amb el servidor: $e',
      };
    }
  }

  //LOGIN
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$API_BASE_URL/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'sistema': 'Flutter App',
        }),
      );

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        //Guardar token y rol en el móvil
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['access_token']);
        await prefs.setString('user_rol', responseData['rol']);

        return {
          'success': true,
          'rol': responseData['rol'],
          'message': 'Inici de sessió correcte.',
        };
      } else {
        return {
          'success': false,
          'message': responseData['error'] ?? 'Credencials incorrectes.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de connexió: $e'};
    }
  }
}
