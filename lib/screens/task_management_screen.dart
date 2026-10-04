
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/time_entry_provider.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    String? selectedProjectId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final provider = context.read<TimeEntryProvider>();

          return AlertDialog(
            title: const Text('Add Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    hintText: 'Enter task name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Select Project',
                    border: OutlineInputBorder(),
                  ),
                  items: provider.projects.map((project) {
                    return DropdownMenuItem<String>(
                      value: project.id,
                      child: Text(project.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedProjectId = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isEmpty || selectedProjectId == null) return;

                  final task = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    projectId: selectedProjectId!,
                  );
                  provider.addTask(task);
                  Navigator.pop(dialogContext);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
        centerTitle: true,
      ),

      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              String projectName = 'Unknown Project';

              for (final project in provider.projects) {
                if (project.id == task.projectId) {
                  projectName = project.name;
                  break;
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 10),

                child: ListTile(
                  leading: const Icon(
                    Icons.task_alt,
                    color: Colors.blue,
                  ),

                  title: Text(task.name),

                  subtitle: Text(projectName),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),

                    onPressed: () {
                      provider.deleteTask(task.id);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Task deleted successfully',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}