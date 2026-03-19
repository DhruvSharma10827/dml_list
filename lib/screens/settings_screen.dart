import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirmation_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearData(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: '⚠️ Clear All Data',
      message: 'This will permanently delete all your todos. This action cannot be undone.',
      confirmText: 'Clear All',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await context.read<TodoProvider>().clearAllTodos();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    // Show share info dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share DML List with your friends!'),
            SizedBox(height: 12),
            SelectableText(
              'https://github.com/dmllabs/dml_list',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final provider = context.read<TodoProvider>();
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Theme Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AppColorTheme.values.length,
                itemBuilder: (context, index) {
                  final theme = AppColorTheme.values[index];
                  final isSelected = provider.colorTheme == theme;
                  
                  return GestureDetector(
                    onTap: () {
                      provider.setColorTheme(theme);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Colors.white,
                                width: 3,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: theme.color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('DML List'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('App Name', 'DML List'),
              const SizedBox(height: 8),
              _buildInfoRow('Developed by', 'DML Labs'),
              const SizedBox(height: 8),
              _buildInfoRow('Version', '0.1.0'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'A minimal and premium todo list application.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Data Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'DATA',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all todos permanently'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _clearData(context),
          ),

          const Divider(height: 32),

          // Notifications Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'NOTIFICATIONS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: provider.notificationsEnabled
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    provider.notificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: provider.notificationsEnabled
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
                title: const Text('Notifications'),
                subtitle: Text(
                  provider.notificationsEnabled ? 'Enabled' : 'Disabled',
                ),
                trailing: Switch(
                  value: provider.notificationsEnabled,
                  onChanged: (_) => provider.toggleNotifications(),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Appearance Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'APPEARANCE',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: provider.colorTheme.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: provider.colorTheme.color,
                  ),
                ),
                title: const Text('Theme Color'),
                subtitle: Text(provider.colorTheme.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: provider.colorTheme.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _showColorPicker(context),
              );
            },
          ),

          const Divider(height: 32),

          // About Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.share, color: Colors.blue),
            ),
            title: const Text('Share App'),
            subtitle: const Text('Share with friends'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _shareApp(context),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline, color: Colors.purple),
            ),
            title: const Text('App Info'),
            subtitle: const Text('Version 0.1.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAppInfo(context),
          ),
        ],
      ),
    );
  }
}
