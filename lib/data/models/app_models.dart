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
  final double quantity;
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
      quantity: (map['quantity'] ?? 0).toDouble(),
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

  // --- ADDED QUANTITY FIELDS ---
  final int broilerQty;
  final double broilerWt;

  final double muttonOpeningWt;
  final double muttonClosingWt;
  final int muttonQty; // <-- Added
  final double muttonWt;

  final int dpQty; // <-- Added
  final double dpWt;

  final int ogQty; // <-- Added
  final double ogWt;

  final int eggQty;

  final int potaKalejiQty; // <-- Added
  final double potaKalejiWt;

  final double sellingAmount;
  final double totalAmount;
  final double difference;

  SaleModel({
    this.id,
    required this.shopCode,
    required this.date,
    required this.broilerQty, // <-- Added
    required this.broilerWt,
    required this.muttonOpeningWt,
    required this.muttonClosingWt,
    required this.muttonQty, // <-- Added
    required this.muttonWt,
    required this.dpQty, // <-- Added
    required this.dpWt,
    required this.ogQty, // <-- Added
    required this.ogWt,
    required this.eggQty,
    required this.potaKalejiQty, // <-- Added
    required this.potaKalejiWt,
    required this.sellingAmount,
    required this.totalAmount,
    required this.difference,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_code': shopCode,
      'date': date,
      'broiler_qty': broilerQty, // <-- Added
      'broiler_wt': broilerWt,
      'mutton_opening_wt': muttonOpeningWt,
      'mutton_closing_wt': muttonClosingWt,
      'mutton_qty': muttonQty, // <-- Added
      'mutton_wt': muttonWt,
      'dp_qty': dpQty, // <-- Added
      'dp_wt': dpWt,
      'og_qty': ogQty, // <-- Added
      'og_wt': ogWt,
      'egg_qty': eggQty,
      'pota_kaleji_qty': potaKalejiQty, // <-- Added
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
      broilerQty: map['broiler_qty'] ?? 0, // <-- Added
      broilerWt: map['broiler_wt'] ?? 0.0,
      muttonOpeningWt: map['mutton_opening_wt'] ?? 0.0,
      muttonClosingWt: map['mutton_closing_wt'] ?? 0.0,
      muttonQty: map['mutton_qty'] ?? 0, // <-- Added
      muttonWt: map['mutton_wt'] ?? 0.0,
      dpQty: map['dp_qty'] ?? 0, // <-- Added
      dpWt: map['dp_wt'] ?? 0.0,
      ogQty: map['og_qty'] ?? 0, // <-- Added
      ogWt: map['og_wt'] ?? 0.0,
      eggQty: map['egg_qty'] ?? 0,
      potaKalejiQty: map['pota_kaleji_qty'] ?? 0, // <-- Added
      potaKalejiWt: map['pota_kaleji_wt'] ?? 0.0,
      sellingAmount: map['selling_amount'] ?? 0.0,
      totalAmount: map['total_amount'] ?? 0.0,
      difference: map['difference'] ?? 0.0,
    );
  }
}

// --- NEW STOCK MODEL ---
class StockModel {
  final int? id;
  final String shopCode;
  final String date;
  final String itemType;
  final double qty;
  final double weight1;
  final double weight2;

  StockModel({
    this.id,
    required this.shopCode,
    required this.date,
    required this.itemType,
    required this.qty,
    required this.weight1,
    required this.weight2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_code': shopCode,
      'date': date,
      'item_type': itemType,
      'qty': qty,
      'weight_1': weight1,
      'weight_2': weight2,
    };
  }

  factory StockModel.fromMap(Map<String, dynamic> map) {
    return StockModel(
      id: map['id'],
      shopCode: map['shop_code'],
      date: map['date'],
      itemType: map['item_type'],
      qty: (map['qty'] ?? 0).toDouble(),
      weight1: map['weight_1'],
      weight2: map['weight_2'],
    );
  }
}

class ExpenseModel {
  final int? id;
  final String shopCode;
  final String date;
  final String
  category; // 'चहा', 'नाश्ता', 'दाणा', 'पिशवी', 'पाणी', 'Light Bill', 'Waste Tax', 'Rent', 'Other'
  final double amount;
  final String notes;

  ExpenseModel({
    this.id,
    required this.shopCode,
    required this.date,
    required this.category,
    required this.amount,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_code': shopCode,
      'date': date,
      'category': category,
      'amount': amount,
      'notes': notes,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      shopCode: map['shop_code'],
      date: map['date'],
      category: map['category'],
      amount: map['amount'],
      notes: map['notes'] ?? '',
    );
  }
}

class TraderPaymentModel {
  final int? id;
  final int? traderId;
  final String itemType; // Fallback category if trader is null
  final String date;
  final double amount;
  final String notes;

  TraderPaymentModel({
    this.id,
    this.traderId,
    required this.itemType,
    required this.date,
    required this.amount,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trader_id': traderId,
      'item_type': itemType,
      'date': date,
      'amount': amount,
      'notes': notes,
    };
  }

  factory TraderPaymentModel.fromMap(Map<String, dynamic> map) {
    return TraderPaymentModel(
      id: map['id'],
      traderId: map['trader_id'],
      itemType: map['item_type'],
      date: map['date'],
      amount: map['amount'],
      notes: map['notes'] ?? '',
    );
  }
}
