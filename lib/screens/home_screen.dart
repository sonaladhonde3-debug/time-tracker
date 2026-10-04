
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_management_screen.dart';
import 'task_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time Tracker'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: 'All Entries'),
              Tab(icon: Icon(Icons.folder_copy), text: 'Grouped by Projects'),
              Tab(icon: Icon(Icons.folder), text: 'Projects'),
              Tab(icon: Icon(Icons.task), text: 'Tasks'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'projects') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProjectManagementScreen()),
                  );
                } else if (value == 'tasks') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TaskManagementScreen()),
                  );
                } else if (value == 'clear') {
                  _showClearConfirmation(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'projects',
                  child: Row(
                    children: [
                      Icon(Icons.folder),
                      SizedBox(width: 12),
                      Text('Manage Projects'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'tasks',
                  child: Row(
                    children: [
                      Icon(Icons.task),
                      SizedBox(width: 12),
                      Text('Manage Tasks'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever),
                      SizedBox(width: 12),
                      Text('Clear all entries'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            EntriesTab(),
            GroupedEntriesTab(),
            ProjectManagementScreen(),
            TaskManagementScreen(),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all entries?'),
        content: const Text('This will permanently delete all time entries.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<TimeEntryProvider>();
              for (final entry in List.of(provider.timeEntries)) {
                await provider.deleteEntry(entry.id);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class EntriesTab extends StatelessWidget {
  const EntriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          final entries = provider.timeEntries;

          if (provider.timeEntries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 80,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No time entries yet!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap the + button to add your first entry.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final Map<String, List<TimeEntry>> groupedEntries = {};

          for (final entry in entries) {
            groupedEntries.putIfAbsent(entry.project, () => []);
            groupedEntries[entry.project]!.add(entry);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: groupedEntries.entries.map((group) {
              final projectName = group.key;
              final projectEntries = group.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...projectEntries.map((entry) {
                    final hours = entry.durationMinutes ~/ 60;
                    final minutes = entry.durationMinutes % 60;

                    final durationText = hours > 0
                        ? '${hours}h ${minutes}m'
                        : '${minutes}m';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.access_time),
                        ),
                        title: Text(
                          entry.task,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().format(entry.date),
                            ),
                            if (entry.notes.isNotEmpty)
                              Text('Notes: ${entry.notes}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer),
                                const SizedBox(height: 4),
                                Text(durationText),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              tooltip: 'Delete entry',
                              onPressed: () {
                                _showDeleteConfirmation(
                                  context,
                                  provider,
                                  entry,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTimeEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TimeEntryProvider provider,
    TimeEntry entry,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text('Delete "${entry.task}" from "${entry.project}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteEntry(entry.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class GroupedEntriesTab extends StatelessWidget {
  const GroupedEntriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (provider.timeEntries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 80, color: Colors.grey.shade500),
                  const SizedBox(height: 20),
                  const Text(
                    'No entries to group yet!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add time entries to see them grouped by project.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final Map<String, List<TimeEntry>> grouped = {};
        for (final entry in provider.timeEntries) {
          grouped.putIfAbsent(entry.project, () => []);
          grouped[entry.project]!.add(entry);
        }

        return ListView(
          padding: const EdgeInsets.all(12),
          children: grouped.entries.map((group) {
            final totalMinutes = group.value.fold(0, (sum, e) => sum + e.durationMinutes);
            final totalHours = totalMinutes ~/ 60;
            final totalMins = totalMinutes % 60;
            final totalText = totalHours > 0 ? '${totalHours}h ${totalMins}m' : '${totalMins}m';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        group.key,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total: $totalText',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ...group.value.map((entry) {
                  final h = entry.durationMinutes ~/ 60;
                  final m = entry.durationMinutes % 60;
                  final dur = h > 0 ? '${h}h ${m}m' : '${m}m';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.access_time, size: 18),
                      ),
                      title: Text(
                        entry.task,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat.yMMMd().format(entry.date)),
                          if (entry.notes.isNotEmpty)
                            Text(entry.notes, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: Text(
                        dur,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }),
                const Divider(height: 24),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}