import 'package:flutter/material.dart';
import '../Service/stripe_service.dart';

class StripeViewModel extends ChangeNotifier {
  final StripeService _stripeService = StripeService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> iniciarPago() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = await _stripeService.iniciarCheckout();
      if (url == null) {
        _error = "No se pudo obtener el enlace de pago.";
      }
      return url;
    } catch (e) {
      _error = "Error al iniciar el pago: $e";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
