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
  final double broilerWt;

  // --- NEW MUTTON FIELDS ---
  final double muttonOpeningWt; // Yesterday's Unsold
  final double muttonClosingWt; // Today's Unsold
  final double muttonWt; // Raw Weight

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
    required this.muttonOpeningWt, // <-- Add this
    required this.muttonClosingWt, // <-- Add this
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
      'mutton_opening_wt': muttonOpeningWt, // <-- Add this
      'mutton_closing_wt': muttonClosingWt, // <-- Add this
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
      broilerWt: map['broiler_wt'] ?? 0.0,
      muttonOpeningWt:
          map['mutton_opening_wt'] ?? 0.0, // <-- Add this (with fallback)
      muttonClosingWt:
          map['mutton_closing_wt'] ?? 0.0, // <-- Add this (with fallback)
      muttonWt: map['mutton_wt'] ?? 0.0,
      dpWt: map['dp_wt'] ?? 0.0,
      ogWt: map['og_wt'] ?? 0.0,
      eggQty: map['egg_qty'] ?? 0,
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
