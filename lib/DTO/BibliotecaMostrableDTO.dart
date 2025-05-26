import '../Model/Album.dart';
import '../Model/Artista.dart';
import '../Model/Cancion.dart';
import '../Model/Playlist.dart';

class BibliotecaMostrableDTO {
  final List<Cancion> canciones;
  final List<Playlist> playlists;
  final List<Artista> artistas;
  final List<Album> albumes;

  BibliotecaMostrableDTO({
    required this.canciones,
    required this.playlists,
    required this.artistas,
    required this.albumes,
  });

  factory BibliotecaMostrableDTO.fromJson(Map<String, dynamic> json) {
    return BibliotecaMostrableDTO(
      canciones: (json['canciones'] as List?)?.map((e) => Cancion.fromJson(e)).toList() ?? [],
      playlists: (json['playlists'] as List?)?.map((e) => Playlist.fromJson(e)).toList() ?? [],
      artistas: (json['artistas'] as List?)?.map((e) => Artista.fromJson(e)).toList() ?? [],
      albumes: (json['albumes'] as List?)?.map((e) => Album.fromJson(e)).toList() ?? [],
    );
  }
}
