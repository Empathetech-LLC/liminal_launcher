/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/services.dart';

/// '---'
const String nullAppLabel = '---';

/// ';'
const String idSplit = ':';

/// Helpful for creating [AppInfo] lists
/// [nullAppLabel], '', false
final AppInfo nullApp = AppInfo(
  label: nullAppLabel,
  package: '', // If you change this, match launchApp
  removable: false,
);

class AppInfo {
  final String _label;
  String name;
  final String _package;
  String id;
  final Uint8List? icon;
  final bool removable;

  /// [Object] to store app information
  /// Label, package, and icon
  /// [AppInfo]s with == packages are ==
  AppInfo({
    required String label,
    required String package,
    this.icon,
    required this.removable,
  })  : _label = label,
        name = label,
        _package = package,
        id = package + idSplit + label;

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        label: map['label'] ?? nullAppLabel,
        package: map['package'] ?? '', // Ditto (above)
        icon: map['icon'],
        removable: map['removable'] ?? false,
      );

  String get package => _package;

  set rename(String newName) => name = newName;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is AppInfo && id == other.id;

  @override
  String toString() => '''<AppInfo> {
  label: $_label,
  name: $name,
  package: $_package
  id: $id,
  icon: ${icon == null ? 'null' : 'present'},
  removable: $removable,
}''';
}

const String _pattern = r"^[\w\s\-\.\&\(\)']+$";

String? validateRename(String? newName) {
  if (newName == null || newName.trim().isEmpty) return 'Cannot be empty';

  final RegExp validNameRegExp = RegExp(_pattern);
  if (!validNameRegExp.hasMatch(newName)) return 'Invalid; $_pattern';

  return null;
}
