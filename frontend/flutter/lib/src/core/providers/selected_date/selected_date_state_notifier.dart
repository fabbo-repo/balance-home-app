import 'package:balance_home_app/src/core/data/models/selected_date_enum.dart';
import 'package:balance_home_app/src/core/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateStateNotifier extends StateNotifier<SelectedDateState> {
  SelectedDateStateNotifier({SelectedDateEnum? selectedDateMode}) : 
    super(
      SelectedDateState(
        SelectedDateModel(
          day: DateTime.now().day, 
          month: DateTime.now().month, 
          year: DateTime.now().year,
          selectedDateMode: selectedDateMode ?? SelectedDateEnum.day
        )
      ));

  void setSelectedDate(SelectedDateModel date) {
    state = state.copyWith(date: date);
  }
  
  void setDay(int day) {
    SelectedDateModel date = SelectedDateModel(
      day: day,
      month: state.date.month,
      year: state.date.year,
      selectedDateMode: state.date.selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
  
  void setMonth(int month) {
    SelectedDateModel date = SelectedDateModel(
      day: state.date.day,
      month: month,
      year: state.date.year,
      selectedDateMode: state.date.selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
  
  void setYear(int year) {
    SelectedDateModel date = SelectedDateModel(
      day: state.date.day,
      month: state.date.month,
      year: year,
      selectedDateMode: state.date.selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
  
  void setSelectedDateMode(SelectedDateEnum selectedDateMode) {
    SelectedDateModel date = SelectedDateModel(
      day: state.date.day,
      month: state.date.month,
      year: state.date.year,
      selectedDateMode: selectedDateMode
    ); 
    state = state.copyWith(date: date);
  }
}