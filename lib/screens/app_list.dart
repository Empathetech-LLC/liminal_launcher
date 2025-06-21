/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();

  late final double safeTop = MediaQuery.paddingOf(context).top;

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  bool editing = false;

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 0) {
              // Swiped down
              Navigator.of(context).pop();
            }
          }
        },
        child: EzScreen(
          child: EzScrollView(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              EzSpacer(space: safeTop),
              ...provider.apps.expand((AppInfo app) {
                return <Widget>[
                  AppTile(
                    app: app,
                    homeApp: false,
                    editing: editing,
                    editCallback: () {
                      // Set state? Should mostly be in the provider
                    },
                  ),
                  spacer,
                ];
              }),
            ],
          ),
        ),
      ),
    );
  }
}
