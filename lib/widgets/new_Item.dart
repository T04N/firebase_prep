import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/categories.dart';
import '../models/category.dart';
import '../models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enterName = "";
  var _enterQuantity = "";
  var _selectedCategory = categories.entries.first.value;

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.https("flutter-prep-f989c-default-rtdb.firebaseio.com", "shopping-list.json");

      // Đợi phản hồi từ server
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'name': _enterName,
            'quantity': _enterQuantity,
            'category': _selectedCategory.title,
          }));

      print("TESTING");
      print(response.body); // In ra phản hồi để kiểm tra
      print(response.statusCode); // In ra mã trạng thái để kiểm tra

      if (response.statusCode == 200) {
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
      } else {
        print('Failed to add item. Status code: ${response.statusCode}');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add new item")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a name";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enterName = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: "1",
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a quantity"; // Sửa lại thông báo lỗi phù hợp
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterQuantity = value!;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                      onSaved: (value) {
                        _selectedCategory = value!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: Text("Reset")),
                  ElevatedButton(onPressed: _saveItem, child: Text("Add item"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
