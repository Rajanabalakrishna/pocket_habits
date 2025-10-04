import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/habit.dart';
import '../theme/pallete.dart';
import '../services/backup_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final isDarkMode = themeNotifier.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                      ),
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          themeNotifier.toggleTheme();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Theme Mode'),
                      subtitle: Text(_getThemeModeText(themeNotifier.mode)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeModeDialog(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.file_upload,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Export Data'),
                      subtitle: const Text('Save your habits to a JSON file'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _exportData(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.file_download,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Import Data'),
                      subtitle: const Text('Restore habits from a JSON file'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _importData(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Preview Backup'),
                      subtitle: const Text('View backup file information'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _previewBackup(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('App Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.feedback,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Send Feedback'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Add feedback functionality
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.dark:
        return 'Always dark';
      case ThemeMode.system:
        return 'Follow system';
    }
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeNotifier.mode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeNotifier.mode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeNotifier.mode,
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportData(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Exporting data...'),
          ],
        ),
      ),
    );




    final success = await BackupService.exportData();


    // Close loading dialog
    Navigator.of(context).pop();

    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Success' : 'Error'),
        content: Text(success
            ? 'Data exported successfully to Downloads folder'
            : 'Failed to export data. Please check permissions and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _importData(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This will replace all existing habits. Continue?\n\n'
              'Note: Your current data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Importing data...'),
          ],
        ),
      ),
    );

    final success = await BackupService.importData();

    // Close loading dialog
    Navigator.of(context).pop();

    // Show result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Success' : 'Error'),
        content: Text(success
            ? 'Data imported successfully! Please restart the app to see all changes.'
            : 'Failed to import data. Please check the file format and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _previewBackup(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Reading backup file...'),
          ],
        ),
      ),
    );

    final backupInfo = await BackupService.getBackupInfo();

    // Close loading dialog
    Navigator.of(context).pop();

    if (backupInfo != null) {
      // Format the export date
      String formattedDate = 'Unknown';
      if (backupInfo['exportDate'] != null) {
        try {
          final date = DateTime.parse(backupInfo['exportDate']);
          formattedDate = '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        } catch (e) {
          formattedDate = backupInfo['exportDate'];
        }
      }

      // Show backup info dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Backup Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('App Name:', backupInfo['appName'] ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildInfoRow('Version:', backupInfo['version'] ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildInfoRow('Export Date:', formattedDate),
              const SizedBox(height: 8),
              _buildInfoRow('Habits Count:', '${backupInfo['habitsCount'] ?? 0}'),
              const SizedBox(height: 16),
              const Text(
                'This backup file appears to be valid and can be imported.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _importData(context);
              },
              child: const Text('Import This File'),
            ),
          ],
        ),
      );
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'Failed to read backup file. Please make sure you selected a valid Pocket Habits backup file.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
