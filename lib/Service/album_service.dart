import 'dart:convert';

import '../Model/Album.dart';

import 'package:http/http.dart' as http;

class AlbumService {
  // final String albumUrl = 'http://192.168.0.23:8081/albumes';
  // final String spotifyUrl = 'http://192.168.0.23:8081/spotify';

  final String albumUrl = 'https://music-sound.onrender.com/albumes';
  final String spotifyUrl = 'https://music-sound.onrender.com/spotify';

  Future<List<Album>> buscarAlbumes(String query) async {
    final url = Uri.parse('$spotifyUrl/buscar/albumes?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Album.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar álbumes');
    }
  }

  Future<Album> obtenerAlbumPorId(String id) async {
    final url = Uri.parse('$albumUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Album.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener album');
    }
  }

  Future<void> darLike(String idToken, String albumId) async {
    final url = Uri.parse('$albumUrl/like/$albumId');
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
    final url = Uri.parse('$albumUrl/like/$albumId');
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