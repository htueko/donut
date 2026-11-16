import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[dio] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[dio] error ${err.response?.statusCode} ${err.message}');
    }
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  RetryInterceptor({required Dio dio, this.maxRetries = 2}) : _retryDio = dio;

  final Dio _retryDio;
  final int maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retriable =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
    final status = err.response?.statusCode ?? 0;
    final options = err.requestOptions;
    if (!retriable || (status != 0 && status < 500)) {
      handler.next(err);
      return;
    }
    final retryCount = (options.extra['retry_count'] as int?) ?? 0;
    if (retryCount >= maxRetries) {
      handler.next(err);
      return;
    }
    options.extra['retry_count'] = retryCount + 1;
    try {
      final response = await _retryDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on Object {
      handler.next(err);
    }
  }
}
