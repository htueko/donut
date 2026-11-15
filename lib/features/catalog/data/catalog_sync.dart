import 'package:dio/dio.dart';

import '../../../core/result.dart';
import '../domain/banner.dart';
import '../domain/catalog_data.dart';
import '../domain/challenge.dart';
import '../domain/member.dart';
import '../domain/product.dart';
import '../domain/shop.dart';
import 'local/catalog_database.dart'
    hide Banner, Challenge, Member, Product, Shop;

class CatalogSync {
  CatalogSync(this._dio, this._db);

  final Dio _dio;
  final CatalogDatabase _db;

  static const _timeout = Duration(seconds: 6);

  Future<Result<void>> refresh() async {
    try {
      final products = await _getList('/v1/products');
      final banners = await _getList('/v1/banners');
      final shops = await _getList('/v1/shops');
      final challenges = await _getList('/v1/challenges');
      final member = await _getMember();
      await _db.catalogDao.replaceCatalog(
        CatalogData(
          products: products
              .map((item) => Product.fromJson(item))
              .toList(growable: false),
          banners: banners
              .map((item) => Banner.fromJson(item))
              .toList(growable: false),
          shops: shops
              .map((item) => Shop.fromJson(item))
              .toList(growable: false),
          challenges: challenges
              .map((item) => Challenge.fromJson(item))
              .toList(growable: false),
          member: member,
        ),
      );
      return const Success(null);
    } on Object catch (error) {
      return FailureResult(_failureFor(error));
    }
  }

  Failure _failureFor(Object error) {
    if (error is DioException) {
      return NetworkFailure(error.message ?? 'Request failed');
    }
    return CacheFailure('$error');
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      options: Options(sendTimeout: _timeout, receiveTimeout: _timeout),
    );
    final data = response.data?['data'];
    if (data is! List) {
      throw const FormatException('expected a list in the data envelope');
    }
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Member?> _getMember() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/member',
      options: Options(sendTimeout: _timeout, receiveTimeout: _timeout),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('expected an object in the data envelope');
    }
    return Member.fromJson(data);
  }
}
