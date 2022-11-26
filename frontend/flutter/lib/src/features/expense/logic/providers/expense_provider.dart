
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/coin/data/repositories/coin_type_repository.dart';
import 'package:balance_home_app/src/features/expense/data/repositories/expense_repository.dart';
import 'package:balance_home_app/src/features/expense/data/repositories/expense_type_respository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expense type repository
final expenseTypeRepositoryProvider = Provider<IExpenseTypeRepository>(
  (ProviderRef<IExpenseTypeRepository> ref) => ExpenseTypeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);

/// Expense repository
final expenseRepositoryProvider = Provider<IExpenseRepository>(
  (ProviderRef<IExpenseRepository> ref) => ExpenseRepository(
    httpService: ref.read(httpServiceProvider)
  )
);