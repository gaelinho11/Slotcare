import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      //Llamamos al Wrapper que decide si mostramos Login o Home
      home: const AuthWrapper(),
    );
  }
}

//wrapper decide qué pantalla mostrar
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  String _userRol = 'Client';
  bool _isLoading = true; //Para que no parpadee al iniciar

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final rol = prefs.getString('user_rol');

    setState(() {
      if (token != null) {
        _isLoggedIn = true;
        _userRol = rol ?? 'Client';
      }
      _isLoading = false;
    });
  }

  void _updateAuthStatus(bool isLoggedIn, {String? rol}) {
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userRol = rol ?? 'Client';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn) {
      return HomeScreen(
        userRol: _userRol,
        onLogout: () => _updateAuthStatus(false),
      );
    } else {
      return AuthScreen(onLoginSuccess: _updateAuthStatus);
    }
  }
}
