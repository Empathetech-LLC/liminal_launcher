/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

const MethodChannel platform = MethodChannel('net.empathetech.liminal/query');

/// Get installed apps
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

Future<void> launchApp(String package) async {
  try {
    await platform.invokeMethod('launchApp', <String, dynamic>{
      'packageName': package,
    });
  } catch (e) {
    ezLog('Failed to launch app: $e');
  }
}
