import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateModelStateNotifier extends StateNotifier<SelectedDateModelState> {
  SelectedDateModelStateNotifier() : 
    super(
      SelectedDateModelState(
        SelectedDateModel(
          day: DateTime.now().day, 
          month: DateTime.now().month, 
          year: DateTime.now().year
        )
      ));
  
  void setSelectedDateModel(SelectedDateModel model) {
    state = state.copyWith(model: model);
  }
  
  void setDay(int day) {
    SelectedDateModel model = SelectedDateModel(
      day: day,
      month: state.model.month,
      year: state.model.year
    ); 
    state = state.copyWith(model: model);
  }
  
  void setMonth(int month) {
    SelectedDateModel model = SelectedDateModel(
      day: state.model.day,
      month: month,
      year: state.model.year
    ); 
    state = state.copyWith(model: model);
  }
  
  void setYear(int year) {
    SelectedDateModel model = SelectedDateModel(
      day: state.model.day,
      month: state.model.month,
      year: year
    ); 
    state = state.copyWith(model: model);
  }

  SelectedDateModel? getSelectedDateModel() {
    return state.model;
  }
}