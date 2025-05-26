import 'BibliotecaMostrableDTO.dart';

class UsuarioBibliotecaMostrableDTO {
  final String id;
  final String nombre;
  final String email;
  final BibliotecaMostrableDTO biblioteca;

  UsuarioBibliotecaMostrableDTO({
    required this.id,
    required this.nombre,
    required this.email,
    required this.biblioteca,
  });

  factory UsuarioBibliotecaMostrableDTO.fromJson(Map<String, dynamic> json) {
    return UsuarioBibliotecaMostrableDTO(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      biblioteca: BibliotecaMostrableDTO.fromJson(json['biblioteca']),
    );
  }
}
