import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/reset_password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordView extends ConsumerWidget {
  /// Route name
  static const routeName = 'resetPassword';

  /// Route path
  static const routePath = 'reset';

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final codeController = TextEditingController();

  ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTittle(fontSize: 30),
        backgroundColor: AppColors.appBarBackgroundColor,
      ),
      body: SafeArea(
          child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        AssetImage((ref.watch(themeModeProvider) == ThemeMode.dark)
                              ? "assets/images/auth_background_dark_image.jpg"
                              : "assets/images/auth_background_image.jpg"),
                    fit: BoxFit.cover),
              ),
              child: ResetPasswordForm())),
    );
  }
}
