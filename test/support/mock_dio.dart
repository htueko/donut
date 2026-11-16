import 'package:dio/dio.dart';

/// A Dio stand-in that answers from a fixed route table, so the sync layer can
/// be tested without a socket. Unknown routes and [failure] both throw.
class MockDio implements Dio {
  MockDio({required this.responses, this.failure});

  final Map<String, Map<String, dynamic>> responses;
  final DioException? failure;

  int calls = 0;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    calls++;
    final error = failure;
    if (error != null) {
      throw error;
    }
    final body = responses[path];
    if (body == null) {
      throw DioException.connectionError(
        requestOptions: RequestOptions(path: path),
        reason: 'no mock route for $path',
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: body as T,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'MockDio does not implement ${invocation.memberName}',
    );
  }
}
