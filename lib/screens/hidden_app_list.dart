/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class HiddenAppListScreen extends StatefulWidget {
  const HiddenAppListScreen({super.key});

  @override
  State<HiddenAppListScreen> createState() => _HiddenAppListScreenState();
}

class _HiddenAppListScreenState extends State<HiddenAppListScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  List<String> packages = EzConfig.get(hiddenPackagesKey) ?? <String>[];

  final ListAlignment listAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(fullListAlignmentKey) ??
        EzConfig.getDefault(fullListAlignmentKey),
  );

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
              // Pop on scroll down (backup for tiny lists)
              Navigator.of(context).pop();
            }
          }
        },
        child: EzScreen(
          // Pop on overscroll
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is OverscrollNotification &&
                  notification.overscroll < 0 &&
                  notification.metrics.pixels <=
                      notification.metrics.minScrollExtent + 1) {
                Navigator.of(context).pop();
                return true;
              }
              return false;
            }, // TODO: fix this
            child: EzScrollView(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: listAlign.crossAxis,
              children: packages.expand((String package) {
                final AppInfo? app = provider.getAppFromID(package);
                if (app == null) return <Widget>[];

                return <Widget>[
                  AppTile(
                    app: app,
                    onHomeScreen: false,
                    editing: editing,
                  ),
                  spacer,
                ];
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
