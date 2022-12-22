import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date_enum.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateStateNotifier extends StateNotifier<SelectedDateState> {
  SelectedDateStateNotifier({SelectedDateEnum? selectedDateMode}) : 
    super(
      SelectedDateState(
        SelectedDate(
          day: DateTime.now().day, 
          month: DateTime.now().month, 
          year: DateTime.now().year,
          selectedDateMode: selectedDateMode ?? SelectedDateEnum.day
        )
      ));

  void setSelectedDate(SelectedDate date) {
    state = state.copyWith(date: date);
  }
  
  void setDay(int day) {
    SelectedDate date = SelectedDate(
      day: day,
      month: state.date.month,
      year: state.date.year,
      selectedDateMode: state.date.selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
  
  void setMonth(int month) {
    SelectedDate date = SelectedDate(
      day: state.date.day,
      month: month,
      year: state.date.year,
      selectedDateMode: state.date.selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
  
  void setYear(int year) {
    SelectedDate date = SelectedDate(
      day: state.date.day,
      month: state.date.month,
      year: year,
      selectedDateMode: state.date.selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
  
  void setSelectedDateMode(SelectedDateEnum selectedDateMode) {
    SelectedDate date = SelectedDate(
      day: state.date.day,
      month: state.date.month,
      year: state.date.year,
      selectedDateMode: selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
}