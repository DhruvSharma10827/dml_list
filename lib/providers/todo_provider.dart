import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class TodoProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<TodoModel> _todos = [];
  List<TodoModel> _filteredTodos = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  AppColorTheme _colorTheme = AppColorTheme.blue;

  // Color theme is stored in memory (persisted via theme callback)
  static AppColorTheme _savedColorTheme = AppColorTheme.blue;
  static bool _savedNotificationsEnabled = true;

  // Getters
  List<TodoModel> get todos => _filteredTodos;
  List<TodoModel> get allTodos => _todos;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get notificationsEnabled => _notificationsEnabled;
  AppColorTheme get colorTheme => _colorTheme;

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _notificationService.initialize();
    await _loadSettings();
    await loadTodos();

    _isLoading = false;
    notifyListeners();
  }

  // Load settings from static memory
  Future<void> _loadSettings() async {
    _notificationsEnabled = _savedNotificationsEnabled;
    _colorTheme = _savedColorTheme;
  }

  // Load all todos
  Future<void> loadTodos() async {
    _todos = await _databaseService.getAllTodos();
    _applyFilter();
  }

  // Search todos
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  // Apply search filter
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTodos = List.from(_todos);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredTodos = _todos.where((todo) {
        return todo.title.toLowerCase().contains(query) ||
            todo.description.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  // Add a new todo
  Future<void> addTodo({
    required String title,
    String description = '',
    List<String> tags = const [],
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final todo = TodoModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      tags: tags,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );

    await _databaseService.insertTodo(todo);
    await loadTodos();
  }

  // Update a todo
  Future<void> updateTodo(TodoModel todo) async {
    final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
    await _databaseService.updateTodo(updatedTodo);
    await loadTodos();
  }

  // Toggle todo completion
  Future<void> toggleComplete(TodoModel todo) async {
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _databaseService.updateTodo(updatedTodo);
    await loadTodos();
  }

  // Delete a todo
  Future<void> deleteTodo(String id) async {
    await _databaseService.deleteTodo(id);
    await loadTodos();
  }

  // Clear all todos
  Future<void> clearAllTodos() async {
    await _databaseService.clearAllTodos();
    await loadTodos();
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    _savedNotificationsEnabled = _notificationsEnabled;
    notifyListeners();
  }

  // Set color theme
  Future<void> setColorTheme(AppColorTheme theme) async {
    _colorTheme = theme;
    _savedColorTheme = theme;
    notifyListeners();
  }
}
