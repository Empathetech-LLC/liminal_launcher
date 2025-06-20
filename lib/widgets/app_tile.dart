/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppTile extends StatefulWidget {
  final AppInfo app;
  final bool homeApp;
  final bool editing;
  final void Function(String package) editCallback;

  const AppTile({
    super.key,
    required this.app,
    required this.homeApp,
    required this.editing,
    required this.editCallback,
  });

  @override
  State<AppTile> createState() => _AppTileState();
}

class _AppTileState extends State<AppTile> {
  // Set pointers //
  late final AppInfo app = widget.app;
  late final bool homeApp = widget.homeApp;
  late bool editing = widget.editing;
  late final void Function(String package) editCallback = widget.editCallback;

  @override
  Widget build(BuildContext context) {
    return editing
        ? EzTextButton(
            text: 'Editing',
            onPressed: () {
              final List<String> homeApps = List<String>.from(
                  EzConfig.get(homePackagesKey) ??
                      defaultConfig[homePackagesKey] as List<String>);

              homeApp
                  ? homeApps.remove(app.package)
                  : homeApps.add(app.package);

              EzConfig.setStringList(homePackagesKey, homeApps);
              editCallback(app.package);
            },
            onLongPress: () => setState(() => editing = !editing),
          )
        : EzTextButton(
            text: widget.app.label,
            onPressed: () => launchApp(widget.app.package),
            onLongPress: () => setState(() => editing = !editing),
          );
  }
}
