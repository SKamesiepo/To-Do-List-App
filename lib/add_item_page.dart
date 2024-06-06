import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddToDoItemPage extends StatefulWidget {
  @override
  _AddToDoItemPageState createState() => _AddToDoItemPageState();
}

class _AddToDoItemPageState extends State<AddToDoItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';
  String _description = '';

  void _saveTodoItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final todoitem = {
        'item_name': _itemName,
        'description_name': _description,
        'itemsdone': 0,
      };
      await DBHelper().insertToDoItem(todoitem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add To Do Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your to-do item';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTodoItem,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
