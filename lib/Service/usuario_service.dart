import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../DTO/UsuarioBibliotecaMostrableDTO.dart';
import '../DTO/UsuarioDTO.dart';

class UsuarioService {

  final String baseUrl = 'https://music-sound.onrender.com/usuario';

  Future<UsuarioDTO> obtenerUsuarioActual() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.get(
      Uri.parse('$baseUrl/perfil'),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return UsuarioDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("No se pudo obtener el usuario actual");
    }
  }

  Future<UsuarioBibliotecaMostrableDTO> obtenerBibliotecaMostrable() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.get(
      Uri.parse('$baseUrl/biblioteca'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      return UsuarioBibliotecaMostrableDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al obtener la biblioteca mostrable");
    }
  }

}
