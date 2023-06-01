import 'dart:convert';

import 'package:flutter/foundation.dart';

class Transaction {
  final String title;
  final DateTime date;

  Transaction({
    @required this.title,
    @required this.date,
  });

  String toJson() {
    return json.encode({'name': title, 'date': date.toIso8601String()});
  }

  // convert JSON string to CustomData object
  static Transaction fromJson(String jsonString) {
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Transaction(
      title: jsonMap['name'],
      date: DateTime.parse(jsonMap['date']),
    );
  }
}
