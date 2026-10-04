import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/project.dart';
import '../models/task.dart';
import '../models/time_entry.dart';

class TimeEntryProvider extends ChangeNotifier {
  List<TimeEntry> _timeEntries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  List<TimeEntry> get timeEntries => _timeEntries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  static const _entriesKey = 'time_entries';
  static const _projectsKey = 'projects';
  static const _tasksKey = 'tasks';

  TimeEntryProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final entriesJson = prefs.getString(_entriesKey);
    if (entriesJson != null) {
      final decoded = jsonDecode(entriesJson) as List<dynamic>;
      _timeEntries = decoded.map((e) => TimeEntry.fromJson(e)).toList();
    }

    final projectsJson = prefs.getString(_projectsKey);
    if (projectsJson != null) {
      final decoded = jsonDecode(projectsJson) as List<dynamic>;
      _projects = decoded.map((e) => Project.fromJson(e)).toList();
    }

    final tasksJson = prefs.getString(_tasksKey);
    if (tasksJson != null) {
      final decoded = jsonDecode(tasksJson) as List<dynamic>;
      _tasks = decoded.map((e) => Task.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_entriesKey, jsonEncode(_timeEntries.map((e) => e.toJson()).toList()));
    await prefs.setString(_projectsKey, jsonEncode(_projects.map((e) => e.toJson()).toList()));
    await prefs.setString(_tasksKey, jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  Future<void> addTimeEntry(TimeEntry entry) async {
    _timeEntries.add(entry);
    await _save();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _timeEntries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _save();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    // also wipe tasks that belonged to this project
    _tasks.removeWhere((t) => t.projectId == id);
    await _save();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _save();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _save();
    notifyListeners();
  }

  List<Task> getTasksForProject(String projectId) {
    return _tasks.where((t) => t.projectId == projectId).toList();
  }
}