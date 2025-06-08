import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/Artista.dart';

class ArtistaService {
  final String baseUrl = 'https://music-sound.onrender.com';

  Future<List<Artista>> buscarArtistas(String query) async {
    final url = Uri.parse('$baseUrl/spotify/buscar/artistas?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Artista.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar artistas');
    }
  }

  Future<Artista> obtenerArtistaPorId(String id) async {
    final url = Uri.parse('$baseUrl/artistas/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Artista.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener artista');
    }
  }

  Future<List<String>> obtenerLikedArtistas(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/perfil'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final liked = (data['biblioteca']['likedArtistas'] as List).cast<String>();
      return liked;
    } else {
      throw Exception('Error al obtener artistas likeados');
    }
  }

  Future<void> darLike(String idToken, String artistaId) async {
    final url = Uri.parse('$baseUrl/artistas/like/$artistaId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al dar like');
  }

  Future<void> quitarLike(String idToken, String artistaId) async {
    final url = Uri.parse('$baseUrl/artistas/like/$artistaId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al quitar like');
  }

}