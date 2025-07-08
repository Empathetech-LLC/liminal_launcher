/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
  bool atBottom = false;

  final ScrollController appScrollControl = ScrollController();
  final ScrollController searchScrollControl = ScrollController();

  final TextEditingController searchController = TextEditingController();
  final bool autoSearch =
      EzConfig.get(autoSearchKey) ?? EzConfig.getDefault(autoSearchKey);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    final List<AppInfo> appList = provider.appList;
    final List<AppInfo> searchList = provider.appList
        .where((AppInfo app) => app.name
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
        .toList();

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
              if (spacing > margin) EzSpacer(space: spacing - margin),

              // List controls
              EzScrollView(
                scrollDirection: Axis.horizontal,
                mainAxisAlignment: listAlign.mainAxis,
                children: <Widget>[
                  // Sort
                  MenuAnchor(
                    builder: (_, MenuController controller, __) => EzIconButton(
                      onPressed: () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                      icon: const Icon(Icons.sort),
                    ),
                    menuChildren: <EzMenuButton>[
                      EzMenuButton(
                        label: 'Name',
                        textAlign: listAlign.textAlign,
                        onPressed: () async {
                          listSort = ListSort.name;

                          await EzConfig.setString(
                            appListSortKey,
                            listSort.configValue,
                          );
                          provider.sort(listSort, ascList);

                          setState(() {});
                        },
                      ),
                      EzMenuButton(
                        label: 'Publisher',
                        textAlign: listAlign.textAlign,
                        onPressed: () async {
                          listSort = ListSort.publisher;

                          await EzConfig.setString(
                            appListSortKey,
                            listSort.configValue,
                          );
                          provider.sort(listSort, ascList);

                          setState(() {});
                        },
                      ),
                    ],
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

                  // Search
                ],
              ),
              spacer,

              // App list
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is OverscrollNotification &&
                      notification.overscroll < 0) {
                    // Pop on top overscroll
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

                    if (atBottom &&
                        notification.metrics.pixels <
                            notification.metrics.maxScrollExtent) {
                      setState(() => atBottom = false);
                    }
                  } else if (notification is ScrollEndNotification) {
                    atTop = (notification.metrics.pixels == 0);
                    atBottom = (notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent);
                    setState(() {});
                  }
                  return false;
                },
                child: Expanded(
                  child: searchController.text.isNotEmpty
                      ? ListView.builder(
                          controller: searchScrollControl,
                          physics: const ClampingScrollPhysics(),
                          itemCount: searchList.length,
                          itemBuilder: (_, int index) => Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: spacing / 2),
                            key: ValueKey<String>(searchList[index].id),
                            child: AppTile(
                              app: searchList[index],
                              onHomeScreen: false,
                              editing: false,
                              refreshHome: widget.refreshHome,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: appScrollControl,
                          physics: const ClampingScrollPhysics(),
                          itemCount: appList.length,
                          itemBuilder: (_, int index) => Padding(
                            padding:
                                EdgeInsets.symmetric(vertical: spacing / 2),
                            key: ValueKey<String>(appList[index].id),
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
      fab: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Scroll to top
          if (!atTop)
            FloatingActionButton(
              onPressed: () {
                appScrollControl.animateTo(
                  0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
              child: EzIcon(PlatformIcons(context).upArrow),
            ),

          // Spacer (if needed)
          if (!atTop && !atBottom) spacer,

          // Scroll to bottom
          if (!atBottom)
            FloatingActionButton(
              onPressed: () {
                appScrollControl.animateTo(
                  appScrollControl.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
              child: EzIcon(PlatformIcons(context).downArrow),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    appScrollControl.dispose();
    searchController.dispose();
    super.dispose();
  }
}
