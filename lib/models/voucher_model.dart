class VoucherModel {
  final int id;
  final int sellerId;
  final String code;
  final String name;
  final String discountType;
  final double discountValue;
  final double minPurchase;
  final double? maxDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final int quota;
  final bool isClaimed;

  VoucherModel({
    required this.id,
    required this.sellerId,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.quota,
    this.isClaimed = false,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      sellerId: json['seller_id'],
      code: json['code'],
      name: json['name'],
      discountType: json['discount_type'],
      discountValue: double.parse(json['discount_value'].toString()),
      minPurchase: double.parse(json['min_purchase'].toString()),
      maxDiscount: json['max_discount'] != null 
          ? double.parse(json['max_discount'].toString()) 
          : null,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      quota: json['quota'],
      isClaimed: json['is_claimed'] ?? false,
    );
  }
}
