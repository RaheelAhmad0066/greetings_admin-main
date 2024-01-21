import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greetings_admin/models/events.dart';
import 'package:greetings_admin/models/quotes.dart';

class QuotesProvider with ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final quoteCollection = FirebaseFirestore.instance.collection('Quotes');

  List<Quote> _quotes = [];
  int _quoteCount = 0;

  List<Quote> get quotes => _quotes;
  int get quoteCount => _quoteCount;

  // Initialize the provider by fetching quotes

  QuerySnapshot? quotesSnapshot;
  Future<void> fetchQuotes(Event event) async {
    try {
      // quotesSnapshot = null;
      _quotes.clear();
      quotesSnapshot = await quoteCollection
          .where('event', isEqualTo: event.name)
          .limit(10)
          .get();

      _quotes =
          quotesSnapshot!.docs.map((doc) => Quote.fromSnapshot(doc)).toList();

      DocumentSnapshot data =
          await firestore.collection('events').doc(event.id).get();
      _quoteCount = data['greetingCount'];

      notifyListeners();

      // Notify listeners that the data has been loaded
    } catch (e) {
      print("Error fetching quotes: $e");
    }
  }

  // Fetch more quotes for pagination
  // Future<void> fetchMoreQuotes(String eventName) async {
  //   try {
  //     QuerySnapshot additionalQuotesSnapshot = await quoteCollection
  //         .where('eventID', isEqualTo: eventName)
  //         .startAfterDocument(quotesSnapshot!.docs.last)
  //         .limit(10)
  //         .get();

  //     List<Quote> additionalQuotes = additionalQuotesSnapshot.docs
  //         .map((doc) => Quote.fromSnapshot(doc))
  //         .toList();

  //     _quotes.addAll(additionalQuotes);

  //     // Notify listeners that additional quotes have been loaded
  //     notifyListeners();
  //   } catch (e) {
  //     print("Error fetching more quotes: $e");
  //   }
  // }

  // Add a new quote
  Future<void> addQuote(Quote quote, Event event) async {
    try {
      final data = await quoteCollection.add({});
      data.set({
        'id': data.id,
        'quoteText': quote.text,
        'event': quote.event,
        'createdAt': DateTime.now(),
      });

      firestore.collection('events').doc(event.id).update({
        'greetingCount': FieldValue.increment(1),
      });

      _quoteCount++;
      // Fetch the latest quotes after adding a new one
      await fetchQuotes(event);
    } catch (e) {
      print("Error adding quote: $e");
    }
  }

  // Update an existing quote
  Future<void> updateQuote(String quoteId, String newText, Event event) async {
    try {
      await quoteCollection.doc(quoteId).update({'quoteText': newText});

      // Fetch the updated quotes
      await fetchQuotes(event);
    } catch (e) {
      print("Error updating quote: $e");
    }
  }

  // Delete a quote
  Future<void> deleteQuote(String quoteId, Event event) async {
    try {
      await FirebaseFirestore.instance
          .collection('quotes')
          .doc(quoteId)
          .delete();

      _quoteCount--;
      // Fetch the updated quotes after deletion
      await fetchQuotes(event);
    } catch (e) {
      print("Error deleting quote: $e");
    }
  }
}
