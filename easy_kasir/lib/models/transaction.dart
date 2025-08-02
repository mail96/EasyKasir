class Transaction {
  final String id;
  final DateTime dateTime;
  final List<Map<String, dynamic>> items;
  final String paymentMethod;
  final double total;
  final double discount;

  Transaction({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.paymentMethod,
    required this.total,
    required this.discount,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      dateTime: map['dateTime'].toDate(),
      items: List<Map<String, dynamic>>.from(map['items']),
      paymentMethod: map['paymentMethod'],
      total: map['total'],
      discount: map['discount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime,
      'items': items,
      'paymentMethod': paymentMethod,
      'total': total,
      'discount': discount,
    };
  }
}