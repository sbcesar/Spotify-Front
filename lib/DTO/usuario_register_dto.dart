class UsuarioRegisterDTO {
  final String nombre;
  final String email;
  final String password;

  UsuarioRegisterDTO({
    required this.nombre,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'password': password,
    };
  }
}
