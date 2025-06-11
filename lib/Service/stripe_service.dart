import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class StripeService {
  final String _baseUrl = "https://music-sound.onrender.com/stripe";

  Future<String?> iniciarCheckout() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse("$_baseUrl/checkout"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = response.body;
      final url = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(data)?.group(1);
      return url;
    } else {
      return null;
    }
  }
}
