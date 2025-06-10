/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

class AppInfo {
  final String name;
  final String label;
  final Uint8List? icon;

  AppInfo({required this.name, required this.label, this.icon});

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        name: map['name'],
        label: map['label'],
        icon: map['icon'],
      );
}
