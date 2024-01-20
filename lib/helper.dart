import 'dart:math';

import 'package:flutter/material.dart';

const userColors = [
  Colors.redAccent,
  Colors.blue,
  Colors.pink,
  Colors.indigo,
  Colors.green,
  Colors.deepPurple,
  Colors.orange,
  Colors.teal,
  Colors.brown
];

extension ListExt<T> on List<T> {
  T random() {
    final i = Random.secure().nextInt(length);
    return this[i];
  }
}