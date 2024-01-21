import 'package:flutter/material.dart';
import 'package:greetings_admin/models/events.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Religion {
  final String name;
  final String id;
  final int count;
  final List<Event> events;
  final String imageUrl;

  Religion({
    required this.id,
    required this.name,
    required this.count,
    required this.events,
    required this.imageUrl,
  });
}
