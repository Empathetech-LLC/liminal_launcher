/* smoke_signal
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:installed_apps/index.dart';

class AppInfoProvider extends ChangeNotifier {
  List<AppInfo> _apps;

  AppInfoProvider(List<AppInfo> apps) : _apps = apps;

  List<AppInfo> get apps => _apps;
}
