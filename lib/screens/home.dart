/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSpacer rowSpacer = EzSpacer(vertical: false);
  static const EzSeparator separator = EzSeparator();

  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets listPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  final bool homeTime =
      EzConfig.get(homeTimeKey) ?? EzConfig.getDefault(homeTimeKey);
  final bool homeDate =
      EzConfig.get(homeDateKey) ?? EzConfig.getDefault(homeDateKey);

  // final bool homeWeather =
  //     EzConfig.get(homeWeatherKey) ?? EzConfig.getDefault(homeWeatherKey);

  // final HeaderOrder headerOrder = HeaderOrderConfig.fromValue(
  //     EzConfig.get(headerOrderKey) ?? EzConfig.getDefault(headerOrderKey));

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final ListAlignment homeAlign = ListAlignmentConfig.fromValue(
      EzConfig.get(homeAlignmentKey) ?? EzConfig.getDefault(homeAlignmentKey));

  final bool listIcon =
      EzConfig.get(listIconKey) ?? EzConfig.getDefault(listIconKey);
  final LabelType listLabel = LabelTypeConfig.fromValue(
      EzConfig.get(listLabelTypeKey) ?? EzConfig.getDefault(listLabelTypeKey));

  bool editing = false;
  bool atBottom = false;

  late final Map<String, dynamic> appListData = listData(
    listCheck: (String id) => !provider.hiddenSet.contains(id),
    onSelected: (String id) => launchApp(id),
    refresh: refresh,
  );
  late final Map<String, dynamic> hiddenListData = listData(
    listCheck: (String id) => provider.hiddenSet.contains(id),
    onSelected: (String id) => launchApp(id),
    icon: PlatformIcons(context).eyeSlash,
    refresh: refresh,
  );

  // Define custom functions //

  List<Widget> homeA2T() {
    final List<Widget> tileList = <Widget>[];

    for (int index = 0; index < provider.homeList.length; index++) {
      final String item = provider.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          key: ValueKey<String>('${parts[0]}_$index'),
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: AppFolder(
            index: index,
            name: parts[0],
            ids: parts[0] == emptyTag ? <String>[] : parts.sublist(1),
            alignment: homeAlign,
            folderIcon: listIcon,
            editing: editing,
            refresh: refresh,
          ),
        ));
      } else {
        final AppInfo app = provider.appMap[parts[0]] ?? nullApp;
        tileList.add(Padding(
          key: ValueKey<String>(app.id),
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: AppTile(
            app: app,
            onHomeScreen: true,
            onSelected: (String id) => launchApp(id),
            editing: editing,
            refresh: refresh,
          ),
        ));
      }
    }

    return tileList;
  }

  void refresh() => setState(() {});

  // Define custom Widgets //

  Widget header() {
    final List<Widget> children = <Widget>[];

    if (homeTime || homeDate) {
      children.add(_Clock(
        homeTime: homeTime,
        homeDate: homeDate,
        homeAlign: homeAlign,
        textTheme: textTheme,
      ));
    }

    // if (homeWeather) {
    //   children.add(EzText(
    //     'Weather',
    //     style: textTheme.headlineLarge,
    //   ));
    // }

    if (children.length == 2) children.insert(1, rowSpacer);

    return Row(
      mainAxisAlignment: homeAlign.mainAxis,
      children: children, // headerOrder == HeaderOrder.timeFirst
      // ? children
      // : children.reversed.toList(),
    );
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () async {
          final bool needAuth = !editing &&
              (EzConfig.get(authToEditKey) ??
                  EzConfig.getDefault(authToEditKey));
          // Check every time so no reset is required; O(1)

          if (needAuth) {
            bool authed = false;

            try {
              authed = await LocalAuthentication().authenticate(
                localizedReason: 'Authenticate to continue',
              );
            } catch (e) {
              if (context.mounted) {
                ezLogAlert(context, message: e.toString());
              }
            }

            if (!authed) return;
          }

          setState(() => editing = !editing);
        },
        onVerticalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swiped up
              context.goNamed(
                appListPath,
                extra: editing ? hiddenListData : appListData,
              );
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            AppInfo? toLaunch;

            if (details.primaryVelocity! < 0 && !editing) {
              toLaunch = provider.appMap[EzConfig.get(leftAppKey)];
            } else if (details.primaryVelocity! > 0) {
              editing
                  ? setState(() => editing = false)
                  : toLaunch = provider.appMap[EzConfig.get(rightAppKey)];
            }

            if (toLaunch != null) launchApp(toLaunch.package);
          }
        },
        child: LiminalScreen(Column(
          crossAxisAlignment: homeAlign.crossAxis,
          children: <Widget>[
            header(),
            spacer,

            // App list
            editing
                ? NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is OverscrollNotification &&
                          notification.overscroll > 0) {
                        // Navigate on bottom overscroll
                        if (atBottom) {
                          context.goNamed(appListPath, extra: hiddenListData);
                          return true;
                        } else {
                          setState(() => atBottom = true);
                          return true;
                        }
                      } else if (notification is ScrollUpdateNotification) {
                        if (atBottom && notification.metrics.pixels < 0) {
                          setState(() => atBottom = false);
                        }
                      } else if (notification is ScrollEndNotification) {
                        atBottom = (notification.metrics.pixels ==
                            notification.metrics.maxScrollExtent);
                        setState(() {});
                      }
                      return false; // Let other notifications propagate
                    },
                    child: Expanded(
                      child: ReorderableListView(
                        onReorder: (int oldIndex, int newIndex) async {
                          await provider.reorderHomeItem(
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          );
                          refresh();
                        },
                        children: homeA2T(),
                      ),
                    ),
                  )
                : EzScrollView(
                    crossAxisAlignment: homeAlign.crossAxis,
                    children: homeA2T(),
                  ),
            spacer,
          ],
        )),
      ),
      fab: Visibility(
        visible: editing,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Add folder
            if (provider.homeSet.isNotEmpty) ...<Widget>[
              AddFolderFAB(context, () {
                provider.addHomeFolder();
                refresh();
              }),
              separator,
            ],

            // Add app
            AddAppFAB(
              context,
              () => context.goNamed(
                appListPath,
                extra: listData(
                  listCheck: (String id) =>
                      !provider.hiddenSet.contains(id) &&
                      !provider.homeSet.contains(id),
                  onSelected: (String id) => provider.addHomeApp(id),
                  icon: PlatformIcons(context).add,
                  refresh: refresh,
                ),
              ),
            ),
            separator,

            // Settings
            SettingsFAB(context, () => context.goNamed(settingsHomePath))
          ],
        ),
      ),
    );
  }
}

class _Clock extends StatefulWidget {
  final bool homeTime;
  final bool homeDate;
  final ListAlignment homeAlign;
  final TextTheme textTheme;

  const _Clock({
    required this.homeTime,
    required this.homeDate,
    required this.homeAlign,
    required this.textTheme,
  });

  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> {
  DateTime now = DateTime.now();
  late Timer ticker;

  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return EzTextBackground(Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.homeAlign.crossAxis,
      children: <Widget>[
        if (widget.homeTime)
          Text(
            TimeOfDay.fromDateTime(now).format(context),
            style: widget.textTheme.headlineLarge,
          ),
        if (widget.homeDate)
          Text(
            MaterialLocalizations.of(context).formatMediumDate(now),
            style: widget.textTheme.labelLarge,
          ),
      ],
    ));
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
