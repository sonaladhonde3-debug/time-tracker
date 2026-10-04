import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/time_entry.dart';
import '../providers/time_entry_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _durationController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  String? selectedProjectId;
  String? selectedTaskId;

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedProjectId == null || selectedTaskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a project and task')),
      );
      return;
    }

    final provider = context.read<TimeEntryProvider>();

    final selectedProject = provider.projects.firstWhere(
      (project) => project.id == selectedProjectId,
    );

    final selectedTask = provider.tasks.firstWhere(
      (task) => task.id == selectedTaskId,
    );

    final entry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      project: selectedProject.name,
      task: selectedTask.name,
      notes: _notesController.text.trim(),
      date: selectedDate,
      durationMinutes: int.parse(_durationController.text.trim()),
    );

    await provider.addTimeEntry(entry);

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          final tasks = selectedProjectId == null
              ? []
              : provider.getTasksForProject(selectedProjectId!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedProjectId,
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select project'),
                    items: provider.projects.map((project) {
                      return DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: provider.projects.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              selectedProjectId = value;
                              selectedTaskId = null;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a project';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedTaskId,
                    decoration: const InputDecoration(
                      labelText: 'Task',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select task'),
                    items: tasks.map((task) {
                      return DropdownMenuItem<String>(
                        value: task.id,
                        child: Text(task.name),
                      );
                    }).toList(),
                    onChanged: tasks.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              selectedTaskId = value;
                            });
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a task';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat.yMMMd().format(selectedDate)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration in minutes',
                      hintText: 'Example: 60',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter duration';
                      }

                      final duration = int.tryParse(value.trim());

                      if (duration == null || duration <= 0) {
                        return 'Enter a valid duration';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Add notes about this work',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _saveEntry,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Entry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
