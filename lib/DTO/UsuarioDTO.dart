import 'BibliotecaDTO.dart';

class UsuarioDTO {
  final String id;
  final String nombre;
  final String email;
  final int playlistCount;
  final int seguidores;
  final int seguidos;
  final BibliotecaDTO biblioteca;

  UsuarioDTO({
    required this.id,
    required this.nombre,
    required this.email,
    required this.playlistCount,
    required this.seguidores,
    required this.seguidos,
    required this.biblioteca,
  });

  factory UsuarioDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioDTO(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      playlistCount: json['playlistCount'] ?? 0,
      seguidores: json['seguidores'] ?? 0,
      seguidos: json['seguidos'] ?? 0,
      biblioteca: BibliotecaDTO.fromJson(json['biblioteca']),
    );
  }
}
