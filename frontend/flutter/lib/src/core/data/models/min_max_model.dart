import 'package:equatable/equatable.dart';

class MinMaxModel extends Equatable {

  final double min;
  final double max;

  const MinMaxModel({
    required this.min,
    required this.max
  });

  @override
  List<Object?> get props => [
    min, max
  ];
}