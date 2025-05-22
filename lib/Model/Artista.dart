class Artista {
  final String id;
  final String nombre;
  final String? imagenUrl;
  final int popularidad;
  final int seguidores;
  final String urlSpotify;
  final List<String> generos;

  Artista({
    required this.id,
    required this.nombre,
    this.imagenUrl,
    required this.popularidad,
    required this.seguidores,
    required this.urlSpotify,
    required this.generos,
  });

  factory Artista.fromJson(Map<String, dynamic> json) {
    return Artista(
      id: json['id'],
      nombre: json['nombre'],
      imagenUrl: json['imagenUrl'],
      popularidad: json['popularidad'],
      seguidores: json['seguidores'],
      urlSpotify: json['urlSpotify'],
      generos: List<String>.from(json['generos']),
    );
  }
}
