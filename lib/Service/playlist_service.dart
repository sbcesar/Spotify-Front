import 'dart:convert';

import '../Model/Playlist.dart';
import 'package:http/http.dart' as http;

class PlaylistService {
  final String playlistUrl = 'http://192.168.0.23:8081/playlists';
  final String spotifyUrl = 'http://192.168.0.23:8081/spotify';

  Future<List<Playlist>> buscarPlaylists(String query) async {
    final url = Uri.parse('$spotifyUrl/buscar/playlists?query=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Playlist.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar playlists');
    }
  }

  Future<List<Playlist>> obtenerTodas() async {
    final url = Uri.parse('http://192.168.0.23:8081/playlists/todas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Playlist.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener todas las playlists');
    }
  }

  Future<Playlist> obtenerPlaylistPorId(String id) async {
    final url = Uri.parse('$playlistUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Playlist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener playlist');
    }
  }

  Future<void> eliminarPlaylist(String token, String playlistId) async {
  final url = Uri.parse('$playlistUrl/$playlistId');
  final response = await http.delete(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar la playlist');
  }
}

  Future<void> agregarCancionAPlaylist(String token, String playlistId, String cancionId) async {
    final response = await http.put(
      Uri.parse('http://192.168.0.23:8081/playlists/$playlistId/agregarCancion/$cancionId'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al agregar la canción a la playlist");
    }
  }

  Future<Playlist> eliminarCancionDePlaylist(String token, String playlistId, String cancionId) async {
  final response = await http.put(
    Uri.parse('http://192.168.0.23:8081/playlists/$playlistId/eliminarCancion/$cancionId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return Playlist.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Error al eliminar canción de la playlist");
  }
}

  Future<void> darLike(String idToken, String playlistId) async {
    final url = Uri.parse('$playlistUrl/like/$playlistId');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode != 200) throw Exception('Error al dar like');
  }

  Future<void> quitarLike(String idToken, String playlistId) async {
    final url = Uri.parse('$playlistUrl/like/$playlistId');
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