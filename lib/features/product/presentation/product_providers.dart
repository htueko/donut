import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/product.dart';

final productByIdProvider = FutureProvider.autoDispose.family<Product, String>((
  ref,
  id,
) async {
  final result = await ref.watch(catalogRepositoryProvider).getProduct(id);
  return result.when(
    onSuccess: (product) => product,
    onFailure: (failure) => throw ProductLookupError(failure),
  );
});

class ProductLookupError implements Exception {
  const ProductLookupError(this.failure);

  final Failure failure;

  @override
  String toString() => 'ProductLookupError(${failure.runtimeType})';
}

Failure failureFromProductError(Object error) {
  if (error is ProductLookupError) {
    return error.failure;
  }
  return UnexpectedFailure(error);
}
