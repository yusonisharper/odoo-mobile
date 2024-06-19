import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import '../models/picking_line_model.dart';

class StockPickingModel {
  //String pickingLocation;
  int id;
  String displayName;
  String locationId;
  String state;
  double quantity;

  StockPickingModel({
    //required this.pickingLocation,
    required this.id,
    required this.displayName,
    required this.locationId,
    required this.state,
    required this.quantity,
  });
}

class BatchValidate extends StatefulWidget {
  const BatchValidate({super.key});

  @override
  State<BatchValidate> createState() => _BatchValidateState();
}

class _BatchValidateState extends State<BatchValidate> {
  List<StockPickingModel> stockPickingList = [];

  void addStockPickingOrder(String ref) async {
    var stockPickingData = await searchRead(ref);
    if (stockPickingData.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('无法找到')));
      return;
    } else if (stockPickingData.length != 1) {
      print("错误：多个同样的订单");
      return;
    } else {
      var pickingLines = await searchReadLines(stockPickingData[0]);
      PickingLine pl = PickingLine(pickingLineList: pickingLines);
      List<dynamic> locationList = pl.getLocations();
      if (locationList.length > 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('错误：多个库位')));
        return;
      }
      List<PickingLineModel> pickingLineList =
          pl.getPickingLines(locationList[0]);
      PickingLineModel temp = pickingLineList[0];
      double qty = 0;
      for (final pickingLine in pickingLineList) {
        if (pickingLine.displayName != temp.displayName) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('错误：多个不同的产品')));
          return;
        }
        qty = pickingLine.quantity;
        temp = pickingLine;
      }
      stockPickingList.add(StockPickingModel(
          id: stockPickingData[0].id,
          displayName: pickingLineList[0].displayName,
          locationId: locationList[0],
          state: stockPickingData[0].state,
          quantity: qty));
    }
  }

  Future<dynamic> searchRead(String ref) {
    return orpc.callKw({
      'model': 'stock.picking',
      'method': 'search_read',
      'args': [
        [
          ['name', '=', ref]
        ]
      ],
      'kwargs': {
        'fields': [
          'id',
          'name',
          'origin',
          'location_id',
          'state',
        ],
        'limit': 80,
      },
    });
  }

  Future<List> searchReadLines(Map data) async {
    List<dynamic> result = await orpc.callKw({
      'model': 'stock.move.line',
      'method': 'search_read',
      'args': [
        [
          ['picking_id', 'in', data['name']]
        ]
      ],
      'kwargs': {
        'fields': [
          'location_id',
          'display_name',
          'quantity',
          'picked',
        ]
      },
    });
    if (result.isEmpty) {
      print("It is Empty!!!");
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
