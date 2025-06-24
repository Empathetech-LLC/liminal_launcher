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

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final ListAlignment listAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(fullListAlignmentKey) ?? defaultConfig[fullListAlignmentKey],
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
              // Pop on swipe down (backup for non-scroll portions)
              Navigator.of(context).pop();
            }
          }
        },
        child: EzScreen(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: listAlign.crossAxis,
            children: <Widget>[
              // Sort/order controls
              const SizedBox.shrink(),
              const EzSeparator(),

              // App list
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  // Pop on overscroll
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
                  children: provider.apps.expand((AppInfo app) {
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
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
