import 'Cancion.dart';

class Playlist {
  final String id;
  final String nombre;
  final String descripcion;
  final String creadorId;
  final String creadorNombre;
  final String imagenUrl;
  final List<Cancion> canciones;

  Playlist({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.creadorId,
    required this.creadorNombre,
    required this.imagenUrl,
    required this.canciones,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      creadorId: json['creadorId'] ?? 'Desconocido',
      creadorNombre: json['creadorNombre'] ?? 'Desconocido',
      imagenUrl: json['imagenUrl'] ?? '',
      canciones: (json['canciones'] as List)
          .map((e) => Cancion.fromJson(e))
          .toList(),
    );
  }
}
