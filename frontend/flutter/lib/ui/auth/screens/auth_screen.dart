import 'package:balance_home_app/ui/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/auth_background_image.jpg"),
            fit: BoxFit.cover),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'TemiCodes',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 30),
              )
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  children: const [
                    TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: "Sign in"),
                        Tab(text: "Register")
                      ]
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          LoginScreen(),
                          LoginScreen()
                        ]
                      )
                    ),
                  ],
                ),
              ),
            )  
          ],
        )
      ),
    );
  }
}