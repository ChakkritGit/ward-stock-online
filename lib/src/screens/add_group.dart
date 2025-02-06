// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vending_standalone/src/constants/instants_dropdown.dart';
import 'package:vending_standalone/src/constants/style.dart';
import 'package:vending_standalone/src/models/drugs/drug_list_model.dart';
import 'package:vending_standalone/src/models/drugs/drug_model.dart';
import 'package:vending_standalone/src/models/inventory/inventory.dart';
import 'package:vending_standalone/src/widgets/manage_inventory_group/add_group_form.dart';
import 'package:vending_standalone/src/widgets/md_widget/app_bar.dart';

class AddGroup extends StatefulWidget {
  final String? titleText;
  final DrugGroup? group;
  const AddGroup({super.key, this.group, this.titleText});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  List<Drugs> drugs = [];
  List<Inventories> inventory = [];

  Future<void> loadData() async {
    final drugsData = await InventoryPosition.getAvailableDrug(context);
    final inventoryData = await InventoryPosition.getInventory(context);
    drugs = drugsData.map((map) => Drugs.fromMap(map)).toList();
    inventory = inventoryData.map((map) => Inventories.fromMap(map)).toList();
    setState(() {});
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text: widget.titleText ?? 'เพิ่มกรุ๊ป',
        isBottom: false,
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          padding: CustomPadding.paddingAll_15,
          child: Form(
            child: AddGroupForm(
              drugs: drugs,
              inventory: inventory,
              group: widget.group,
            ),
          ),
        ),
      ),
    );
  }
}
