import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Spotify",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Sign up free"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Log in"),
            )
          ],
        ),
      ),
    );
  }
}