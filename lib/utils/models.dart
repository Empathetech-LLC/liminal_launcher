/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

const String nullAppLabel = '---';

/// Helpful for creating [AppInfo] lists
/// [nullAppLabel], '', false
final AppInfo nullApp = AppInfo(
  label: nullAppLabel,
  package: '', // If you update this, update launchApp
  removable: false,
);

class AppInfo {
  String label;
  final String package;
  String keyLabel;
  final Uint8List? icon;
  final bool removable;

  /// [Object] to store app information
  /// Label, package, and icon
  /// [AppInfo]s with == packages are ==
  AppInfo({
    required this.label,
    required this.package,
    this.icon,
    required this.removable,
  }) : keyLabel = '$label:$package';

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        label: map['label'] ?? nullAppLabel,
        package: map['package'] ?? '',
        icon: map['icon'],
        removable: map['removable'] ?? false,
      );

  set rename(String newLabel) {
    label = newLabel;
    keyLabel = '$newLabel:$package';
  }

  @override
  bool operator ==(Object other) =>
      other is AppInfo && package == other.package;

  @override
  int get hashCode => package.hashCode;

  @override
  String toString() => 'app_label: $label, app_package: $package';
}

const String _pattern = r"^[\w\s\-\.\&\(\)']+$";

String? validateAppName(String? toCheck) {
  if (toCheck == null || toCheck.trim().isEmpty) {
    return 'App name cannot be empty';
  }

  final RegExp validNameRegExp = RegExp(_pattern);
  if (!validNameRegExp.hasMatch(toCheck)) {
    return 'Invalid app name; $_pattern';
  }
  return null;
}
