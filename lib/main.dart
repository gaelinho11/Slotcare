import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Per guardar el token

// =========================================================================
// API
const String API_BASE_URL = 'http://127.0.0.1:8000/api/users'; 

// =========================================================================
// 2. Auntentificació api

class AuthService {
  // Funció per cridar l'endpoint /register/
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final url = Uri.parse('$API_BASE_URL/register/');
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
      // 201 Created (Registre correcte)
      return {'success': true, 'message': 'Registre completat. Ja pots iniciar sessió.'};
    } else {
      // 400 Bad Request o altres errors
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      
      // chivatos de quan em deia uncallable
      print('--- ERROR DJANGO DETALLAT (400) ---');
      print(errorData); // Això imprimirà el JSON que Django envia
      print('-------------------------------------');


      //missatge si no es sap l'error
      String errorMessage = 'Error al registrar. Revisar camps obligatoris i contrasenya.'; 

      if (errorData.containsKey('password')) {
        errorMessage = 'Error de Contrasenya: ${errorData['password'][0]}';
      } else if (errorData.containsKey('username')) {
        errorMessage = 'Error d\'Usuari: L\'usuari ja existeix.';
      } else if (errorData.containsKey('first_name') || errorData.containsKey('last_name') || errorData.containsKey('email')) {
        errorMessage = "Camps obligatoris buits. Nom, Cognoms o Correu invàlids.";
      } else if (errorData.containsKey('non_field_errors')) {
        errorMessage = 'Error de dades: ${errorData['non_field_errors'][0]}';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }

  // Funció per cridar l'endpoint /login/
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$API_BASE_URL/login/');
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
      // 200 OK (Login correcte)
      final String token = responseData['access_token'];
      final String rol = responseData['rol'];

      // Guardem el token i el rol
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_rol', rol);

      return {'success': true, 'rol': rol, 'message': 'Inici de sessió correcte.'};
    } else if (response.statusCode == 403) {
      // 403 Forbidden (Compte bloquejat - Requisit 5)
      return {'success': false, 'message': responseData['error'] ?? 'Accés denegat.'};
    } else {
      // 401 Unauthorized (Credencials incorrectes)
      return {'success': false, 'message': 'Nom d\'usuari o contrasenya invàlids.'};
    }
  }
}

// =========================================================================
// 3. APLICACIÓ PRINCIPAL

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlotCare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), 
          filled: false,
          fillColor: Colors.transparent,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// =========================================================================
// 4. WRAPPER

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  String _userRol = 'Client';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Comprova si hi ha un token guardat
  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final rol = prefs.getString('user_rol');
    
    if (token != null) {
      setState(() {
        _isLoggedIn = true;
        _userRol = rol ?? 'Client';
      });
    }
  }

  // Mètode per canviar l'estat de la sessió
  void _setLoggedIn(bool isLoggedIn, {String? rol}) {
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userRol = rol ?? 'Client';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      // Si l'usuari està autenticat, mostra la Home amb el seu Rol
      return HomeScreen(userRol: _userRol, onLogout: () => _setLoggedIn(false));
    } else {
      // Altres, mostra la pantalla de Login/Registre
      return AuthScreen(onLoginSuccess: _setLoggedIn);
    }
  }
}

// =========================================================================
// 5. pantalla principal

class AuthScreen extends StatefulWidget {
  final Function(bool, {String rol}) onLoginSuccess;
  const AuthScreen({required this.onLoginSuccess, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  void toggleScreen() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Inici de Sessió' : 'Registre')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SlotCare',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 40),
              isLogin 
                  ? LoginScreen(onLoginSuccess: widget.onLoginSuccess) 
                  : RegisterScreen(onRegisterComplete: toggleScreen),
              const SizedBox(height: 20),
              TextButton(
                onPressed: toggleScreen,
                child: Text(
                  isLogin ? 'No tens compte? Registra\'t' : 'Ja tens compte? Inicia Sessió',
                  style: TextStyle(color: Theme.of(context).primaryColor), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 6. login

class LoginScreen extends StatefulWidget {
  final Function(bool, {String rol}) onLoginSuccess;
  const LoginScreen({required this.onLoginSuccess, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final result = await _authService.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        widget.onLoginSuccess(true, rol: result['rol']);
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Nom d\'Usuari'), 
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introdueix el nom d\'usuari';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contrasenya'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introdueix la contrasenya';
              }
              return null;
            },
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red), 
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('INICIAR SESSIÓ'),
                ),
        ],
      ),
    );
  }
}

// =========================================================================
// 7. FORMULARI DE REGISTRE

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterComplete;
  const RegisterScreen({required this.onRegisterComplete, super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _registerMessage = '';
  bool _isLoading = false;

  // Regex per verificar la contrasenya (Simula el validador estricte de Django)
  final String passwordRegex = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\$;\.\-_*]).{8,}$';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _registerMessage = '';
      });

      final result = await _authService.register(
        username: _usernameController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
      );

      setState(() {
        _isLoading = false;
        _registerMessage = result['message'];
      });

      if (result['success']) {
        // espera 2 segons per a que l'usuari llegeixi el missatge d'èxit
        await Future.delayed(const Duration(seconds: 2)); 
        widget.onRegisterComplete(); // Torna a la pantalla de Login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Noms i Usuari
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Nom d\'Usuari'),
            validator: (v) => v!.isEmpty ? 'Nom d\'usuari obligatori' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'Nom'),
            validator: (v) => v!.isEmpty ? 'Nom obligatori' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Cognoms'),
            validator: (v) => v!.isEmpty ? 'Cognoms obligatoris' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Correu Electrònic'),
            validator: (v) => v!.isEmpty || !v.contains('@') ? 'Correu invàlid' : null,
          ),
          const SizedBox(height: 10),
          // Contrasenya amb validació estricta (Requisit 2)
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contrasenya Segura'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contrasenya és obligatòria';
              }
              // validació de la contrassenya
              if (!RegExp(passwordRegex).hasMatch(value)) {
                return "Req: 8+ caràcters, Majús., Minús., Núm., Símbol (\$;._-*)";
              }
              return null;
            },
          ),
          if (_registerMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _registerMessage,
                style: TextStyle(
                  color: _registerMessage.contains('correcte') ? Colors.green : Colors.red, 
                  fontWeight: FontWeight.normal
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('REGISTRAR COMPTE'),
                ),
        ],
      ),
    );
  }
}

// =========================================================================
// 8. home temporal

class HomeScreen extends StatelessWidget {
  final String userRol;
  final VoidCallback onLogout;
  
  const HomeScreen({required this.userRol, required this.onLogout, super.key});

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_rol');
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SlotCare - Àrea Privada'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Tancar Sessió',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Benvingut a SlotCare.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal), 
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'El teu nivell d\'accés és:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Chip(
                label: Text(
                  userRol.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16), // Més simple
                ),
                backgroundColor: userRol == 'Superadmin' ? Colors.red[300] : (userRol == 'Admin' ? Colors.orange[300] : Colors.blue[300]), 
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}