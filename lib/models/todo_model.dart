import 'package:intl/intl.dart';

class TodoModel {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.tags = const [],
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags.join(','),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map from SQLite
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      tags: (map['tags'] as String? ?? '')
          .split(',')
          .where((tag) => tag.isNotEmpty)
          .toList(),
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'] as String)
          : null,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Copy with new values
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format due date for display
  String get formattedDueDate {
    if (dueDate == null) return '';
    return DateFormat('MMM d, yyyy').format(dueDate!);
  }

  // Check if due date is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, isCompleted: $isCompleted)';
  }
}
