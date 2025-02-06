class OrderRabbit {
  final String id;
  final String presId;
  final int qty;
  final int position;

  OrderRabbit({
    required this.id,
    required this.presId,
    required this.qty,
    required this.position,
  });

  factory OrderRabbit.fromMap(Map<String, dynamic> map) {
    return OrderRabbit(
      id: map['id'] as String,
      presId: map['presId'] as String,
      qty: map['qty'] as int,
      position: map['position'] as int,
    );
  }
}
