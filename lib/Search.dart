import 'package:flutter/material.dart';

class SearchAnchors extends StatefulWidget {
  const SearchAnchors({super.key});

  @override
  State<SearchAnchors> createState() => _SearchAnchorsState();
}

class _SearchAnchorsState extends State<SearchAnchors> {
  String? selectedColor;
  List<ColorItem> searchHistory = <ColorItem>[];

  Iterable<Widget> getHistoryList(SearchController controller) {
    return searchHistory.map((color) => ListTile(
          leading: const Icon(Icons.history),
          title: Text(color.label),
          trailing: IconButton(
              icon: const Icon(Icons.call_missed),
              onPressed: () {
                controller.text = color.label;
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
              }),
          onTap: () {
            controller.closeView(color.label);
            handleSelection(color);
          },
        ));
  }

  Iterable<Widget> getSuggestions(SearchController controller) {
    final String input = controller.value.text;
    return ColorItem.values
        .where((color) => color.label.contains(input))
        .map((filteredColor) => ListTile(
              leading: CircleAvatar(backgroundColor: filteredColor.color),
              title: Text(filteredColor.label),
              trailing: IconButton(
                  icon: const Icon(Icons.call_missed),
                  onPressed: () {
                    controller.text = filteredColor.label;
                    controller.selection =
                        TextSelection.collapsed(offset: controller.text.length);
                  }),
              onTap: () {
                controller.closeView(filteredColor.label);
                handleSelection(filteredColor);
              },
            ));
  }

  void handleSelection(ColorItem color) {
    setState(() {
      selectedColor = color.label;
      if (searchHistory.length >= 5) {
        searchHistory.removeLast();
      }
      searchHistory.insert(0, color);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      barHintText: 'Search anything',
      suggestionsBuilder: (context, controller) {
        print(controller.text);
        if (controller.text.isEmpty) {
          if (searchHistory.isNotEmpty) {
            return getHistoryList(controller);
          }
          return <Widget>[
            const Center(
              child: Text('No search history.',
                  style: TextStyle(color: Colors.grey)),
            )
          ];
        }
        return getSuggestions(controller);
      },
    );
  }
}

enum ColorItem {
  red('red', Colors.red),
  orange('orange', Colors.orange),
  yellow('yellow', Colors.yellow),
  green('green', Colors.green),
  blue('blue', Colors.blue),
  indigo('indigo', Colors.indigo),
  violet('violet', Color(0xFF8F00FF)),
  purple('purple', Colors.purple),
  pink('pink', Colors.pink),
  silver('silver', Color(0xFF808080)),
  gold('gold', Color(0xFFFFD700)),
  beige('beige', Color(0xFFF5F5DC)),
  brown('brown', Colors.brown),
  grey('grey', Colors.grey),
  black('black', Colors.black),
  white('white', Colors.white);

  const ColorItem(this.label, this.color);
  final String label;
  final Color color;
}

//---------------------------------------------------------------------------------------------------------------------
// class Odoo extends StatelessWidget {
//   const Odoo({super.key});

//   Future<dynamic> fetchContacts() {
//     return orpc.callKw({
//       'model': 'stock.picking',
//       'method': 'search_read',
//       'args': [
//         [
//           ['name', '=', 'WH/IN/00002']
//         ]
//       ],
//       'kwargs': {
//         'fields': [
//           'location_dest_id',
//           'location_id',
//           'move_type',
//           'picking_type_id',
//           'lot_id'
//         ],
//         'limit': 80,
//       },
//     });
//   }

//   Widget buildListItem(Map<String, dynamic> record) {
//     var unique = record['location_dest_id'] as String;
//     unique = unique.replaceAll(RegExp(r'[^0-9]'), '');
//     final avatarUrl =
//         '${orpc.baseURL}/web/image?model=res.partner&field=image_128&id=${record["id"]}&unique=$unique';
//     return ListTile(
//       leading: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
//       title: Text(record['name']),
//       subtitle: Text(record['email'] is String ? record['email'] : ''),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Contacts'),
//       ),
//       body: Center(
//         child: FutureBuilder(
//             future: fetchContacts(),
//             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//               if (snapshot.hasData) {
//                 return ListView.builder(
//                     itemCount: snapshot.data.length,
//                     itemBuilder: (context, index) {
//                       final record =
//                           snapshot.data[index] as Map<String, dynamic>;
//                       return buildListItem(record);
//                     });
//               } else {
//                 if (snapshot.hasError) {
//                   return Text('Unable to fetch data');
//                 }
//                 return CircularProgressIndicator();
//               }
//             }),
//       ),
//     );
//   }
// }

// class TextInput extends StatefulWidget {
//   const TextInput({super.key});

//   @override
//   State<TextInput> createState() => _TextInputState();
// }

// class _TextInputState extends State<TextInput> {
//   final controller = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//           prefixIcon: Icon(Icons.media_bluetooth_off),
//           labelText: "Type a message: "),
//     );
//   }
// }

// class ComponentDecoration extends StatefulWidget {
//   const ComponentDecoration({
//     super.key,
//     required this.child,
//     this.tooltipMessage = '',
//   });

//   final Widget child;
//   final String? tooltipMessage;

//   @override
//   State<ComponentDecoration> createState() => _ComponentDecorationState();
// }

// class _ComponentDecorationState extends State<ComponentDecoration> {
//   final focusNode = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: smallSpacing),
//         child: Column(
//           children: [
//             ConstrainedBox(
//               constraints:
//                   const BoxConstraints.tightFor(width: widthConstraint),
//               // Tapping within the a component card should request focus
//               // for that component's children.
//               child: Focus(
//                 focusNode: focusNode,
//                 canRequestFocus: true,
//                 child: GestureDetector(
//                   onTapDown: (_) {
//                     focusNode.requestFocus();
//                   },
//                   behavior: HitTestBehavior.opaque,
//                   child: Card(
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       side: BorderSide(
//                         color: Theme.of(context).colorScheme.outlineVariant,
//                       ),
//                       borderRadius: const BorderRadius.all(Radius.circular(12)),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 5.0, vertical: 20.0),
//                       child: Center(
//                         child: widget.child,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
