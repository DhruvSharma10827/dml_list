import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_card.dart';
import '../widgets/confirmation_dialog.dart';
import 'todo_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToForm([TodoModel? todo]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TodoFormScreen(todo: todo),
      ),
    );
  }

  Future<void> _deleteTodo(TodoModel todo) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Todo',
      message: 'Are you sure you want to delete "${todo.title}"?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<TodoProvider>().deleteTodo(todo.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<TodoProvider>().search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search todos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<TodoProvider>().search('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Todo List
            Expanded(
              child: Consumer<TodoProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.todos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isEmpty
                                ? Icons.checklist_rounded
                                : Icons.search_off,
                            size: 80,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No todos yet'
                                : 'No todos found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_searchController.text.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first todo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: provider.todos.length,
                    itemBuilder: (context, index) {
                      final todo = provider.todos[index];
                      return TodoCard(
                        todo: todo,
                        onTap: () => _navigateToForm(todo),
                        onDelete: () => _deleteTodo(todo),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
