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
  static const EzSeparator separator = EzSeparator();

  final double spacing = EzConfig.get(spacingKey);

  late final EdgeInsets listPadding =
      EdgeInsets.symmetric(vertical: spacing / 2);

  late final ColorScheme colorScheme = Theme.of(context).colorScheme;

  late final TextTheme textTheme = Theme.of(context).textTheme;

  final ListAlignment homeAlign = ListAlignmentConfig.fromValue(
      EzConfig.get(homeAlignmentKey) ?? EzConfig.getDefault(homeAlignmentKey));

  final bool listIcon =
      EzConfig.get(listIconKey) ?? EzConfig.getDefault(listIconKey);
  final LabelType listLabel = LabelTypeConfig.fromValue(
      EzConfig.get(listLabelTypeKey) ?? EzConfig.getDefault(listLabelTypeKey));

  final bool folderIcon =
      EzConfig.get(folderIconKey) ?? EzConfig.getDefault(folderIconKey);
  final LabelType folderLabel = LabelTypeConfig.fromValue(
      EzConfig.get(folderLabelTypeKey) ??
          EzConfig.getDefault(folderLabelTypeKey));

  // Define the build data //

  final bool homeTime =
      EzConfig.get(homeTimeKey) ?? EzConfig.getDefault(homeTimeKey);
  final bool homeDate =
      EzConfig.get(homeDateKey) ?? EzConfig.getDefault(homeDateKey);

  late final AppInfoProvider listener = Provider.of<AppInfoProvider>(context);
  late final AppInfoProvider editor =
      Provider.of<AppInfoProvider>(context, listen: false);

  late List<Widget> homeTiles = homeA2T();

  late final Map<String, dynamic> appListData = listData(
    listCheck: (String id) => !listener.hiddenSet.contains(id),
    onSelected: (String id) => launchApp(id),
    refresh: refresh,
  );
  late final Map<String, dynamic> hiddenListData = listData(
    listCheck: (String id) => listener.hiddenSet.contains(id),
    onSelected: (String id) => launchApp(id),
    icon: EzTextBackground(EzRow(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Hidden\t', style: textTheme.labelLarge),
        EzIcon(
          PlatformIcons(context).eyeSlash,
          color: colorScheme.onSurface,
        ),
      ],
    )),
    refresh: refresh,
  );

  bool editing = false;
  bool atBottom = false;

  // Define custom functions //

  void refresh() => setState(() => homeTiles = homeA2T());

  List<Widget> homeA2T() {
    final List<Widget> tileList = <Widget>[];

    for (int index = 0; index < listener.homeList.length; index++) {
      final String item = listener.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          key: ValueKey<String>('${parts[0]}_$index'),
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: AppFolder(
            listener: listener,
            editor: editor,
            index: index,
            alignment: homeAlign,
            folderLabel: folderLabel,
            folderIcon: listIcon,
            appIcon: listIcon,
            appLabel: listLabel,
            editing: editing,
            refresh: refresh,
          ),
        ));
      } else {
        final AppInfo app = listener.appMap[parts[0]] ?? nullApp;
        tileList.add(Padding(
          key: ValueKey<String>(app.id),
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: AppTile(
            app: app,
            listener: listener,
            editor: editor,
            onHomeScreen: true,
            labelType: listLabel,
            showIcon: listIcon,
            onSelected: (String id) => launchApp(id),
            editing: editing,
            refresh: refresh,
          ),
        ));
      }
    }

    return tileList;
  }

  // Define custom Widgets //

  Widget header() => (homeTime || homeDate)
      ? _Clock(
          homeTime: homeTime,
          homeDate: homeDate,
          homeAlign: homeAlign,
          textTheme: textTheme,
        )
      : const SizedBox.shrink();

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

          editing = !editing;
          setState(() => homeTiles = homeA2T());
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
              toLaunch = listener.appMap[EzConfig.get(leftSwipeIDKey)];
            } else if (details.primaryVelocity! > 0) {
              editing
                  ? setState(() => editing = false)
                  : toLaunch = listener.appMap[EzConfig.get(rightSwipeIDKey)];
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
                        setState(() => atBottom =
                            (notification.metrics.pixels ==
                                notification.metrics.maxScrollExtent));
                      }
                      return false; // Let other notifications propagate
                    },
                    child: Expanded(
                      child: ReorderableListView(
                        onReorder: (int oldIndex, int newIndex) async {
                          final bool reordered = await editor.reorderHomeItem(
                            oldIndex: oldIndex,
                            newIndex: newIndex,
                          );
                          if (reordered) refresh();
                        },
                        children: homeTiles,
                      ),
                    ),
                  )
                : EzScrollView(
                    crossAxisAlignment: homeAlign.crossAxis,
                    children: homeTiles,
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
            if (listener.homeSet.isNotEmpty) ...<Widget>[
              AddFolderFAB(context, () {
                editor.addHomeFolder();
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
                      !listener.hiddenSet.contains(id) &&
                      !listener.homeSet.contains(id),
                  onSelected: (String id) => editor.addHomeApp(id),
                  refresh: refresh,
                  autoRefresh: true,
                  icon: EzTextBackground(EzRow(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Home\t', style: textTheme.labelLarge),
                      EzIcon(
                        PlatformIcons(context).add,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  )),
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

    ticker = widget.homeTime
        ? Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) setState(() => now = DateTime.now());
          })
        : Timer.periodic(const Duration(minutes: 1), (_) {
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
