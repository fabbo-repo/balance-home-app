import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Selected date class.
class SelectedDate extends Equatable {
  final int day;
  final int month;
  final int year;
  final SelectedDateMode selectedDateMode;

  DateTime get dateFrom {
    if (selectedDateMode == SelectedDateMode.month) {
      return DateTime(year, month, 1);
    } else if (selectedDateMode == SelectedDateMode.year) {
      return DateTime(year, 1, 1);
    }
    return DateTime(year, month, day);
  }

  DateTime get dateTo {
    if (selectedDateMode == SelectedDateMode.month) {
      return DateTime(year, month, DateUtils.getDaysInMonth(year, month));
    } else if (selectedDateMode == SelectedDateMode.year) {
      return DateTime(year, 12, DateUtils.getDaysInMonth(year, month));
    }
    return DateTime(year, month, day);
  }

  const SelectedDate({
    required this.day,
    required this.month,
    required this.year,
    required this.selectedDateMode,
  });

  @override
  List<Object?> get props => [day, month, year];

  SelectedDate copyWith({
    int? day,
    int? month,
    int? year,
    SelectedDateMode? selectedDateMode,
  }) {
    return SelectedDate(
        day: day ?? this.day,
        month: month ?? this.month,
        year: year ?? this.year,
        selectedDateMode: selectedDateMode ?? this.selectedDateMode);
  }
}
