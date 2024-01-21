import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greetings_admin/models/events.dart';
import 'package:greetings_admin/models/religions.dart';

class ReligionEventsProvider with ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Event> _events = [];
  List<Religion> _religions = [];
  List<Religion> get religions => _religions;

  // Initialize the provider by fetching religions and events
  Future<void> initialize() async {
    await fetchReligions();
  }

  Future<void> fetchReligions() async {
    try {
      _religions.clear();
      QuerySnapshot religionsSnapshot =
          await FirebaseFirestore.instance.collection('religions').get();

      QuerySnapshot eventSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      _events = eventSnapshot.docs.map((doc) {
        Map<String, dynamic> eventData = doc.data() as Map<String, dynamic>;
        return Event(
          id: eventData['id'],
          name: eventData['eventName'],
          userCount: eventData['userCount'],
          greetingCount: eventData['greetingCount'],
          religion: eventData['religion'],
          imageUrl: eventData['imageUrl'],
        );
      }).toList();
      //Fetch all the religions and store its relevent events
      _religions = religionsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<Event> eventsInReligion = _events
            .where((event) => event.religion == doc['religionName'])
            .toList();

        return Religion(
          id: doc.id,
          name: data['religionName'] ?? "",
          count: data['count'] ?? 0,
          events: eventsInReligion,
          imageUrl: data['imageUrl'],
        );
      }).toList();

      // Notify listeners that the data has been loaded
      notifyListeners();
    } catch (e) {
      print("Error fetching religions: $e");
    }
  }

  Future<void> createReligion(Religion religion) async {
    try {
      final data = await _firestore.collection('religions').add({});
      data.set({
        'id': data.id,
        'religionName': religion.name,
        'count': religion.count,
        'imageUrl': religion.imageUrl,
      });
      // Notify listeners that the data has been loaded
      fetchReligions();
    } catch (e) {
      print("Error fetching religions: $e");
    }
  }

  Future<void> addEvent(Religion religion, Event event) async {
    try {
      final data = await _firestore.collection('events').add({});
      _firestore.collection('events').doc(data.id).update({
        'id': data.id,
        'eventName': event.name,
        'userCount': event.userCount,
        'greetingCount': event.greetingCount,
        'religion': religion.name,
        'imageUrl': event.imageUrl,
      });
      fetchReligions();
    } catch (e) {
      print(e);
    }
  }
}
