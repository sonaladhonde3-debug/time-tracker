class TimeEntry {
  final String id;
  final String project;
  final String task;
  final String notes;
  final DateTime date;
  final int durationMinutes;

  TimeEntry({
    required this.id,
    required this.project,
    required this.task,
    required this.notes,
    required this.date,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project': project,
      'task': task,
      'notes': notes,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      project: json['project'],
      task: json['task'],
      notes: json['notes'] ?? '',
      date: DateTime.parse(json['date']),
      durationMinutes: json['durationMinutes'],
    );
  }
}