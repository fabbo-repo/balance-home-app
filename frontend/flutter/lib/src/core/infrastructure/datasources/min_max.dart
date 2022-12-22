import 'package:equatable/equatable.dart';

class MinMax extends Equatable {

  final double min;
  final double max;

  const MinMax({
    required this.min,
    required this.max
  });

  @override
  List<Object?> get props => [
    min, max
  ];
}