/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppInfoProvider extends ChangeNotifier {
  // Construct //

  // App info
  final List<AppInfo> _apps;
  final Map<String, AppInfo> _appMap;

  // Listeners
  static const EventChannel _appEventChannel =
      EventChannel('net.empathetech.liminal/app_events');
  StreamSubscription<dynamic>? _appEventSubscription;

  // Renamed
  final Set<String> _renamedPS = Set<String>.from(
      EzConfig.get(renamedAppsKey) ?? EzConfig.getDefault(renamedAppsKey));

  // Home list
  final Set<String> _homePS = Set<String>.from(
      EzConfig.get(homePackagesKey) ?? EzConfig.getDefault(homePackagesKey));
  final List<String> _homePL =
      EzConfig.get(homePackagesKey) ?? EzConfig.getDefault(homePackagesKey);

  // Hidden list
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
    // Gather renamed apps
    if (_renamedPS.isNotEmpty) {
      for (final String package in _renamedPS) {
        final List<String> parts = package.split(':');
        if (parts.length == 2) {
          final String package = parts[0];
          final AppInfo? app = _appMap[package];
          if (app != null) {
            app.rename = parts[1];
          }
        }
      }
    }

    // Sort the apps based on the user's preferences
    sort(
      AppListSortConfig.fromValue(
        EzConfig.get(appListSortKey) ?? EzConfig.getDefault(appListSortKey),
      ),
      EzConfig.get(appListOrderKey) ?? EzConfig.getDefault(appListOrderKey),
    );

    // Listen for events
    _listenToAppEvents();
  }

  // Get //

  List<AppInfo> get apps => _apps;

  List<String> get homePL => _homePL;
  Set<String> get homePS => _homePS;

  List<String> get hiddenPL => _hiddenPL;
  Set<String> get hiddenPS => _hiddenPS;

  List<AppInfo> get appList =>
      _apps.where((AppInfo app) => !_hiddenPS.contains(app.package)).toList();

  AppInfo? getAppFromID(String package) => _appMap[package];

  void _listenToAppEvents() {
    _appEventSubscription =
        _appEventChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map<dynamic, dynamic>) {
        final String eventType = event['eventType'] as String;

        switch (eventType) {
          case 'installed':
            final Map<String, dynamic>? appInfoMap =
                event['appInfo'] as Map<String, dynamic>?;

            if (appInfoMap != null) _handleAppInstalled(appInfoMap);
            break;
          case 'uninstalled':
            final String packageName = event['packageName'] as String;

            _handleAppUninstalled(packageName);
            break;
        }
      }
    }, onError: (dynamic error) {
      ezLog('Error listening to app events: $error');
    });
  }

  // Post //

  Future<void> addHomeFolder() async {
    // Include ':empty' so a ':' split will still return a list
    _homePL.add('Folder:empty');

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();
  }

  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.package] = installed;

    sort(
      AppListSortConfig.fromValue(
        EzConfig.get(appListSortKey) ?? EzConfig.getDefault(appListSortKey),
      ),
      EzConfig.get(appListOrderKey) ?? EzConfig.getDefault(appListOrderKey),
    );

    if (EzConfig.get(autoAddToHomeKey) == true &&
        !_homePS.contains(installed.package)) {
      _homePL.add(installed.package);
      _homePS.add(installed.package);
      await EzConfig.setStringList(homePackagesKey, _homePL);
    }

    notifyListeners();
  }

  Future<void> _handleAppUninstalled(String packageName) =>
      removeDeleted(packageName);

  // Put //

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

  /// Does not handle dupes; please handle before
  Future<bool> addToFolder({
    required String fullName,
    required String package,
  }) async {
    final int index = _homePL.indexOf(fullName);
    if (index == -1) return false;

    final List<String> parts = fullName.split(':');
    if (parts.length == 2 && parts[1] == 'empty') {
      _homePL[index] = parts[0];
    }

    _homePL[index] = '${_homePL[index]}:$package';
    _homePS.contains(package) ? _homePL.remove(package) : _homePS.add(package);

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();

    return true;
  }

  Future<bool> removeFromFolder({
    required String fullName,
    required String package,
  }) async {
    final int index = _homePL.indexOf(fullName);
    if (index == -1) return false;

    String newFullName = fullName.replaceFirst(':$package', '');
    if (!homePL.contains(':')) {
      // Include ':empty' so a ':' split will still return a list
      newFullName += ':empty';
    }
    _homePL[index] = newFullName;
    _homePL.add(package);

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();

    return true;
  }

  // Patch //

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

  Future<void> reorderHomeApp(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    if (newIndex > oldIndex) newIndex -= 1;

    final String package = _homePL.removeAt(oldIndex);
    _homePL.insert(newIndex, package);

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();
  }

  Future<bool> renameApp(String package, String newLabel) async {
    final AppInfo? app = _appMap[package];
    if (app == null || app.label == newLabel) return false;

    app.rename = newLabel;

    _renamedPS.removeWhere((String entry) => entry.startsWith('$package:'));
    _renamedPS.add('$package:$newLabel');

    await EzConfig.setStringList(renamedAppsKey, _renamedPS.toList());
    notifyListeners();

    return true;
  }

  Future<bool> renameFolder(String fullName, String newLabel) async {
    final int index = _homePL.indexOf(fullName);
    if (index == -1) return false;

    final List<String> parts = fullName.split(':');
    if (parts[0] == newLabel) return false;

    final String newFullName = '$newLabel:${parts.sublist(1).join(':')}';
    _homePL[index] = newFullName;

    await EzConfig.setStringList(homePackagesKey, _homePL);
    notifyListeners();

    return true;
  }

  // Delete //

  Future<void> removeDeleted(String package) async {
    await showApp(package);
    await removeHomeApp(package);
    _apps.remove(_appMap[package]);
    _appMap.remove(package);

    notifyListeners();
  }

  Future<void> deleteFolder(String fullName) async {
    final List<String> packages = fullName.split(':').sublist(1);
    for (final String package in packages) {
      _homePS.remove(package);
    }

    _homePL.remove(fullName);
    await EzConfig.setStringList(homePackagesKey, _homePL);

    notifyListeners();
  }

  @override
  void dispose() {
    _appEventSubscription?.cancel();
    super.dispose();
  }
}
