/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

// Apps //

class AppInfoProvider extends ChangeNotifier {
  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;

  final Set<String> _homePS = Set<String>.from(
      EzConfig.get(homePackagesKey) ?? EzConfig.getDefault(homePackagesKey));
  final List<String> _homePL =
      EzConfig.get(homePackagesKey) ?? EzConfig.getDefault(homePackagesKey);

  final Set<String> _hiddenPS = Set<String>.from(
      EzConfig.get(hiddenPackagesKey) ??
          EzConfig.getDefault(hiddenPackagesKey));
  final List<String> _hiddenPL =
      EzConfig.get(hiddenPackagesKey) ?? EzConfig.getDefault(hiddenPackagesKey);

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{
          for (AppInfo app in apps) app.package: app,
        } {
    sort(
      AppListSortConfig.fromValue(
        EzConfig.get(appListSortKey) ?? EzConfig.getDefault(appListSortKey),
      ),
      EzConfig.get(appListOrderKey) ?? EzConfig.getDefault(appListOrderKey),
    );
  }

  List<AppInfo> get apps => _apps;

  List<String> get homePL => _homePL;
  Set<String> get homePS => _homePS;

  List<String> get hiddenPL => _hiddenPL;
  Set<String> get hiddenPS => _hiddenPS;

  List<AppInfo> get appList =>
      _apps.where((AppInfo app) => !_hiddenPS.contains(app.package)).toList();

  AppInfo? getAppFromID(String package) => _appMap[package];

  void sort(ListSort sort, bool asc) {
    switch (sort) {
      case ListSort.name:
        _apps.sort((AppInfo a, AppInfo b) =>
            (asc) ? a.label.compareTo(b.label) : b.label.compareTo(a.label));

      case ListSort.publisher:
        _apps.sort((AppInfo a, AppInfo b) => (asc)
            ? a.package.compareTo(b.package)
            : b.package.compareTo(a.package));
    }
    notifyListeners();
  }

  Future<void> addHomeApp(String package) async {
    if (_homePS.contains(package)) return;

    _homePL.add(package);
    _homePS.add(package);

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();
  }

  Future<bool> removeHomeApp(String package) async {
    if (!_homePS.contains(package)) return false;

    _homePL.remove(package);
    _homePS.remove(package);

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();

    return true;
  }

  Future<void> removeDeleted(String package) async {
    await showApp(package);
    await removeHomeApp(package);
    _apps.remove(_appMap[package]);
    _appMap.remove(package);

    notifyListeners();
  }

  Future<void> reorderHomeApp(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    if (newIndex > oldIndex) newIndex -= 1;

    final String package = _homePL.removeAt(oldIndex);
    _homePL.insert(newIndex, package);

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();
  }

  Future<void> hideApp(String package) async {
    if (_hiddenPS.contains(package)) return;

    _hiddenPL.add(package);
    _hiddenPS.add(package);

    await EzConfig.setStringList(hiddenPackagesKey, _hiddenPL);

    final bool notified = await removeHomeApp(package);
    if (!notified) notifyListeners();
  }

  Future<void> showApp(String package) async {
    if (!_hiddenPS.contains(package)) return;

    _hiddenPL.remove(package);
    _hiddenPS.remove(package);

    await EzConfig.setStringList(hiddenPackagesKey, _hiddenPL);
    notifyListeners();
  }
}

// Wallpaper //

class WallpaperProvider extends ChangeNotifier {
  dynamic _wallpaper;
  bool _useOS;

  WallpaperProvider()
      : _useOS = (EzConfig.get(useOSWallpaperKey) ??
            EzConfig.getDefault(useOSWallpaperKey)) {
    _initWallpaper();
  }

  Future<void> _initWallpaper() async {
    if (_useOS) {
      _wallpaper = await getWallpaper();
    } else {
      _wallpaper =
          '${EzConfig.get(darkBackgroundImageKey)}:${EzConfig.get(lightBackgroundImageKey)}';
    }
    notifyListeners();
  }

  bool get useOS => _useOS;
  dynamic get wallpaper => _wallpaper;

  Future<void> setUseOS(bool choice) async {
    if (choice == _useOS) return;

    _useOS = choice;
    await EzConfig.setBool(useOSWallpaperKey, choice);
    notifyListeners();
  }
}
