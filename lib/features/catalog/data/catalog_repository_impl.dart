import '../../../core/result.dart';
import '../domain/catalog_data.dart';
import '../domain/catalog_repository.dart';
import '../domain/product.dart';
import 'catalog_sync.dart';
import 'local/catalog_database.dart' as local;

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._db, {this.sync});

  final local.CatalogDatabase _db;
  final CatalogSync? sync;

  @override
  Stream<CatalogData> watchCatalog() => _db.catalogDao.watchCatalog();

  @override
  Future<Result<Product>> getProduct(String id) async {
    try {
      final product = await _db.catalogDao.productById(id);
      if (product == null) {
        return const FailureResult(NotFoundFailure('Product not found'));
      }
      return Success(product);
    } on Object catch (error, stack) {
      return FailureResult(UnexpectedFailure(error, stack));
    }
  }

  @override
  Future<Result<void>> refresh() async {
    final catalogSync = sync;
    if (catalogSync == null) {
      return const Success(null);
    }
    return catalogSync.refresh();
  }
}
