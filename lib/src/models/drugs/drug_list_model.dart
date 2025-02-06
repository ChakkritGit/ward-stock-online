class DrugInventory {
  final String inventoryId;
  final int inventoryPosition;
  final int inventoryQty;

  DrugInventory({
    required this.inventoryId,
    required this.inventoryPosition,
    required this.inventoryQty,
  });

  factory DrugInventory.fromJson(Map<String, dynamic> json) {
    return DrugInventory(
      inventoryId: json['inventoryId'],
      inventoryPosition: json['inventoryPosition'],
      inventoryQty: json['inventoryQty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inventoryId': inventoryId,
      'inventoryPosition': inventoryPosition,
      'inventoryQty': inventoryQty,
    };
  }
}

class DrugGroup {
  final String groupid;
  final String drugid;
  final String drugname;
  final String drugimage;
  final String drugunit;
  final int? drugpriority;
  final int? groupmin;
  final int? groupmax;
  final List<DrugInventory> inventoryList;

  DrugGroup({
    required this.groupid,
    required this.drugid,
    required this.drugname,
    required this.drugimage,
    required this.drugunit,
    required this.drugpriority,
    required this.groupmin,
    required this.groupmax,
    required this.inventoryList,
  });

  factory DrugGroup.fromMap(Map<String, dynamic> json) {
    var inventoryListFromJson = json['inventoryList'] as List?;
    List<DrugInventory> inventoryList =
        inventoryListFromJson?.map((i) => DrugInventory.fromJson(i)).toList() ??
            [];

    return DrugGroup(
      groupid: json['groupid'] ?? '',
      drugid: json['drugid'] ?? '',
      drugname: json['drugname'] ?? '',
      drugimage: json['drugimage'] ?? '',
      drugunit: json['drugunit'] ?? '',
      drugpriority: json['drugpriority'] ?? 0,
      groupmin: json['groupmin'] ?? 0,
      groupmax: json['groupmax'] ?? 0,
      inventoryList: inventoryList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupid': groupid,
      'drugid': drugid,
      'drugname': drugname,
      'drugimage': drugimage,
      'drugunit': drugunit,
      'drugpriority': drugpriority,
      'groupmin': groupmin,
      'groupmax': groupmax,
      'inventoryList': inventoryList.map((i) => i.toJson()).toList(),
    };
  }
}
