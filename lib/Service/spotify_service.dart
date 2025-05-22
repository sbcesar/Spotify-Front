import 'dart:convert';

import '../Model/Album.dart';
import '../Model/Artista.dart';
import '../Model/Cancion.dart';
import 'package:http/http.dart' as http;

import '../Model/Playlist.dart';

class SpotifyService {
  
  final String baseUrl = 'http://192.168.0.23:8081/spotify';

  Future<List<Cancion>> buscarCanciones(String query) async {
    final url = Uri.parse('$baseUrl/buscar/canciones?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Cancion.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar canciones');
    }
  }

  Future<List<Artista>> buscarArtistas(String query) async {
    final url = Uri.parse('$baseUrl/buscar/artistas?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Artista.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar artistas');
    }
  }

  Future<List<Album>> buscarAlbumes(String query) async {
    final url = Uri.parse('$baseUrl/buscar/albumes?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Album.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar álbumes');
    }
  }

  Future<List<Playlist>> buscarPlaylists(String query) async {
    final url = Uri.parse('$baseUrl/buscar/playlists?query=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Playlist.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar playlists');
    }
  }
}