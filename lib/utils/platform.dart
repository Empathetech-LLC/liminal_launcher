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
    final List<dynamic>? apps = await platform.invokeMethod('getApps');

    if (apps == null) return <AppInfo>[];
    return apps
        .map((dynamic app) => AppInfo.fromMap(Map<String, dynamic>.from(app)))
        .toList();
  } catch (e) {
    ezLog('Failed to get apps: $e');
    return <AppInfo>[];
  }
}
