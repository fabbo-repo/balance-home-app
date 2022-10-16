import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/features/auth/views/login_view.dart';
import 'package:balance_home_app/src/features/auth/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
     return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/auth_background_image.jpg"),
            fit: BoxFit.cover
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(40, 70, 40, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ref.read(appLocalizationsProvider).appTitle1,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                  Text(
                    ref.read(appLocalizationsProvider).appTitle2,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              )
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(
                          child: Text(
                            ref.read(appLocalizationsProvider).signIn,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 27, 27, 27),
                              fontSize: 20
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            ref.read(appLocalizationsProvider).register,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 27, 27, 27),
                              fontSize: 20
                            ),
                          ),
                        )
                      ]
                    ),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          LoginScreen(),
                          RegisterScreen()
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