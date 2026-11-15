import 'package:drift/drift.dart';

class Members extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  TextColumn get tier => text().withDefault(const Constant('bronze'))();
  IntColumn get points => integer().withDefault(const Constant(0))();
  IntColumn get notificationsCount =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get priceMmk => integer()();
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();
  IntColumn get discountPercent => integer().nullable()();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get section => text().withDefault(const Constant('popular'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Banners extends Table {
  TextColumn get id => text()();
  TextColumn get imageUrl => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get distanceLabel => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  BoolColumn get isOpen => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind => text().withDefault(const Constant('donut'))();
  IntColumn get current => integer().withDefault(const Constant(0))();
  IntColumn get target => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get phoneE164 => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get dateOfBirth => text()();

  @override
  Set<Column> get primaryKey => {id};
}
