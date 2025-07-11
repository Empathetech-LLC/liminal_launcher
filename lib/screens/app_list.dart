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

Map<String, dynamic> listData({
  required bool Function(String id) listCheck,
  required Future<void> Function(String id) onSelected,
  Widget? icon,
  required void Function() refresh,
}) =>
    <String, dynamic>{
      ListData.listCheck.key: listCheck,
      ListData.onSelected.key: onSelected,
      ListData.icon.key: icon,
      ListData.refresh.key: refresh,
    };

class AppListScreen extends StatefulWidget {
  final bool Function(String) listCheck;
  final Future<void> Function(String id) onSelected;
  final Widget? icon;
  final void Function() refresh;

  const AppListScreen({
    super.key,
    required this.listCheck,
    required this.onSelected,
    this.icon,
    required this.refresh,
  });

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSpacer rowSpacer = EzSpacer(vertical: false);
  final EzSpacer rowMargin = EzMargin(vertical: false);

  final double margin = EzConfig.get(marginKey);
  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets listPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final ListAlignment listAlign = ListAlignmentConfig.fromValue(
      EzConfig.get(fullListAlignmentKey) ??
          EzConfig.getDefault(fullListAlignmentKey));

  AppSort listSort = AppSortConfig.fromValue(
    EzConfig.get(appSortKey) ?? EzConfig.getDefault(appSortKey),
  );
  bool ascList = EzConfig.get(appOrderKey) ?? EzConfig.getDefault(appOrderKey);

  final ScrollController scrollControl = ScrollController();

  late List<AppInfo> appList = getApps();
  late List<AppInfo> searchList = appList;

  bool searching =
      EzConfig.get(autoSearchKey) ?? EzConfig.getDefault(autoSearchKey);
  final TextEditingController searchControl = TextEditingController();

  bool atTop = true;
  bool atBottom = false;

  // Define custom functions //

  void refreshList() => setState(() => appList = getApps());

  void refreshAll() {
    widget.refresh();
    refreshList();
  }

  List<AppInfo> getApps() =>
      provider.apps.where((AppInfo app) => widget.listCheck(app.id)).toList();

  List<AppInfo> searchApps(List<AppInfo> appList) => appList
      .where((AppInfo app) =>
          app.name.toLowerCase().contains(searchControl.text.toLowerCase()))
      .toList();

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
        child: LiminalScreen(Column(
          mainAxisSize: MainAxisSize.min,
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
                    // By name
                    EzMenuButton(
                      label: 'Name',
                      textAlign: listAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.name;

                        await EzConfig.setString(
                          appSortKey,
                          listSort.configValue,
                        );
                        provider.sort(listSort, ascList);

                        refreshList();
                      },
                    ),
                    // By publisher
                    EzMenuButton(
                      label: 'Publisher',
                      textAlign: listAlign.textAlign,
                      onPressed: () async {
                        listSort = AppSort.publisher;

                        await EzConfig.setString(
                          appSortKey,
                          listSort.configValue,
                        );
                        provider.sort(listSort, ascList);

                        refreshList();
                      },
                    ),
                  ],
                ),
                rowSpacer,

                // Order
                EzIconButton(
                  icon: EzIcon(
                      ascList ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: () async {
                    ascList = !ascList;

                    await EzConfig.setBool(appOrderKey, ascList);
                    provider.sort(listSort, ascList);

                    refreshList();
                  },
                ),
                rowSpacer,

                // Search
                AnimatedContainer(
                  duration: animDuration,
                  width: searching ? 200 : null,
                  curve: Curves.easeInOut,
                  child: EzRow(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      EzIconButton(
                        icon: Icon(PlatformIcons(context).search),
                        onPressed: () {
                          if (searching) {
                            closeKeyboard(context);
                            searchControl.clear();

                            searchList = appList;
                            setState(() => searching = false);
                          } else {
                            searchList = searchApps(appList);
                            setState(() => searching = true);
                          }
                        },
                      ),
                      if (searching) ...<Widget>[
                        rowMargin,
                        Expanded(
                          child: TextField(
                            controller: searchControl,
                            autofocus: searching,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (_) => setState(
                                () => searchList = searchApps(appList)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (widget.icon != null) ...<Widget>[
              EzMargin(),
              widget.icon!,
            ],
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
              child: searching
                  ? Expanded(
                      child: ListView.builder(
                        controller: scrollControl,
                        physics: const ClampingScrollPhysics(),
                        itemCount: searchList.length,
                        itemBuilder: (_, int index) => Padding(
                          key: ValueKey<String>(searchList[index].id),
                          padding: listPadding,
                          child: AppTile(
                            app: searchList[index],
                            onHomeScreen: false,
                            editing: false,
                            onSelected: widget.onSelected,
                            refresh: refreshAll,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        controller: scrollControl,
                        physics: const ClampingScrollPhysics(),
                        itemCount: appList.length,
                        itemBuilder: (_, int index) => Padding(
                          key: ValueKey<String>(appList[index].id),
                          padding: listPadding,
                          child: AppTile(
                            app: appList[index],
                            onHomeScreen: false,
                            editing: false,
                            onSelected: widget.onSelected,
                            refresh: refreshAll,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        )),
      ),
      fab: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Scroll to top
          if (!atTop)
            FloatingActionButton(
              onPressed: () {
                scrollControl.animateTo(
                  0,
                  duration: animDuration,
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
                scrollControl.animateTo(
                  scrollControl.position.maxScrollExtent,
                  duration: animDuration,
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
    scrollControl.dispose();
    searchControl.dispose();
    super.dispose();
  }
}
