import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/date_currency_conversion_list_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_conversion_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_type_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/annual_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/domain/repositories/monthly_balance_repository_interface.dart';
import 'package:balance_home_app/src/features/statistics/presentation/models/statistics_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

class StatisticsController
    extends StateNotifier<AsyncValue<Either<Failure, StatisticsData>>> {
  final BalanceRepositoryInterface balanceRepository;
  final AnnualBalanceRepositoryInterface annualBalanceRepository;
  final MonthlyBalanceRepositoryInterface monthlyBalanceRepository;
  final CurrencyTypeRepositoryInterface currencyTypeRepository;
  final CurrencyConversionRepositoryInterface currencyConversionRepository;
  final SelectedDate selectedBalanceDate;
  final SelectedDate selectedSavingsDate;

  StatisticsController(
      {required this.balanceRepository,
      required this.annualBalanceRepository,
      required this.monthlyBalanceRepository,
      required this.currencyTypeRepository,
      required this.currencyConversionRepository,
      required this.selectedBalanceDate,
      required this.selectedSavingsDate})
      : super(const AsyncValue.loading());

  Future<void> handle() async {
    SelectedDate balanceDate =
        selectedBalanceDate.copyWith(selectedDateMode: SelectedDateMode.year);
    final revenues = await balanceRepository.getBalances(
        BalanceTypeMode.revenue,
        dateFrom: balanceDate.dateFrom,
        dateTo: balanceDate.dateTo);
    state = await revenues.fold((failure) {
      if (failure is NoLocalEntityFailure) {
        return AsyncValue.data(left(failure));
      }
      return AsyncValue.error(failure.detail, StackTrace.empty);
    }, (revenues) async {
      // Revenues years
      final revenueYears =
          await balanceRepository.getBalanceYears(BalanceTypeMode.revenue);
      return await revenueYears.fold((failure) {
        return AsyncValue.error(failure.detail, StackTrace.empty);
      }, (revenueYears) async {
        // Expenses
        final expenses = await balanceRepository.getBalances(
            BalanceTypeMode.expense,
            dateFrom: balanceDate.dateFrom,
            dateTo: balanceDate.dateTo);
        return await expenses.fold((failure) {
          if (failure is NoLocalEntityFailure) {
            return AsyncValue.data(left(failure));
          }
          return AsyncValue.error(failure.detail, StackTrace.empty);
        }, (expenses) async {
          // Expense years
          final expenseYears =
              await balanceRepository.getBalanceYears(BalanceTypeMode.expense);
          return await expenseYears.fold((failure) {
            return AsyncValue.error(failure.detail, StackTrace.empty);
          }, (expenseYears) async {
            // Monthly balances
            final monthlyBalances = await monthlyBalanceRepository
                .getMonthlyBalances(year: selectedSavingsDate.year);
            return await monthlyBalances.fold((failure) {
              if (failure is NoLocalEntityFailure) {
                return AsyncValue.data(left(failure));
              }
              return AsyncValue.error(failure.detail, StackTrace.empty);
            }, (monthlyBalances) async {
              // Annual balances
              final annualBalances =
                  await annualBalanceRepository.getAnnualBalances();
              return await annualBalances.fold((failure) {
                if (failure is NoLocalEntityFailure) {
                  return AsyncValue.data(left(failure));
                }
                return AsyncValue.error(failure.detail, StackTrace.empty);
              }, (annualBalances) async {
                // Currency types
                final currencyTypes =
                    await currencyTypeRepository.getCurrencyTypes();
                return await currencyTypes.fold((failure) {
                  if (failure is NoLocalEntityFailure) {
                    return AsyncValue.data(left(failure));
                  }
                  return AsyncValue.error(failure.detail, StackTrace.empty);
                }, (currencyTypes) async {
                  // Date exchanges
                  final dateCurrencyConversion =
                      await currencyConversionRepository
                          .getLastDateCurrencyConversion(days: 20);
                  return await dateCurrencyConversion.fold((failure) {
                    if (failure is HttpConnectionFailure) {
                      return AsyncValue.data(right(StatisticsData(
                        revenues: revenues,
                        revenueYears: revenueYears,
                        expenses: expenses,
                        expenseYears: expenseYears,
                        monthlyBalances: monthlyBalances,
                        annualBalances: annualBalances,
                        currencyTypes: currencyTypes,
                        dateCurrencyConversion:
                            const DateCurrencyConversionListEntity(
                                dateExchanges: []),
                      )));
                    }
                    return AsyncValue.error(failure.detail, StackTrace.empty);
                  }, (dateCurrencyConversion) async {
                    return AsyncValue.data(right(StatisticsData(
                      revenues: revenues,
                      revenueYears: revenueYears,
                      expenses: expenses,
                      expenseYears: expenseYears,
                      monthlyBalances: monthlyBalances,
                      annualBalances: annualBalances,
                      currencyTypes: currencyTypes,
                      dateCurrencyConversion: dateCurrencyConversion,
                    )));
                  });
                });
              });
            });
          });
        });
      });
    });
  }
}
