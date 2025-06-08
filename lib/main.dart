import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:spotify_tfg_flutter/Viewmodels/audio_player_viewmodel.dart';
import 'package:spotify_tfg_flutter/Viewmodels/cancion_viewmodel.dart';

import 'Model/Playlist.dart';
import 'Screens/editar_playlist_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/main_screen.dart';
import 'Screens/playlist_screen.dart';
import 'Screens/register_screen.dart';
import 'Screens/start_screen.dart';
import 'Viewmodels/album_viewmodel.dart';
import 'Viewmodels/artista_viewmodel.dart';
import 'Viewmodels/auth_viewmodel.dart';
import 'Viewmodels/playlist_viewmodel.dart';
import 'Viewmodels/usuario_viewmodel.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UsuarioViewModel()),
        ChangeNotifierProvider(create: (_) => PlaylistViewModel()),
        ChangeNotifierProvider(create: (_) => CancionViewModel()),
        ChangeNotifierProvider(create: (_) => AlbumViewModel()),
        ChangeNotifierProvider(create: (_) => ArtistaViewModel()),
        ChangeNotifierProvider(create: (_) => AudioPlayerViewModel()),
      ],
      child: MaterialApp(
        title: 'Spotify App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
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
      ),
    );
  }
}
