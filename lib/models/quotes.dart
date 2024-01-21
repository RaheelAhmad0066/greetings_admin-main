import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  final String id;
  final String text;
  final String event;
  final DateTime timestamp;
  Quote({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.event,
  });

  factory Quote.fromSnapshot(DocumentSnapshot snapshot) {
    return Quote(
      id: snapshot.id,
      text: snapshot['quoteText'],
      timestamp: snapshot['createdAt'].toDate(),
      event: snapshot['event'],
    );
  }
}
