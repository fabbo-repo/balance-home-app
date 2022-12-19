import 'package:balance_home_app/src/core/data/models/selected_date_enum.dart';
import 'package:equatable/equatable.dart';

class SelectedDateModel extends Equatable {

  final int day;
  final int month;
  final int year;
  final SelectedDateEnum selectedDateMode; 

  const SelectedDateModel({
    required this.day,
    required this.month,
    required this.year,
    required this.selectedDateMode,
  });

  @override
  List<Object?> get props => [
    day, 
    month, 
    year
  ];
}