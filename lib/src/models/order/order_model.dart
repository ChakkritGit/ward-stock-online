class Prescription {
  final String id;
  final String hn;
  final String patientName;
  final String? wardCode;
  final String? wardDesc;
  final String? priorityCode;
  final String? priorityDesc;
  final String status;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Order> order;

  Prescription({
    required this.id,
    required this.hn,
    required this.patientName,
    this.wardCode,
    this.wardDesc,
    this.priorityCode,
    this.priorityDesc,
    required this.status,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      hn: json['hn'] as String,
      patientName: json['patientName'] as String,
      wardCode: json['wardCode'] as String?,
      wardDesc: json['wardDesc'] as String?,
      priorityCode: json['priorityCode'] as String?,
      priorityDesc: json['priorityDesc'] as String?,
      status: json['status'] as String,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      order: (json['order'] as List<dynamic>)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hn': hn,
      'patientName': patientName,
      'wardCode': wardCode,
      'wardDesc': wardDesc,
      'priorityCode': priorityCode,
      'priorityDesc': priorityDesc,
      'status': status,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'order': order.map((o) => o.toJson()).toList(),
    };
  }
}

class Order {
  final String id;
  final String prescriptionId;
  final String drugId;
  final String drugName;
  final int qty;
  final String unit;
  final int position;
  final String machineId;
  final String status;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.prescriptionId,
    required this.drugId,
    required this.drugName,
    required this.qty,
    required this.unit,
    required this.position,
    required this.machineId,
    required this.status,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      prescriptionId: json['prescriptionId'] as String,
      drugId: json['drugId'] as String,
      drugName: json['drugName'] as String,
      qty: json['qty'] as int,
      unit: json['unit'] as String,
      position: json['position'] as int,
      machineId: json['machineId'] as String,
      status: json['status'] as String,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      'drugId': drugId,
      'drugName': drugName,
      'qty': qty,
      'unit': unit,
      'position': position,
      'machineId': machineId,
      'status': status,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
