import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'modules/stock_picking.dart';

const rowDivider = SizedBox(width: 20);
const colDivider = SizedBox(height: 10);
const tinySpacing = 3.0;
const smallSpacing = 10.0;
const double cardWidth = 115;
const double widthConstraint = 450;
const primaryColor = Color.fromARGB(194, 99, 118, 227);

final orpc = OdooClient('http://192.168.0.167:8069');
void main() async {
  await orpc.authenticate('mydb', 'admin', 'admin');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odoo Mobile',
      theme: ThemeData(
        primaryColor: primaryColor,
        //primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Main'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Next page'),
                    ),
                    body: const Center(
                      child: Text(
                        'This is the next page',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [MainMenuTextInput(), Cards()]),
    );
  }
}

// search bar on the top
final TextEditingController _controllerOutlined = TextEditingController();

class MainMenuTextInput extends StatelessWidget {
  MainMenuTextInput({super.key});

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
  // stock.move 'product_id', 'product_uom_qty'
  // stock.move.line 'quant_id', 'quantity,

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(smallSpacing),
      child: TextField(
        onSubmitted: (String text) {
          searchRead(text).then((dynamicData) {
            if (dynamicData.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('无法找到')));
            } else {
              //print(dynamicData[0]);
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return StockPicking(dynamicData[dynamicData.length - 1]);
              }));
            }
          });
        },
        controller: _controllerOutlined,
        decoration: InputDecoration(
          prefixIcon: _Search(searchRead),
          suffixIcon: _ClearButton(controller: _controllerOutlined),
          // _controllerOutlined.text == ""
          //     ? Container()
          //     : _ClearButton(controller: _controllerOutlined),
          labelText: '仓库作业',
          hintText: '请扫描条码',
          //helperText: '请扫描条码',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// search icon in search bar
class _Search extends StatelessWidget {
  final Future<dynamic> Function(String s) callback;
  const _Search(this.callback);
  //Map? data;
  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          callback(_controllerOutlined.text).then((dynamicData) {
            if (dynamicData.isEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('无法找到')));
            } else {
              //print(dynamicData[0]);
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return StockPicking(dynamicData[dynamicData.length - 1]);
              }));
            }
          });
        },
      );
}

// clear icon in search bar
class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

class Cards extends StatelessWidget {
  const Cards({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: cardWidth,
          width: cardWidth,
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return StockPicking({"1": "2"});
                }));
              },
              child: Column(children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("    拣货"),
                )
              ]),
            ),
          ),
        ),
        SizedBox(
          height: cardWidth,
          width: cardWidth,
          child: Card(
            color: Theme.of(context).colorScheme.surfaceVariant,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Filled'),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: cardWidth,
          width: cardWidth,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Outlined'),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
