import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<HttpService> httpServiceProvider = Provider<HttpService>(
  (ProviderRef<HttpService> ref) {
    return HttpService();
  }
);