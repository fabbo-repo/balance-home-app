import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeDataState extends StateNotifier<ThemeData> {
  ThemeDataState(ThemeData theme) : super(theme);

  void setThemeData(ThemeData theme) {
    state = theme;
  }
}
