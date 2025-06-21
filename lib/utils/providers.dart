/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';

class AppInfoProvider extends ChangeNotifier {
  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{
          for (AppInfo app in apps) app.package: app,
        };

  List<AppInfo> get apps => _apps;

  AppInfo? getAppFromID(String package) => _appMap[package];
}
