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
  late final EdgeInsets modalPadding = EzInsets.col(spacing);

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  final bool homeTime =
      EzConfig.get(homeTimeKey) ?? EzConfig.getDefault(homeTimeKey);
  final bool homeDate =
      EzConfig.get(homeDateKey) ?? EzConfig.getDefault(homeDateKey);

  // final bool homeWeather =
  //     EzConfig.get(homeWeatherKey) ?? EzConfig.getDefault(homeWeatherKey);

  final HeaderOrder headerOrder = HeaderOrderConfig.fromValue(
      EzConfig.get(headerOrderKey) ?? EzConfig.getDefault(headerOrderKey));

  final ListAlignment homeAlign = ListAlignmentConfig.fromValue(
      EzConfig.get(homeAlignmentKey) ?? EzConfig.getDefault(homeAlignmentKey));

  bool atBottom = false;

  final LabelType labelType = LabelTypeConfig.fromValue(
      EzConfig.get(labelTypeKey) ?? EzConfig.getDefault(labelTypeKey));

  final bool showIcon =
      EzConfig.get(showIconKey) ?? EzConfig.getDefault(showIconKey);

  bool editing = false;

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  // Define custom functions //

  List<Widget> homeA2T() {
    final List<Widget> tileList = <Widget>[];

    for (int index = 0; index < provider.homeList.length; index++) {
      final String item = provider.homeList[index];
      final List<String> parts = item.split(folderSplit);

      if (parts.length > 1) {
        tileList.add(Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          key: ValueKey<String>('$index:${parts[0]}'),
          child: AppFolder(
            index: index,
            name: parts[0],
            ids: parts.sublist(1),
            provider: provider,
            alignment: homeAlign,
            showIcon: showIcon,
            labelType: labelType,
            editing: editing,
            refreshHome: refreshHome,
          ),
        ));
      } else {
        final AppInfo app = provider.appMap[parts[0]] ?? nullApp;
        tileList.add(Padding(
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          key: ValueKey<String>(app.id),
          child: AppTile(
            app: app,
            onHomeScreen: true,
            editing: editing,
            refreshHome: refreshHome,
          ),
        ));
      }
    }

    return tileList;
  }

  void refreshHome() => setState(() {});

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
      children: headerOrder == HeaderOrder.timeFirst
          ? children
          : children.reversed.toList(),
    );
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () async {
          final bool needAuth =
              EzConfig.get(authToEditKey) ?? EzConfig.getDefault(authToEditKey);
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
                editing ? hiddenListPath : appListPath,
                extra: editing ? null : refreshHome,
              );
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            String? package;

            if (details.primaryVelocity! < 0 && !editing) {
              package = EzConfig.get(leftPackageKey);
            } else if (details.primaryVelocity! > 0) {
              editing
                  ? setState(() => editing = false)
                  : package = EzConfig.get(rightPackageKey);
            }

            if (package != null && package.isNotEmpty) launchApp(package);
          }
        },
        child: EzScreen(
          child: Column(
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
                          // Pop on top overscroll
                          if (atBottom) {
                            context.goNamed(hiddenListPath);
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
                        return false;
                      },
                      child: Expanded(
                        child: ReorderableListView(
                          onReorder: (int oldIndex, int newIndex) async {
                            await provider.reorderHomeItem(
                              oldIndex: oldIndex,
                              newIndex: newIndex,
                            );
                            refreshHome();
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
          ),
        ),
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
                refreshHome();
              }),
              separator,
            ],

            // Add app
            AddAppFAB(
              context,
              () => showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (_) => StatefulBuilder(
                  builder: (_, StateSetter setModalState) {
                    return EzScrollView(
                      mainAxisSize: MainAxisSize.min,
                      children: provider.apps
                          .where((AppInfo app) =>
                              !provider.homeSet.contains(app.id) &&
                              !provider.hiddenSet.contains(app.id))
                          .map((AppInfo app) => Padding(
                                padding: modalPadding,
                                child: TileButton(
                                  key: ValueKey<String>(app.id),
                                  app: app,
                                  type: labelType,
                                  showIcon: showIcon,
                                  onPressed: () async {
                                    await provider.addHomeApp(id: app.id);
                                    setModalState(() {});
                                    refreshHome();
                                  },
                                ),
                              ))
                          .toList(),
                    );
                  },
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.homeAlign.crossAxis,
      children: <Widget>[
        if (widget.homeTime)
          EzText(
            TimeOfDay.fromDateTime(now).format(context),
            style: widget.textTheme.headlineLarge,
          ),
        if (widget.homeDate)
          EzText(
            MaterialLocalizations.of(context).formatMediumDate(now),
            style: widget.textTheme.labelLarge,
          ),
      ],
    );
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
