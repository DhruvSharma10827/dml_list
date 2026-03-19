import 'dart:io';
import 'dart:convert';
import '../models/todo_model.dart';

class DatabaseService {
  late File _file;
  List<TodoModel> _todos = [];
  bool _initialized = false;

  // Initialize database file
  Future<void> _init() async {
    if (_initialized) return;
    
    final dir = Directory.systemTemp;
    _file = File('${dir.path}/dml_list_todos.json');
    
    if (await _file.exists()) {
      final content = await _file.readAsString();
      if (content.isNotEmpty) {
        final List<dynamic> json = jsonDecode(content);
        _todos = json.map((e) => TodoModel.fromMap(e)).toList();
      }
    }
    _initialized = true;
  }

  // Save to file
  Future<void> _save() async {
    final json = _todos.map((e) => e.toMap()).toList();
    await _file.writeAsString(jsonEncode(json));
  }

  // Get all todos (sorted: incomplete first, then completed at bottom)
  Future<List<TodoModel>> getAllTodos() async {
    await _init();
    
    _todos.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    
    return List.from(_todos);
  }

  // Insert a todo
  Future<void> insertTodo(TodoModel todo) async {
    await _init();
    _todos.add(todo);
    await _save();
  }

  // Update a todo
  Future<void> updateTodo(TodoModel todo) async {
    await _init();
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      await _save();
    }
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    await _init();
    _todos.removeWhere((todo) => todo.id == id);
    await _save();
  }

  // Clear all todos
  Future<void> clearAllTodos() async {
    await _init();
    _todos.clear();
    await _save();
  }

  // Search todos
  Future<List<TodoModel>> searchTodos(String query) async {
    await _init();
    final lowercaseQuery = query.toLowerCase();
    return _todos.where((todo) {
      return todo.title.toLowerCase().contains(lowercaseQuery) ||
          todo.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
