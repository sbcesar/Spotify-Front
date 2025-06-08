import 'dart:convert';

import '../Model/Album.dart';

import 'package:http/http.dart' as http;

class AlbumService {
  final String baseUrl = 'https://music-sound.onrender.com';

  Future<List<Album>> buscarAlbumes(String query) async {
    final url = Uri.parse('$baseUrl/spotify/buscar/albumes?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Album.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar álbumes');
    }
  }

  Future<Album> obtenerAlbumPorId(String id) async {
    final url = Uri.parse('$baseUrl/albumes/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Album.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener album');
    }
  }

  Future<List<String>> obtenerLikedAlbums(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/perfil'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final biblioteca = data['biblioteca'];
      final likedIds = (biblioteca['likedAlbums'] as List).cast<String>();
      return likedIds;
    } else {
      throw Exception('Error al obtener álbumes con like');
    }
  }

  Future<void> darLike(String idToken, String albumId) async {
    final url = Uri.parse('$baseUrl/albumes/like/$albumId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al dar like');
  }

  Future<void> quitarLike(String idToken, String albumId) async {
    final url = Uri.parse('$baseUrl/albumes/like/$albumId');
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