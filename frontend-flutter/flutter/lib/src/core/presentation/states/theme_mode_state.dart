import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeState extends StateNotifier<ThemeMode> {

  ThemeModeState(ThemeMode mode) : super(mode);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
