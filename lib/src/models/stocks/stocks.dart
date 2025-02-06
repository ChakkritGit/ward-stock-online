class Stocks {
  final String inventoryId;
  final int inventoryPosition;
  final int inventoryQty;
  final int inventoryMin;
  final int inventoryMAX;
  final bool inventoryStatus;
  final String drugId;
  final String drugName;
  final String drugUnit;
  final String drugImage;
  final int drugPriority;

  Stocks({
    required this.inventoryId,
    required this.inventoryPosition,
    required this.inventoryQty,
    required this.inventoryMin,
    required this.inventoryMAX,
    required this.inventoryStatus,
    required this.drugId,
    required this.drugName,
    required this.drugUnit,
    required this.drugImage,
    required this.drugPriority,
  });

  factory Stocks.fromMap(Map<String, dynamic> map) {
    return Stocks(
      inventoryId: map['inventoryId'] ?? '',
      inventoryPosition: map['inventoryPosition'] ?? '',
      inventoryQty: map['inventoryQty'] ?? '',
      inventoryMin: map['inventoryMin'] ?? '',
      inventoryMAX: map['inventoryMAX'] ?? '',
      inventoryStatus: map['inventoryStatus'] ?? true,
      drugId: map['drugId'] ?? '',
      drugName: map['drugName'] ?? '',
      drugUnit: map['drugUnit'] ?? '',
      drugImage: map['drugImage'] ?? '',
      drugPriority: map['drugPriority'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventoryId': inventoryId,
      'inventoryPosition': inventoryPosition,
      'inventoryQty': inventoryQty,
      'inventoryMin': inventoryMin,
      'inventoryMAX': inventoryMAX,
      'inventoryStatus': inventoryStatus,
      'drugId': inventoryStatus,
      'drugName': drugName,
      'drugUnit': drugUnit,
      'drugImage': drugImage,
      'drugPriority': drugPriority,
    };
  }
}
