import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';

import '../data/dummy_items.dart';
import '../models/grocery_item.dart';
import 'new_Item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryList = [];
  var _isLoading = true;
  var _error ;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final url = Uri.https(
        "flutter-prep-f989c-default-rtdb.firebaseio.com", "shopping-list.json");
    final response = await http.get(url);
    if (response.statusCode > 400) {
      setState(() {
      _error = "have some issue when getching data ";
      });
    };
print(response.body);
    if (response.body == 'null') {
      setState(() {
        _isLoading= false;
      });
      return;
    }

    final List<GroceryItem> _temporaryList = [];
    final Map<String, dynamic> listData =
    jsonDecode(response.body);
    for (final item in listData.entries) {
      final category = categories.entries.firstWhere((catItem) => item.value["category"] == catItem.value.title).value;

      // Sử dụng int.tryParse để tránh lỗi nếu giá trị không thể chuyển đổi thành số
      final quantity = int.tryParse(item.value['quantity']) ?? 0;

      _temporaryList.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: quantity, // Sử dụng giá trị đã chuyển đổi
        category: category,
      ));
    }

    setState(() {
    _groceryList =_temporaryList;
    });
  }


  Future<void> _addItem(BuildContext context) async {
    final newGrocery = await Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => NewItem()));

if (newGrocery == Null){
  print("null new");
  return;
}
    setState(() {
      _groceryList.add(newGrocery);
   });


  }

  Future<void> _removeItem(GroceryItem item) async {
    final index  = _groceryList.indexOf(item);
    setState(() {
      _groceryList.remove(item);
    });
    final url = Uri.https(
        "flutter-prep-f989c-default-rtdb.firebaseio.com", "shopping-list/${item.id}.json");
    final response  = await http.delete(url);
    if (response.statusCode >= 400 )  {
      _groceryList.insert(index, item) ;
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No items add yet"),);

    if (_isLoading) {
      content =const Center(child: CircularProgressIndicator());
    }

    if (_groceryList.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryList.length,
        itemBuilder: (ctx, index) =>
            Dismissible(
              onDismissed: (direction) {
                _removeItem(_groceryList[index]);
              },
              key: ValueKey(_groceryList[index]),
              child: ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryList[index].category.color,
                ),
                title: Text(
                  _groceryList[index].name,
                ),
                trailing: Text(_groceryList[index].quantity.toString()),
              ),
            ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Groceries"),
        actions: [
          IconButton(
              onPressed: () {
                _addItem(context);
              },
              icon: Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
