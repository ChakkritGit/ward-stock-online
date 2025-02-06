class Machines {
  final String id;
  final String machineName;
  final String location;
  final int capacity;
  final bool status;
  final String comment;
  final String createdAt;
  final String updatedAt;

  Machines({
    required this.id,
    required this.machineName,
    required this.location,
    required this.capacity,
    required this.status,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'machineName': machineName,
      'location': location,
      'capacity': capacity,
      'machineStatus': status,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Machines.fromMap(Map<String, dynamic> map) {
    return Machines(
      id: map['id'] as String? ?? '',
      machineName: map['machineName'] as String? ?? '',
      location: map['location'] as String? ?? '',
      capacity: map['capacity'] as int? ?? 60,
      status: map['status'] as bool? ?? true,
      comment: map['comment'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      updatedAt: map['updatedAt'] as String? ?? '',
    );
  }
}
