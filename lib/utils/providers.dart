/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// ','
const String folderSplit = ',';

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
  final Set<String> _renamedSet = Set<String>.from(
      EzConfig.get(renamedIDsKey) ?? EzConfig.getDefault(renamedIDsKey));

  // Home list
  final Set<String> _homeSet = Set<String>.from(
      EzConfig.get(homeIDsKey) ?? EzConfig.getDefault(homeIDsKey));
  final List<String> _homeList =
      EzConfig.get(homeIDsKey) ?? EzConfig.getDefault(homeIDsKey);

  // Hidden list
  final Set<String> _hiddenSet = Set<String>.from(
      EzConfig.get(hiddenIDsKey) ?? EzConfig.getDefault(hiddenIDsKey));
  final List<String> _hiddenList =
      EzConfig.get(hiddenIDsKey) ?? EzConfig.getDefault(hiddenIDsKey);

  AppInfoProvider(List<AppInfo> apps)
      : _apps = apps,
        _appMap = <String, AppInfo>{
          for (AppInfo app in apps) app.id: app,
        } {
    // Gather renamed apps
    if (_renamedSet.isNotEmpty) {
      for (final String csv in _renamedSet) {
        final List<String> parts = csv.split(idSplit);
        if (parts.length == 3) {
          final AppInfo? app = _appMap[parts[0] + idSplit + parts[1]];
          if (app != null) {
            app.rename = parts[2];
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
  Map<String, AppInfo> get appMap => _appMap;

  Set<String> get renamed => _renamedSet;

  List<String> get homeList => _homeList;
  Set<String> get homeSet => _homeSet;

  List<String> get hiddenList => _hiddenList;
  Set<String> get hiddenSet => _hiddenSet;

  List<AppInfo> get appList =>
      _apps.where((AppInfo app) => !_hiddenSet.contains(app.id)).toList();

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
            final Map<String, dynamic>? appInfoMap =
                event['appInfo'] as Map<String, dynamic>?;

            if (appInfoMap != null) {
              final AppInfo uninstalled = AppInfo.fromMap(appInfoMap);
              removeDeleted(id: uninstalled.id);
            }
            break;
        }
      }
    }, onError: (dynamic error) {
      ezLog('Error listening to app events: $error');
    });
  }

  // Post //

  Future<void> addHomeFolder() async {
    _homeList.add('Folder${folderSplit}empty');

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();
  }

  Future<void> _handleAppInstalled(Map<String, dynamic> appInfoMap) async {
    final AppInfo installed = AppInfo.fromMap(appInfoMap);

    _apps.add(installed);
    _appMap[installed.id] = installed;

    sort(
      AppListSortConfig.fromValue(
        EzConfig.get(appListSortKey) ?? EzConfig.getDefault(appListSortKey),
      ),
      EzConfig.get(appListOrderKey) ?? EzConfig.getDefault(appListOrderKey),
    );

    if (EzConfig.get(autoAddToHomeKey) == true &&
        !_homeSet.contains(installed.id)) {
      _homeList.add(installed.id);
      _homeSet.add(installed.id);
      await EzConfig.setStringList(homeIDsKey, _homeList);
    }

    notifyListeners();
  }

  // Put //

  void sort(ListSort sort, bool asc) {
    switch (sort) {
      case ListSort.name:
        _apps.sort((AppInfo a, AppInfo b) =>
            (asc) ? a.name.compareTo(b.name) : b.name.compareTo(a.name));

      case ListSort.publisher:
        _apps.sort((AppInfo a, AppInfo b) => (asc)
            ? a.package.compareTo(b.package)
            : b.package.compareTo(a.package));
    }
    notifyListeners();
  }

  Future<bool> addHomeApp({required String id}) async {
    if (_homeSet.contains(id)) return false;

    _homeList.add(id);
    _homeSet.add(id);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> removeHomeApp({required String id}) async {
    if (!_homeSet.contains(id)) return false;

    _homeList.remove(id);
    _homeSet.remove(id);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  /// Does not handle dupes; please handle before
  Future<bool> addToFolder({
    required int index,
    required String id,
  }) async {
    _homeList[index] = homeList[index] + folderSplit + id;
    _homeSet.contains(id) ? _homeList.remove(id) : _homeSet.add(id);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> removeFromFolder({
    required int index,
    required String id,
  }) async {
    _homeList[index] = _homeList[index].replaceFirst(
      folderSplit + id,
      '',
    );
    _homeList.add(id);

    if (!_homeList[index].contains(folderSplit)) {
      _homeList[index] = '${_homeList[index]}${folderSplit}empty';
    }

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  // Patch //

  Future<bool> hideApp({required String id}) async {
    if (_hiddenSet.contains(id)) return false;

    _hiddenList.add(id);
    _hiddenSet.add(id);

    await EzConfig.setStringList(hiddenIDsKey, _hiddenList);

    final bool notified = await removeHomeApp(id: id);
    if (!notified) notifyListeners();

    return true;
  }

  Future<bool> showApp({required String id}) async {
    if (!_hiddenSet.contains(id)) return false;

    _hiddenList.remove(id);
    _hiddenSet.remove(id);

    await EzConfig.setStringList(hiddenIDsKey, _hiddenList);
    notifyListeners();

    return true;
  }

  Future<bool> renameApp({
    required String id,
    required String newName,
  }) async {
    final AppInfo? app = _appMap[id];
    if (app == null || app.name == newName) return false;

    app.rename = newName;

    _renamedSet.removeWhere((String entry) => entry.startsWith(id));
    _renamedSet.add(id + idSplit + newName);

    await EzConfig.setStringList(renamedIDsKey, _renamedSet.toList());
    notifyListeners();

    return true;
  }

  Future<bool> renameFolder({
    required int index,
    required String newName,
  }) async {
    final String fullName = _homeList[index];
    final List<String> parts = fullName.split(folderSplit);
    if (parts[0] == newName) return false;

    final String newFullName = (parts.length > 1)
        ? newName + folderSplit + parts.join(folderSplit)
        : newName;
    _homeList[index] = newFullName;

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  Future<bool> reorderHomeItem({
    required int oldIndex,
    required int newIndex,
  }) async {
    if (oldIndex == newIndex) return false;

    if (newIndex > oldIndex) newIndex -= 1;

    final String id = _homeList.removeAt(oldIndex);
    _homeList.insert(newIndex, id);

    await EzConfig.setStringList(homeIDsKey, _homeList);
    notifyListeners();

    return true;
  }

  // Delete //

  Future<void> removeDeleted({required String id}) async {
    await showApp(id: id);
    await removeHomeApp(id: id);
    _apps.remove(_appMap[id]);
    _appMap.remove(id);

    notifyListeners();
  }

  Future<void> deleteFolder({required String fullName}) async {
    final List<String> ids = fullName.split(':').sublist(1);
    for (final String id in ids) {
      _homeSet.remove(id);
    }

    _homeList.remove(fullName);
    await EzConfig.setStringList(homeIDsKey, _homeList);

    notifyListeners();
  }

  @override
  void dispose() {
    _appEventSubscription?.cancel();
    super.dispose();
  }
}
