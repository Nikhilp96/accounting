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

  final int broilerQty;
  final double broilerWt;

  final double muttonOpeningWt;
  final double muttonClosingWt;
  final int muttonQty;
  final double muttonWt;

  final int dpQty;
  final double dpWt;

  final int ogQty;
  final double ogWt;

  final int eggQty;

  final int potaKalejiQty;
  final double potaKalejiWt;

  // --- NEW: MORTALITY FIELDS ---
  final int broilerDeadQty;
  final double broilerDeadWt;
  final int dpDeadQty;
  final double dpDeadWt;
  final int ogDeadQty;
  final double ogDeadWt;

  final double sellingAmount;
  final double totalAmount;
  final double difference;

  SaleModel({
    this.id,
    required this.shopCode,
    required this.date,
    required this.broilerQty,
    required this.broilerWt,
    required this.muttonOpeningWt,
    required this.muttonClosingWt,
    required this.muttonQty,
    required this.muttonWt,
    required this.dpQty,
    required this.dpWt,
    required this.ogQty,
    required this.ogWt,
    required this.eggQty,
    required this.potaKalejiQty,
    required this.potaKalejiWt,
    // Mortality
    required this.broilerDeadQty,
    required this.broilerDeadWt,
    required this.dpDeadQty,
    required this.dpDeadWt,
    required this.ogDeadQty,
    required this.ogDeadWt,
    required this.sellingAmount,
    required this.totalAmount,
    required this.difference,
  });

  Map<String, dynamic> toMap() {
    return {
      'shop_code': shopCode,
      'date': date,
      'broiler_qty': broilerQty,
      'broiler_wt': broilerWt,
      'mutton_opening_wt': muttonOpeningWt,
      'mutton_closing_wt': muttonClosingWt,
      'mutton_qty': muttonQty,
      'mutton_wt': muttonWt,
      'dp_qty': dpQty,
      'dp_wt': dpWt,
      'og_qty': ogQty,
      'og_wt': ogWt,
      'egg_qty': eggQty,
      'pota_kaleji_qty': potaKalejiQty,
      'pota_kaleji_wt': potaKalejiWt,
      // Mortality
      'broiler_dead_qty': broilerDeadQty,
      'broiler_dead_wt': broilerDeadWt,
      'dp_dead_qty': dpDeadQty,
      'dp_dead_wt': dpDeadWt,
      'og_dead_qty': ogDeadQty,
      'og_dead_wt': ogDeadWt,
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
      broilerQty: map['broiler_qty'] ?? 0,
      broilerWt: map['broiler_wt'] ?? 0.0,
      muttonOpeningWt: map['mutton_opening_wt'] ?? 0.0,
      muttonClosingWt: map['mutton_closing_wt'] ?? 0.0,
      muttonQty: map['mutton_qty'] ?? 0,
      muttonWt: map['mutton_wt'] ?? 0.0,
      dpQty: map['dp_qty'] ?? 0,
      dpWt: map['dp_wt'] ?? 0.0,
      ogQty: map['og_qty'] ?? 0,
      ogWt: map['og_wt'] ?? 0.0,
      eggQty: map['egg_qty'] ?? 0,
      potaKalejiQty: map['pota_kaleji_qty'] ?? 0,
      potaKalejiWt: map['pota_kaleji_wt'] ?? 0.0,
      // Mortality
      broilerDeadQty: map['broiler_dead_qty'] ?? 0,
      broilerDeadWt: map['broiler_dead_wt'] ?? 0.0,
      dpDeadQty: map['dp_dead_qty'] ?? 0,
      dpDeadWt: map['dp_dead_wt'] ?? 0.0,
      ogDeadQty: map['og_dead_qty'] ?? 0,
      ogDeadWt: map['og_dead_wt'] ?? 0.0,
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

// --- NEW DYNAMIC CATEGORY MODEL ---
class ExpenseCategoryModel {
  final int? id;
  final String name;
  final bool isSalary;

  ExpenseCategoryModel({this.id, required this.name, this.isSalary = false});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'is_salary': isSalary ? 1 : 0};
  }

  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryModel(
      id: map['id'],
      name: map['name'],
      isSalary: map['is_salary'] == 1,
    );
  }
}

// --- NEW TRANSFER MODEL ---
class TransferModel {
  final int? id;
  final String date;
  final String fromShop;
  final String toShop;
  final String itemType;
  final double qty;
  final double weight1;
  final double weight2;

  TransferModel({
    this.id,
    required this.date,
    required this.fromShop,
    required this.toShop,
    required this.itemType,
    required this.qty,
    required this.weight1,
    required this.weight2,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'from_shop': fromShop,
      'to_shop': toShop,
      'item_type': itemType,
      'qty': qty,
      'weight_1': weight1,
      'weight_2': weight2,
    };
  }

  factory TransferModel.fromMap(Map<String, dynamic> map) {
    return TransferModel(
      id: map['id'],
      date: map['date'],
      fromShop: map['from_shop'],
      toShop: map['to_shop'],
      itemType: map['item_type'],
      qty: (map['qty'] ?? 0).toDouble(),
      weight1: (map['weight_1'] ?? 0).toDouble(),
      weight2: (map['weight_2'] ?? 0).toDouble(),
    );
  }
}
