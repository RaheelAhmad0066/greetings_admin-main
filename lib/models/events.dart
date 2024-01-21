class Event {
  final String id;
  final String name;
  final int userCount;
  final int greetingCount;
  final String religion;
  final String imageUrl;
  Event({
    required this.id,
    required this.name,
    required this.userCount,
    required this.greetingCount,
    required this.religion,
    required this.imageUrl,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['eventName'],
      userCount: map['userCount'],
      greetingCount: map['greetingCount'],
      religion: map['religion'],
      imageUrl: map['imageUrl'],
    );
  }
}
