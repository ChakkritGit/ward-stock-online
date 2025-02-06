class Inventories {
  final String id;
  final int position;
  final int qty;
  final int min;
  final int max;
  final bool status;
  final String machineId;
  final String comment;
  final String createdAt;
  final String updatedAt;

  Inventories({
    required this.id,
    required this.position,
    required this.qty,
    required this.min,
    required this.max,
    required this.status,
    required this.machineId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Inventories.fromMap(Map<String, dynamic> map) {
    return Inventories(
      id: map['id'] as String? ?? '',
      position: map['position'] as int? ?? 0,
      qty: map['qty'] as int? ?? 0,
      min: map['min'] as int? ?? 0,
      max: map['max'] as int? ?? 0,
      status: map['status'] as bool? ?? false,
      machineId: map['machineId'] as String? ?? '',
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': position,
      'qty': qty,
      'min': min,
      'max': max,
      'status': status,
      'machineId': machineId,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
