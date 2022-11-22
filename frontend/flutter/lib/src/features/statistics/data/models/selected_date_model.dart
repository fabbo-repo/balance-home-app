import 'package:equatable/equatable.dart';

class SelectedDateModel extends Equatable {

  final int day;
  final int month;
  final int year;

  const SelectedDateModel({
    required this.day,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [
    day, 
    month, 
    year
  ];
}