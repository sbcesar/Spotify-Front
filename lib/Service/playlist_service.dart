import 'dart:convert';

import '../Model/Playlist.dart';
import 'package:http/http.dart' as http;

class PlaylistService {
  final String baseUrl = 'https://music-sound.onrender.com';

  Future<List<Playlist>> buscarPlaylists(String query) async {
    final url = Uri.parse('$baseUrl/spotify/buscar/playlists?query=$query');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Playlist.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar playlists');
    }
  }

  Future<List<Playlist>> obtenerTodas() async {
    final url = Uri.parse('$baseUrl/playlists/todas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Playlist.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener todas las playlists');
    }
  }

  Future<Playlist> obtenerPlaylistPorId(String id) async {
    final url = Uri.parse('$baseUrl/playlists/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Playlist.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener playlist');
    }
  }

  Future<List<Playlist>> obtenerPlaylistsDelUsuario(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/biblioteca'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final playlists = data['biblioteca']['playlists'] as List;
      return playlists.map((p) => Playlist.fromJson(p)).toList();
    } else {
      throw Exception('Error al obtener playlists del usuario');
    }
  }

  Future<void> mezclarPlaylists(String token, String id1, String id2) async {
    final url = Uri.parse('$baseUrl/playlists/mix');
    final body = jsonEncode({
      "playlistId1": id1,
      "playlistId2": id2,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al mezclar playlists');
    }
  }

  Future<void> editarPlaylist(String token, String id, String nombre, String descripcion, String imagenUrl) async {
    final uri = Uri.parse('$baseUrl/playlists/$id/editar');
    final body = {
      "nombre": nombre.trim(),
      "descripcion": descripcion.trim(),
      "imagenUrl": imagenUrl.trim(),
    };

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar la playlist: ${response.body}');
    }
  }

  Future<void> eliminarPlaylist(String token, String playlistId) async {
    final url = Uri.parse('$baseUrl/playlists/$playlistId');
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
      Uri.parse('$baseUrl/playlists/$playlistId/agregarCancion/$cancionId'),
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
    Uri.parse('$baseUrl/playlists/$playlistId/eliminarCancion/$cancionId'),
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
    final url = Uri.parse('$baseUrl/playlists/like/$playlistId');
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
    final url = Uri.parse('$baseUrl/playlists/like/$playlistId');
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