class JournalEntry {
  final DateTime date;
  final int mood;
  final String note;

  JournalEntry({required this.date, required this.mood, required this.note});

  static JournalEntry fromJson(Map<String, dynamic> j) => JournalEntry(
      date: DateTime.parse(j['date'] as String),
      mood: j['mood'] as int,
      note: j['note'] as String
  );
}