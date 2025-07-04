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
  final void Function()? refreshHome;

  const AppListScreen({super.key, this.refreshHome});

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
      EzConfig.get(appListOrderKey) ?? EzConfig.getDefault(appListOrderKey);

  bool atTop = true;

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final List<AppInfo> appList = provider.appList;

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
          child: Column(
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

                      await EzConfig.setBool(appListOrderKey, ascList);
                      provider.sort(listSort, ascList);

                      setState(() {});
                    },
                  ),
                ],
              ),
              spacer,

              // App list
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
                    setState(() => atTop =
                        (notification.metrics.pixels == 0) ? true : false);
                  }
                  return false;
                },
                child: Expanded(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: appList.length,
                    itemBuilder: (_, int index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: spacing / 2),
                      key: ValueKey<String>(appList[index].keyLabel),
                      child: AppTile(
                        app: appList[index],
                        onHomeScreen: false,
                        editing: false,
                        refreshHome: widget.refreshHome,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
