import 'dart:convert'; // Used to convert our list to text for storage
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoScreen(),
  ));
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // This list holds our tasks. Each task is a Map with 'title' and 'isDone'
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load data when app starts
  }

  // --- SAVE & LOAD LOGIC (SharedPreferences) ---

  // Save the list to phone storage
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    // We convert the List into a String (JSON) because prefs can only store strings
    final String encodedData = jsonEncode(_tasks);
    await prefs.setString('todo_list', encodedData);
  }

  // Load the list from phone storage
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('todo_list');

    if (encodedData != null) {
      setState(() {
        // Convert the String back into a List
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(encodedData));
      });
    }
  }

  // --- TASK ACTIONS (Add, Edit, Delete) ---

  void _addTask(String title) {
    setState(() {
      _tasks.add({'title': title, 'isDone': false});
    });
    _saveTasks(); // Save immediately after adding
  }

  void _editTask(int index, String newTitle) {
    setState(() {
      _tasks[index]['title'] = newTitle;
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
    _saveTasks();
  }

  // --- UI DIALOG FOR ADDING/EDITING ---

  void _showTaskDialog({int? index}) {
    TextEditingController _controller = TextEditingController();
    if (index != null) {
      _controller.text = _tasks[index]['title']; // Pre-fill if editing
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Task' : 'Edit Task'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter task name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                if (index == null) {
                  _addTask(_controller.text);
                } else {
                  _editTask(index, _controller.text);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- MAIN UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text("No tasks yet. Add one!"))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              // Checkbox Logic
              leading: Checkbox(
                value: _tasks[index]['isDone'],
                onChanged: (_) => _toggleTask(index),
              ),
              // Task Title (Strikethrough if done)
              title: Text(
                _tasks[index]['title'],
                style: TextStyle(
                  decoration: _tasks[index]['isDone']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: _tasks[index]['isDone'] ? Colors.grey : Colors.black,
                ),
              ),
              // Edit and Delete Buttons
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showTaskDialog(index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}