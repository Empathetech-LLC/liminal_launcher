/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppInfoProvider extends ChangeNotifier {
  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;
  final Set<String> _hiddenPackages;

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{
          for (AppInfo app in apps) app.package: app,
        },
        _hiddenPackages = Set<String>.from(EzConfig.get(hiddenPackagesKey) ??
            EzConfig.getDefault(hiddenPackagesKey)) {
    sort(EzConfig.get(appListSortKey) ?? EzConfig.getDefault(appListSortKey),
        EzConfig.get(appListOrderKey) ?? EzConfig.getDefault(appListOrderKey));
  }

  List<AppInfo> get apps => _apps;

  void sort(AppListSort sort, AppListOrder order) {
    switch (sort) {
      case AppListSort.name:
        _apps.sort((AppInfo a, AppInfo b) => (order == AppListOrder.asc)
            ? a.label.compareTo(b.label)
            : b.label.compareTo(a.label));

      case AppListSort.publisher:
        _apps.sort((AppInfo a, AppInfo b) => (order == AppListOrder.asc)
            ? a.package.compareTo(b.package)
            : b.package.compareTo(a.package));
    }
    notifyListeners();
  }

  AppInfo? getAppFromID(String package) => _appMap[package];

  bool isHidden(String package) => _hiddenPackages.contains(package);
}
