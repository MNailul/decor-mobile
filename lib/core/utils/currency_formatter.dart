import 'package:intl/intl.dart';

extension CurrencyFormatter on num {
  String toIDR() {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(this);
  }
}
