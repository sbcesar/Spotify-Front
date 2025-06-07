import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'Model/Playlist.dart';
import 'Screens/editar_playlist_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/main_screen.dart';
import 'Screens/playlist_screen.dart';
import 'Screens/register_screen.dart';
import 'Screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: { // Tratar de usar const para las rutas
        '/': (context) => StartScreen(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
        '/crearPlaylist': (context) => const CrearPlaylistScreen(),
        '/editarPlaylist': (context) {
          final playlist = ModalRoute.of(context)!.settings.arguments as Playlist;
          return EditarPlaylistScreen(playlist: playlist);
        },
      },
    );
  }
}