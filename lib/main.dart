import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_item_page.dart';

void main() {
  runApp(TodoListApp());
}

class TodoListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _todolistitem = [];
  String _searchQuery = '';
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _fetchToDoItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchToDoItems() async {
    setState(() {
      _isLoading = true;
    });
    final todoitems = await DBHelper().getToDoItems();
    setState(() {
      _todolistitem = todoitems;
      _isLoading = false;
      _controller.forward();
    });
  }

  void _filterTodoItems(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _markTodoItem(int id) async {
    await DBHelper().markToDoItem(id);
    _fetchToDoItems();
  }

  void _deleteTodoItem(int id) async {
    await DBHelper().deleteToDoItem(id);
    _fetchToDoItems();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTodoItems = _todolistitem.where((todoitem) {
      final fullName =
          '${todoitem['item_name']} ${todoitem['description_name']}';
      return fullName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filteredTodoItems.sort((a, b) => a['itemsdone'].compareTo(b['itemsdone']));

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 245, 255),
                Color.fromARGB(255, 236, 236, 236)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 116, 196, 119),
                child: Icon(Icons.add, color: Colors.black, size: 32),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddToDoItemPage()),
                  ).then((_) {
                    _fetchToDoItems();
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterTodoItems,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredTodoItems.length,
                    itemBuilder: (context, index) {
                      final todoitem = filteredTodoItems[index];
                      return SlideTransition(
                        position: _offsetAnimation,
                        child: Card(
                          color: todoitem['itemsdone'] == 1
                              ? Colors.green[100]
                              : Colors.grey[100],
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Text(
                              '${todoitem['item_name']} ${todoitem['description_name']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    todoitem['itemsdone'] == 1
                                        ? Icons.check
                                        : Icons.check_box_outline_blank,
                                    color: todoitem['itemsdone'] == 1
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                  onPressed: () {
                                    if (todoitem['itemsdone'] != 1) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Confirm Item Complete'),
                                          content: Text(
                                              'Mark item completed for "${todoitem['item_name']}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _markTodoItem(todoitem['id']);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Confirm'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Delete ToDo Item'),
                                        content: Text(
                                            'Are you sure you want to delete "${todoitem['item_name']}" ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteTodoItem(todoitem['id']);
                                              Navigator.pop(context);
                                            },
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
