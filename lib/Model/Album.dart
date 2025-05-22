import 'Cancion.dart';

class Album {
  final String id;
  final String nombre;
  final String? imagenUrl;
  final String fechaLanzamiento;
  final String tipo;
  final int totalCanciones;
  final int popularidad;
  final String urlSpotify;
  final List<String> artistas;
  final List<Cancion> canciones;

  Album({
    required this.id,
    required this.nombre,
    this.imagenUrl,
    required this.fechaLanzamiento,
    required this.tipo,
    required this.totalCanciones,
    required this.popularidad,
    required this.urlSpotify,
    required this.artistas,
    required this.canciones,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      nombre: json['nombre'],
      imagenUrl: json['imagenUrl'],
      fechaLanzamiento: json['fechaLanzamiento'],
      tipo: json['tipo'],
      totalCanciones: json['totalCanciones'],
      popularidad: json['popularidad'],
      urlSpotify: json['urlSpotify'],
      artistas: List<String>.from(json['artistas']),
      canciones: (json['canciones'] as List<dynamic>)
          .map((e) => Cancion.fromJson(e))
          .toList(),
    );
  }
}
