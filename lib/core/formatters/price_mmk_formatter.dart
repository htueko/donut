import 'package:intl/intl.dart';

abstract final class PriceMmkFormatter {
  static final NumberFormat _decimal = NumberFormat.decimalPattern('en');

  static String format(int amount) {
    return '${_decimal.format(amount)} MMK';
  }
}
