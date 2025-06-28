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

  final double margin = EzConfig.get(marginKey);
  final double spacing = EzConfig.get(spacingKey);

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final ListAlignment listAlign = ListAlignmentConfig.fromValue(
      EzConfig.get(fullListAlignmentKey) ??
          EzConfig.getDefault(fullListAlignmentKey));

  ListSort listSort = AppListSortConfig.fromValue(
    EzConfig.get(appListSortKey) ?? EzConfig.getDefault(appListSortKey),
  );

  bool ascList =
      EzConfig.get(ascListOrderKey) ?? EzConfig.getDefault(ascListOrderKey);

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
          child: NotificationListener<ScrollNotification>(
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
              children: <Widget>[
                if (spacing > margin) EzSpacer(space: spacing - margin),

                // List controls
                EzScrollView(
                  scrollDirection: Axis.horizontal,
                  mainAxisAlignment: listAlign.mainAxis,
                  children: <Widget>[
                    // Sort
                    EzDropdownMenu<ListSort>(
                      widthEntries: <String>['Publisher'],
                      dropdownMenuEntries: const <DropdownMenuEntry<ListSort>>[
                        DropdownMenuEntry<ListSort>(
                          value: ListSort.name,
                          label: 'Name',
                        ),
                        DropdownMenuEntry<ListSort>(
                          value: ListSort.publisher,
                          label: 'Publisher',
                        ),
                      ],
                      enableSearch: false,
                      initialSelection: listSort,
                      onSelected: (ListSort? choice) async {
                        if (choice == null) return;
                        listSort = choice;

                        await EzConfig.setString(
                          appListSortKey,
                          listSort.configValue,
                        );
                        provider.sort(listSort, ascList);

                        setState(() {});
                      },
                    ),
                    const EzSpacer(vertical: false),

                    // Order
                    EzIconButton(
                      icon: EzIcon(
                          ascList ? Icons.arrow_upward : Icons.arrow_downward),
                      onPressed: () async {
                        ascList = !ascList;

                        await EzConfig.setBool(appListSortKey, ascList);
                        provider.sort(listSort, ascList);

                        setState(() {});
                      },
                    ),
                  ],
                ),
                spacer,

                // App list
                ...provider.apps.expand((AppInfo app) {
                  return <Widget>[
                    AppTile(
                      app: app,
                      homeApp: false,
                      editing: false,
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
      ),
    );
  }
}
