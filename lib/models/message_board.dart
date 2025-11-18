import 'package:flutter/material.dart';

class MessageBoard {
  final String id;
  final String name;
  final IconData icon;
  final int order;

  const MessageBoard({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
  });
}