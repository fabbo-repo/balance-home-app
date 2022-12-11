import 'package:equatable/equatable.dart';

class SelectedExchangeModel extends Equatable {

  final String selectedCoinFrom;
  final String selectedCoinTo;

  const SelectedExchangeModel({
    required this.selectedCoinFrom,
    required this.selectedCoinTo
  });

  @override
  List<Object?> get props => [
    selectedCoinFrom, 
    selectedCoinTo
  ];
}