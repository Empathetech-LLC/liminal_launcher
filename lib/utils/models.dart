/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

/// Helpful for creating [AppInfo] lists
/// Label 'None' and package ''
const AppInfo nullApp = AppInfo(label: '---', package: '');

class AppInfo {
  final String label;
  final String package;
  final Uint8List? icon;

  /// [Object] to store app information
  /// Label, package, and icon
  /// [AppInfo]s with == packages are ==
  const AppInfo({required this.label, required this.package, this.icon});

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        label: map['label'],
        package: map['package'],
        icon: map['icon'],
      );

  @override
  bool operator ==(Object other) =>
      other is AppInfo && package == other.package;

  @override
  int get hashCode => package.hashCode;

  @override
  String toString() => 'app_label: $label, app_package: $package';
}
