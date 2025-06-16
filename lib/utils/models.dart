/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

class AppInfo {
  final String label;
  final String package;
  final Uint8List? icon;

  AppInfo({required this.label, required this.package, this.icon});

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        label: map['label'],
        package: map['package'],
        icon: map['icon'],
      );
}
