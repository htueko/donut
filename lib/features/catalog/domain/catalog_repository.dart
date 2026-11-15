import '../../../core/result.dart';
import 'catalog_data.dart';
import 'product.dart';

abstract interface class CatalogRepository {
  Stream<CatalogData> watchCatalog();

  Future<Result<Product>> getProduct(String id);

  Future<Result<void>> refresh();
}
