import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:spotify_tfg_flutter/DTO/usuario_register_dto.dart';


class AuthService {
  final String baseUrl = 'http://192.168.0.23:8081/usuario';

  Future<http.Response> register(UsuarioRegisterDTO usuario) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(usuario.toJson()),
    );
    
    return response;
  }

  Future<http.Response> login(String idToken) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },   
    );

    return response;
  }

  
}