/* liminal_launcher
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

  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets listPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final ListAlignment listAlign = ListAlignmentConfig.fromValue(
    EzConfig.get(fullListAlignmentKey) ??
        EzConfig.getDefault(fullListAlignmentKey),
  );

  bool atTop = true;

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
        child: LiminalScreen(
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is OverscrollNotification &&
                  notification.overscroll < 0) {
                // Pop on overscroll (when already the top)
                if (atTop) {
                  Navigator.of(context).pop();
                  return true;
                } else {
                  setState(() => atTop = true);
                  return true;
                }
              } else if (notification is ScrollUpdateNotification) {
                if (atTop && notification.metrics.pixels > 0) {
                  setState(() => atTop = false);
                }
              } else if (notification is ScrollEndNotification) {
                setState(() =>
                    atTop = (notification.metrics.pixels == 0) ? true : false);
              }
              return false; // Let other notifications propagate
            },
            child: EzScrollView(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: listAlign.crossAxis,
              physics: const ClampingScrollPhysics(),
              children: provider.hiddenList
                  .map((String id) {
                    final AppInfo? app = provider.appMap[id];

                    return (app == null)
                        ? null
                        : Padding(
                            key: ValueKey<String>(app.id),
                            padding: listPadding,
                            child: AppTile(
                              app: app,
                              onHomeScreen: false,
                              editing: false,
                            ),
                          );
                  })
                  .whereType<Widget>()
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
