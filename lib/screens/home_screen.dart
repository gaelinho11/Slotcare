import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/time_service.dart';

class HomeScreen extends StatefulWidget {
  final String userRol;
  final VoidCallback onLogout;

  const HomeScreen({required this.userRol, required this.onLogout, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TimeService _timeService = TimeService();

  @override
  void initState() {
    super.initState();
    _timeService.empezarContador();
    _timeService.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_rol');
    widget.onLogout();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3 Pestañas: Juegos, Terapeutas, Perfil
    final List<Widget> pages = [
      const DashboardView(),
      const TherapistsView(),
      ProfileView(userRol: widget.userRol),
    ];

    return Scaffold(
      backgroundColor:
          Colors.grey.shade100, // Fondo sutil para resaltar las tarjetas
      appBar: AppBar(
        title: const Text(
          'SlotCare',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // CRONÓMETRO
          Container(
            margin: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, size: 18, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  _timeService.obtenerTiempoFormateado(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // BOTÓN CERRAR SESIÓN
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Jugar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Terapeutas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// --- VISTA 1: DASHBOARD (MODIFICADA PARA LOGO GRANDE) ---
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CONTENEDOR DEL LOGO DE SLOTCARE - AHORA MÁS GRANDE Y SIN PADDING
          Container(
            // --- CAMBIO 1: Eliminado el padding para que la imagen ocupe el cuadrado entero ---
            // padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            // Llamada a la imagen real logo.png
            child: Image.asset(
              'assets/logo.png',
              // --- CAMBIO 2: Aumentado el height de 80 a 110 para que el logo sea más grande ---
              height: 110,
              // --- AÑADIDO: BoxFit.contain asegura que todo el logo sea visible sin deformarlo ---
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Si falla al cargar la imagen, pone un icono provisional
                return const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Benvingut a SlotCare",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Tria una simulació per començar",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 40),

          // JUEGO 1: SLOT MACHINE
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                print("Click en Slot Machine");
              },
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 25,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.casino, size: 40, color: Colors.deepPurple),
                    SizedBox(width: 20),
                    Text(
                      "Slot Machine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // JUEGO 2: BLACKJACK
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                print("Click en Blackjack");
              },
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 25,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.style, size: 40, color: Colors.deepPurple),
                    SizedBox(width: 20),
                    Text(
                      "Blackjack",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- VISTA 2: TERAPEUTAS ---
class TherapistsView extends StatelessWidget {
  const TherapistsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "El teu suport",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Contacta amb professionals especialitzats en joc responsable. Estan aquí per ajudar-te.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 20),

        _buildTherapistCard(
          "Exemple terapeuta",
          "Especialista en addiccions",
          Icons.person,
        ),
        const SizedBox(height: 15),
        _buildTherapistCard(
          "Exemple terapeuta",
          "Psicòloga clínica",
          Icons.person_3,
        ),
        const SizedBox(height: 15),
        _buildTherapistCard(
          "Exemple associació",
          "Suport grupal i familiar",
          Icons.groups,
        ),
      ],
    );
  }

  Widget _buildTherapistCard(String name, String specialty, IconData iconData) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(iconData, size: 35, color: Colors.deepPurple),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    specialty,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                print("Contactar amb $name");
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- VISTA 3: PERFIL ---
class ProfileView extends StatelessWidget {
  final String userRol;
  const ProfileView({required this.userRol, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.person, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            "Usuari Connectat",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Chip(
            label: Text(
              userRol.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.deepPurple.shade300,
          ),
        ),
        const Divider(height: 40, thickness: 1),
        const ListTile(
          leading: Icon(Icons.timer, color: Colors.deepPurple, size: 30),
          title: Text(
            "Temps jugat avui",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("Sessió activa"),
        ),
      ],
    );
  }
}
