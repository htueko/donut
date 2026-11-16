import 'package:dio/dio.dart';

class ReachabilityService {
  ReachabilityService({Dio? dio}) : _dio = dio ?? Dio();

  static const String probeUrl = 'https://www.google.com/generate_204';

  final Dio _dio;

  Future<bool> isReachable() async {
    try {
      await _dio.head<dynamic>(
        probeUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      return true;
    } on Object {
      return false;
    }
  }
}
