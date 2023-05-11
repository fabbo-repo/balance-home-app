import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateState extends StateNotifier<SelectedDate> {
  SelectedDateState(SelectedDateMode selectedDateMode)
      : super(SelectedDate(
            day: DateTime.now().day,
            month: DateTime.now().month,
            year: DateTime.now().year,
            selectedDateMode: selectedDateMode));

  void setSelectedDate(SelectedDate selectedDate) {
    state = selectedDate;
  }

  void setMonth(int month) {
    state = state.copyWith(month: month);
  }

  void setYear(int year) {
    state = state.copyWith(year: year);
  }
}
