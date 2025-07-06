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
  final String _package;
  String id;
  final Uint8List? icon;
  final bool removable;

  /// [Object] to store app information
  /// Label, package, and icon
  /// [AppInfo]s with == packages are ==
  AppInfo({
    required this.label,
    required String package,
    this.icon,
    required this.removable,
  })  : _package = package,
        id = '$package:$label';

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        label: map['label'] ?? nullAppLabel,
        package: map['package'] ?? '',
        icon: map['icon'],
        removable: map['removable'] ?? false,
      );

  set rename(String newLabel) {
    label = newLabel;
    id = '$_package:$label';
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is AppInfo && id == other.id;

  @override
  String toString() => '''<AppInfo> {
  label: $label,
  package: $_package
  id: $id,
  icon: ${icon == null ? 'null' : 'present'},
  removable: $removable,
}''';
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
