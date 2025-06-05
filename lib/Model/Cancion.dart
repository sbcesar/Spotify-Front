class Cancion {
  final String id;
  final String nombre;
  final String artista;
  final String album;
  final String imagenUrl;
  final int duracionMs;
  final String? previewUrl;
  final int popularidad;
  final String urlSpotify;
  final String? audioUrl;

  Cancion({
    required this.id,
    required this.nombre,
    required this.artista,
    required this.album,
    required this.imagenUrl,
    required this.duracionMs,
    required this.previewUrl,
    required this.popularidad,
    required this.urlSpotify,
    required this.audioUrl,
  });

  factory Cancion.fromJson(Map<String, dynamic> json) {
    return Cancion(
      id: json['id'],
      nombre: json['nombre'],
      artista: json['artista'],
      album: json['album'],
      imagenUrl: json['imagenUrl'] ?? '',
      duracionMs: json['duracionMs'],
      previewUrl: json['previewUrl'],
      popularidad: json['popularidad'],
      urlSpotify: json['urlSpotify'],
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'artista': artista,
      'album': album,
      'imagenUrl': imagenUrl,
      'duracionMs': duracionMs,
      'previewUrl': previewUrl,
      'popularidad': popularidad,
      'urlSpotify': urlSpotify,
      'audioUrl': audioUrl,
    };
  }
}
