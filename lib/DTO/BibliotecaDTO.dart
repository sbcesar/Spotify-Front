class BibliotecaDTO {
  final List<String> likedCanciones;
  final List<String> likedPlaylists;
  final List<String> likedArtistas;
  final List<String> likedAlbumes;

  BibliotecaDTO({
    required this.likedCanciones,
    required this.likedPlaylists,
    required this.likedArtistas,
    required this.likedAlbumes,
  });

  factory BibliotecaDTO.fromJson(Map<String, dynamic> json) {
    return BibliotecaDTO(
      likedCanciones: List<String>.from(json['likedCanciones']),
      likedPlaylists: List<String>.from(json['likedPlaylists']),
      likedArtistas: List<String>.from(json['likedArtistas']),
      likedAlbumes: List<String>.from(json['likedAlbumes']),
    );
  }
}
