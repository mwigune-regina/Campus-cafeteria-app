import 'package:intl/intl.dart';

class Currency {
  static final NumberFormat _format = NumberFormat('#,##0', 'en_US');

  static String format(num amount) => 'Tsh ${_format.format(amount)}';

  static String formatCompact(num amount) => 'Tsh ${_format.format(amount)}';

  static String symbol() => 'Tsh';

  static String amountOnly(num amount) => _format.format(amount);
}
