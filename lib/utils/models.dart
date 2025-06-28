/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

const String nullAppLabel = '---';

/// Helpful for creating [AppInfo] lists
/// [nullAppLabel], '', false
const AppInfo nullApp = AppInfo(
  label: nullAppLabel,
  package: '', // If you update this, update launchApp
  removable: false,
);

class AppInfo {
  final String label;
  final String package;
  final Uint8List? icon;
  final bool removable;

  /// [Object] to store app information
  /// Label, package, and icon
  /// [AppInfo]s with == packages are ==
  const AppInfo({
    required this.label,
    required this.package,
    this.icon,
    required this.removable,
  });

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        label: map['label'] ?? nullAppLabel,
        package: map['package'] ?? '',
        icon: map['icon'],
        removable: map['removable'] ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is AppInfo && package == other.package;

  @override
  int get hashCode => package.hashCode;

  @override
  String toString() => 'app_label: $label, app_package: $package';
}
