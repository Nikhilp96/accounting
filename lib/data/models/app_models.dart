class RateModel {
  final String itemName;
  final double rate;
  RateModel({required this.itemName, required this.rate});
}

class TraderModel {
  final int? id;
  final String name;
  final String category; // 'Broiler' or 'Desi'
  TraderModel({this.id, required this.name, required this.category});
}

class PurchaseModel {
  final int? id;
  final String shopCode;
  final String itemType;
  final String date;
  final int quantity;
  final double? weight1;
  final double? weight2;
  final double rate;
  final double amount;
  final int? traderId;

  PurchaseModel({
    this.id,
    required this.shopCode,
    required this.itemType,
    required this.date,
    required this.quantity,
    this.weight1,
    this.weight2,
    required this.rate,
    required this.amount,
    this.traderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_code': shopCode,
      'item_type': itemType,
      'date': date,
      'quantity': quantity,
      'weight_1': weight1,
      'weight_2': weight2,
      'rate': rate,
      'amount': amount,
      'trader_id': traderId,
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'],
      shopCode: map['shop_code'],
      itemType: map['item_type'],
      date: map['date'],
      quantity: map['quantity'],
      weight1: map['weight_1'],
      weight2: map['weight_2'],
      rate: map['rate'],
      amount: map['amount'],
      traderId: map['trader_id'],
    );
  }
}

class SaleModel {
  final int? id;
  final String shopCode;
  final String date;
  final double broilerWt;
  final double muttonWt;
  final double dpWt;
  final double ogWt;
  final int eggQty;
  final double potaKalejiWt;
  final double sellingAmount;
  final double totalAmount;
  final double difference;

  SaleModel({
    this.id,
    required this.shopCode,
    required this.date,
    required this.broilerWt,
    required this.muttonWt,
    required this.dpWt,
    required this.ogWt,
    required this.eggQty,
    required this.potaKalejiWt,
    required this.sellingAmount,
    required this.totalAmount,
    required this.difference,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_code': shopCode,
      'date': date,
      'broiler_wt': broilerWt,
      'mutton_wt': muttonWt,
      'dp_wt': dpWt,
      'og_wt': ogWt,
      'egg_qty': eggQty,
      'pota_kaleji_wt': potaKalejiWt,
      'selling_amount': sellingAmount,
      'total_amount': totalAmount,
      'difference': difference,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      shopCode: map['shop_code'],
      date: map['date'],
      broilerWt: map['broiler_wt'],
      muttonWt: map['mutton_wt'],
      dpWt: map['dp_wt'],
      ogWt: map['og_wt'],
      eggQty: map['egg_qty'],
      potaKalejiWt: map['pota_kaleji_wt'],
      sellingAmount: map['selling_amount'],
      totalAmount: map['total_amount'],
      difference: map['difference'],
    );
  }
}
