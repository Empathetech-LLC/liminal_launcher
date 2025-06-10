/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';

class AppInfoProvider extends ChangeNotifier {
  final List<AppInfo> _apps;

  AppInfoProvider(List<AppInfo> apps) : _apps = apps;

  List<AppInfo> get apps => _apps;
}
