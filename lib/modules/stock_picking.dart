import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import '../models/picking_line_model.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';

class StockPicking extends StatefulWidget {
  final Map data;
  const StockPicking(this.data, {super.key});
  @override
  State<StockPicking> createState() => _StockPickingState();
}

class _StockPickingState extends State<StockPicking> {
  int stockMoveId = 0;
  String currPickingLocation = "";
  int currLocationIndex = 0;
  bool currLocationIsScan = false;
  int totalLineCount = 1;
  int currFinishLineCount = 0;
  bool progressIndicator = false;
  String orderState = 'draft';
  String barcodeScanRes = '';
  bool isDone = false;
  bool fullBoxQuantity = false;

  PickingLine? pl;
  List<dynamic> locationList = [];
  List<PickingLineModel>? pickingLineList;
  @override
  void initState() {
    stockMoveId = widget.data['id'];
    orderState = widget.data['state'];
    isDone = _isDone();
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    pl = PickingLine(pickingLineList: await searchReadLines());
    setState(() {
      locationList = pl?.getLocations() ?? [];
      currPickingLocation = locationList[currLocationIndex];
      pickingLineList = pl?.getPickingLines(currPickingLocation);
      totalLineCount = pl?.getLineCount() ?? 1;
      currFinishLineCount = pl?.getPickedLineCount() ?? 0;
    });
  }

  Future<List> searchReadLines() async {
    List<dynamic> _data = await orpc.callKw({
      'model': 'stock.move.line',
      'method': 'search_read',
      'args': [
        [
          ['picking_id', 'in', widget.data['name']]
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
    if (_data.isEmpty) {
      print("It is Empty!!!");
    }
    return _data;
  }

  dynamic writeLine(int? id, Map args) async {
    dynamic _data = await orpc.callKw({
      'model': 'stock.move.line',
      'method': 'write',
      'args': [id, args],
      'kwargs': {},
    });
    if (_data == null) {
      print("It is Empty!!!");
    }
    return _data;
  }

  Future<bool> validate() async {
    PickingLine temp = PickingLine(pickingLineList: await searchReadLines());
    bool _data = false;
    if (temp.isAllPicked()) {
      _data = await orpc.callKw({
        'model': 'stock.picking',
        'method': 'button_validate',
        'args': [stockMoveId],
        'kwargs': {},
      });
    }
    return _data;
  }

  Future<void> refresh() async {
    setState(() {
      progressIndicator = true;
    });
    _loadData();
    setState(() {
      progressIndicator = false;
    });
  }

  void goPrevLocation() {
    setState(() {
      if (currLocationIndex > 0) {
        currLocationIndex--;
        currLocationIsScan = false;
      }
      currPickingLocation = locationList[currLocationIndex];
      pickingLineList = pl?.getPickingLines(currPickingLocation);
    });
  }

  void goNextLocation() {
    setState(() {
      if (currLocationIndex < locationList.length - 1) {
        currLocationIndex++;
        currLocationIsScan = false;
      }
      currPickingLocation = locationList[currLocationIndex];
      pickingLineList = pl?.getPickingLines(currPickingLocation);
    });
  }

  bool _isDone() {
    return orderState == 'done';
  }

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double? progress =
        progressIndicator ? null : currFinishLineCount / totalLineCount;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: primaryColor,
        title: const Text('拣货'),
        actions: [
          IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () async {
                barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                    "#ff6666", "Cancel", true, ScanMode.DEFAULT);
                if (barcodeScanRes == currPickingLocation)
                  currLocationIsScan = true;
                for (PickingLineModel line in pickingLineList ?? []) {
                  if (line.displayName == barcodeScanRes) {
                    dynamic temp = await writeLine(line.id, {'picked': true});
                    _loadData();
                    break;
                  }
                }
              }),
          IconButton(icon: const Icon(Icons.refresh), onPressed: refresh),
          isDone
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      progressIndicator = true;
                    });
                    validate().then((validated) {
                      if (!validated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('没有全部拣货，无法验证')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('验证成功')));
                        isDone = true;
                      }
                      setState(() {
                        progressIndicator = false;
                      });
                    });
                  })
        ],
        bottom: PreferredSize(
          preferredSize: Size(size.width, 0),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            tween: Tween<double>(
              begin: 0,
              end: progress ?? currFinishLineCount / totalLineCount,
            ),
            builder: (context, value, _) => LinearProgressIndicator(
                value: progressIndicator ? null : value),
          ),
        ), //LinearProgressIndicator(value: progress),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    // Note: Styles for TextSpans must be explicitly defined.
                    // Child text spans will inherit styles from parent
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                          text: '参考号: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${widget.data['name']}'),
                    ],
                  ),
                )),
            Container(
                alignment: Alignment.topLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      const TextSpan(
                          text: '源单据: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${widget.data['origin']}'),
                    ],
                  ),
                )),
            const Divider(),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                currLocationIndex > 0
                    ? IconButton(
                        onPressed: goPrevLocation,
                        icon: const Icon(Icons.arrow_left, size: 38))
                    : const SizedBox(width: 54),
                SizedBox(
                    height: 100,
                    width: 220,
                    child: Card(
                        color: isDone
                            ? Colors.grey
                            : (currLocationIsScan
                                ? Colors.greenAccent[100]
                                : Colors.indigoAccent[100]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            currPickingLocation,
                            textScaler: const TextScaler.linear(2),
                          )),
                        ))),
                currLocationIndex < locationList.length - 1
                    ? IconButton(
                        onPressed: goNextLocation,
                        icon: const Icon(Icons.arrow_right, size: 38))
                    : const SizedBox(width: 54),
              ],
            ),
            const SizedBox(height: 25),
            Flexible(
              child: Scrollbar(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: pickingLineList?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 75,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.grey
                                : (index % 2 == 0
                                    ? Colors.indigo[100]
                                    : Colors.indigo[50]),
                            //border: Border.all(),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 230,
                                  child: Text(
                                      "${pickingLineList?[index].displayName}"),
                                ),
                                const VerticalDivider(
                                  thickness: 1,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  //width: 30,
                                  child: Row(
                                    children: [
                                      Text(
                                          "${pickingLineList?[index].quantity.toInt()}",
                                          textScaler:
                                              const TextScaler.linear(1.5)),
                                      Checkbox(
                                          activeColor: Colors.green,
                                          autofocus: true,
                                          value: pickingLineList?[index].picked,
                                          onChanged: isDone
                                              ? null
                                              : (bool? value) async {
                                                  bool temp = await writeLine(
                                                      pickingLineList?[index]
                                                          .id,
                                                      {'picked': value});
                                                  _loadData();
                                                }),
                                    ],
                                  ),
                                ),
                              ]),
                        );
                      })),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            // overflowAlignment: OverflowBarAlignment.center,
            // alignment: MainAxisAlignment.center,
            // overflowSpacing: 1,
            children: [
              Switch(
                thumbIcon: thumbIcon,
                value: fullBoxQuantity,
                onChanged: (bool value) {
                  setState(() {
                    fullBoxQuantity = value;
                  });
                },
              ),
              Text("多件扫描？"),
              SizedBox(
                width: 25,
              ),
              TextButton(
                  child: const Text(
                    'Show all picking line',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      showDragHandle: true,
                      context: context,
                      constraints: const BoxConstraints(maxWidth: 640),
                      builder: (context) {
                        return SizedBox(
                          height: 350,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: pl?.pickingLineList.length ?? 0,
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: Row(children: [
                                      SizedBox(
                                          height: 100,
                                          width: 280,
                                          child: Text(
                                              "${pl?.pickingLineList[index]}")),
                                    ]),
                                  );
                                }),
                          ),
                        );
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
