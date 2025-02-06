class Drugs {
  final String id;
  final String drugCode;
  final String drugName;
  final String unit;
  final DateTime drugLot;
  final DateTime drugExpire;
  final int drugPriority;
  final int? weight;
  final bool status;
  final String? picture;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Drugs({
    required this.id,
    required this.drugCode,
    required this.drugName,
    required this.unit,
    required this.drugLot,
    required this.drugExpire,
    this.drugPriority = 1,
    this.weight = 0,
    this.status = true,
    this.picture,
    this.comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drugCode': drugCode,
      'drugName': drugName,
      'unit': unit,
      'drugLot': drugLot.toIso8601String(),
      'drugExpire': drugExpire.toIso8601String(),
      'drugPriority': drugPriority,
      'weight': weight,
      'status': status,
      'picture': picture,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Drugs.fromMap(Map<String, dynamic> map) {
    return Drugs(
      id: map['id'] as String? ?? '',
      drugCode: map['drugCode'] as String? ?? '',
      drugName: map['drugName'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
      drugLot: DateTime.tryParse(map['drugLot'] ?? '') ?? DateTime.now(),
      drugExpire: DateTime.tryParse(map['drugExpire'] ?? '') ?? DateTime.now(),
      drugPriority: map['drugPriority'] as int? ?? 1,
      weight: map['weight'] as int? ?? 0,
      status: map['status'] as bool? ?? true,
      picture: map['picture'] ?? '',
      comment: map['comment'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
