import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import '../models/picking_line_model.dart';

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
  int totalLineCount = 1;
  int currFinishLineCount = 0;
  bool progressIndicator = false;
  String orderState = 'draft';

  PickingLine? pl;
  List<dynamic> locationList = [];
  List<PickingLineModel>? pickingLineList;
  @override
  void initState() {
    stockMoveId = widget.data['id'];
    orderState = widget.data['state'];
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

  dynamic writeLine(int? id, args) async {
    dynamic _data = await orpc.callKw({
      'model': 'stock.move.line',
      'method': 'write',
      'args': [
        id,
        {args[0]: args[1]}
      ],
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
      if (currLocationIndex > 0) currLocationIndex--;
      currPickingLocation = locationList[currLocationIndex];
      pickingLineList = pl?.getPickingLines(currPickingLocation);
    });
  }

  void goNextLocation() {
    setState(() {
      if (currLocationIndex < locationList.length - 1) currLocationIndex++;
      currPickingLocation = locationList[currLocationIndex];
      pickingLineList = pl?.getPickingLines(currPickingLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double? progress =
        progressIndicator ? null : currFinishLineCount / totalLineCount;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('拣货'),
        actions: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh), onPressed: refresh),
          orderState == 'done'
              ? Container()
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
                      }
                      setState(() {
                        progressIndicator = false;
                      });
                    });
                  })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            LinearProgressIndicator(
              value: progress,
            ),
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
                        icon: const Icon(Icons.arrow_left))
                    : const SizedBox(width: 48),
                SizedBox(
                    height: 100,
                    width: 220,
                    child: Card(
                        color: Colors.grey,
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
                        icon: const Icon(Icons.arrow_right))
                    : const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Scrollbar(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: pickingLineList?.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 75,
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Color.fromARGB(146, 174, 174, 174)
                                : Color.fromARGB(219, 236, 236, 236),
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
                                          autofocus: true,
                                          value: pickingLineList?[index].picked,
                                          onChanged: orderState == 'done'
                                              ? null
                                              : (bool? value) async {
                                                  bool temp = await writeLine(
                                                      pickingLineList?[index]
                                                          .id,
                                                      ['picked', value]);
                                                  setState(() {
                                                    currFinishLineCount +=
                                                        (value ?? false
                                                            ? 1
                                                            : -1);
                                                    pl?.setPickingLine(
                                                        pickingLineList?[index]
                                                            .id,
                                                        value!);
                                                    pickingLineList?[index]
                                                        .picked = value!;
                                                  });
                                                }),
                                    ],
                                  ),
                                ),
                              ]),
                        );
                      })), //Text("$displayName, $quantity")
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            overflowAlignment: OverflowBarAlignment.center,
            alignment: MainAxisAlignment.center,
            overflowSpacing: 5.0,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    //shadowColor = !shadowColor;
                  });
                },
                icon: Icon(Icons.visibility
                    //shadowColor ? Icons.visibility_off : Icons.visibility,
                    ),
                label: const Text('shadow color'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
