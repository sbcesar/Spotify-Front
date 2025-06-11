import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Viewmodels/usuario_viewmodel.dart';
import 'library_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'premium_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuarioViewModel>().cargarUsuarioActual();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final usuarioVM = context.watch<UsuarioViewModel>();

    final esUser = usuarioVM.usuarioActual?.role == "USER";

    final List<Widget> screens = [
      const LibraryScreen(),
      const HomeScreen(),
      const SearchScreen(),
      if (esUser) const PremiumScreen(),
    ];

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Biblioteca'),
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
      if (esUser) const BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Premium'),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFF2C698D),
        unselectedItemColor: Colors.white70,
        items: items,
      ),
    );
  }
}
