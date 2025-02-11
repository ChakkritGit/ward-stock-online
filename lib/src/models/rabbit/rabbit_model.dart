class OrderRabbit {
  final String id;
  final String presId;
  final int qty;
  final int position;
  final int priority;

  OrderRabbit({
    required this.id,
    required this.presId,
    required this.qty,
    required this.position,
    required this.priority
  });

  factory OrderRabbit.fromMap(Map<String, dynamic> map) {
    return OrderRabbit(
      id: map['id'] as String,
      presId: map['presId'] as String,
      qty: map['qty'] as int,
      position: map['position'] as int,
      priority: map['priority'] as int,
    );
  }
}
