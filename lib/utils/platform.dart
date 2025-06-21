/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

const MethodChannel platform = MethodChannel('net.empathetech.liminal/query');

/// Get all installed apps
Future<List<AppInfo>> getApps() async {
  try {
    final List<dynamic>? appData = await platform.invokeMethod('getApps');

    if (appData == null) return <AppInfo>[];
    final List<AppInfo> apps = appData
        .map((dynamic app) => AppInfo.fromMap(Map<String, dynamic>.from(app)))
        .toList();
    apps.remove(self);
    return apps;
  } catch (e) {
    ezLog('Failed to get apps: $e');
    return <AppInfo>[];
  }
}

/// Open the app with [package] name
Future<void> launchApp(String package) async {
  try {
    await platform.invokeMethod('launchApp', <String, dynamic>{
      'packageName': package,
    });
  } catch (e) {
    ezLog('Failed to launch $package: $e');
  }
}

/// Open the settings for the app with [package] name
Future<void> openSettings(String package) async {
  try {
    await platform.invokeMethod('openSettings', <String, dynamic>{
      'packageName': package,
    });
  } catch (e) {
    ezLog('Failed to open the settings for $package: $e');
  }
}

Future<void> deleteApp(BuildContext context, AppInfo app) async {
  late final List<Widget> materialActions;
  late final List<Widget> cupertinoActions;

  (materialActions, cupertinoActions) = ezActionPairs(
    context: context,
    onConfirm: () => Navigator.of(context).pop(true),
    onDeny: () => Navigator.of(context).pop(false),
  );

  final bool confirmed = await showPlatformDialog(
    context: context,
    builder: (BuildContext context) {
      return EzAlertDialog(
        title: Text('Delete ${app.label}?'),
        materialActions: materialActions,
        cupertinoActions: cupertinoActions,
      );
    },
  );

  if (confirmed == false) return;

  try {
    await platform.invokeMethod('deleteApp', <String, dynamic>{
      'packageName': app.package,
    });
  } catch (e) {
    ezLog('Failed to delete ${app.package}: $e');
  }
}
