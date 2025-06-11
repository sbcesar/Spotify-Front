import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_tfg_flutter/Viewmodels/stripe_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  Future<void> _goToCheckout(BuildContext context) async {
    final stripeVM = context.read<StripeViewModel>();
    final url = await stripeVM.iniciarPago();

    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(stripeVM.error ?? 'Error al abrir Stripe')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stripeVM = context.watch<StripeViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hazte Premium"),
        backgroundColor: const Color(0xFF2C698D),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "ÚNETE A PREMIUM",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C698D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Mejora tu experiencia y disfruta de las siguientes ventajas:",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "• Mezcla y crea playlists únicas",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "• Disfruta de una experiencia personalizada de música",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "• Sin anuncios, sin interrupciones",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    "Suscripción mensual",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C698D),
                    ),
                  ),
                  const Text(
                    "\$0.49 / mes",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: stripeVM.isLoading ? null : () => _goToCheckout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C698D),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: stripeVM.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Pasar a Premium",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
