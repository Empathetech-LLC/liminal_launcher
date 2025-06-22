/* empathetech_launcher
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
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSeparator separator = EzSeparator();

  late final double safeTop = MediaQuery.paddingOf(context).top;
  final EdgeInsets modalPadding = EzInsets.col(EzConfig.get(spacingKey));

  late final TextTheme textTheme = Theme.of(context).textTheme;
  late final MaterialLocalizations localizations =
      MaterialLocalizations.of(context);

  // Define the build data //

  final bool homeTime = EzConfig.get(homeTimeKey) ?? defaultConfig[homeTimeKey];
  final bool homeDate = EzConfig.get(homeDateKey) ?? defaultConfig[homeDateKey];

  DateTime now = DateTime.now();
  late Timer ticker;

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  /// Ordered list of home package [String]s
  late final List<String> homePackages = List<String>.from(
      EzConfig.get(homePackagesKey) ?? defaultConfig[homePackagesKey]);

  /// Ordered list of home [AppInfo]s
  late final List<AppInfo> homeApps = homeP2A();

  bool editing = false;

  // Define custom Widgets //

  Widget header() {
    final List<Widget> children = <Widget>[];

    if (homeTime) {
      children.add(EzText(
        TimeOfDay.fromDateTime(now).format(context),
        style: textTheme.headlineLarge,
      ));
    }

    if (homeDate) {
      children.add(EzText(
        localizations.formatMediumDate(now),
        style: textTheme.labelLarge,
      ));
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  // Define custom functions //

  /// Home packages [String]s to [AppInfo]s
  List<AppInfo> homeP2A() => homePackages
      .map((String package) => provider.getAppFromID(package))
      .whereType<AppInfo>() // Filter nulls
      .toList();

  /// Home [AppInfo]s to [AppTile]s
  List<Widget> homeA2T() => homeApps.expand((AppInfo app) {
        return <Widget>[
          AppTile(
            key: ValueKey<String>(app.package),
            app: app,
            homeApp: true,
            editing: editing,
            editCallback: () async {
              homePackages.remove(app.package);
              homeApps.remove(app);

              await EzConfig.setStringList(homePackagesKey, homePackages);
              setState(() {});
            },
          ),
          spacer,
        ];
      }).toList();

  // Init //

  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => setState(() => editing = !editing),
        onVerticalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swiped up
              context.goNamed(editing ? hiddenListPath : appListPath);
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            late final String? package;

            if (details.primaryVelocity! < 0) {
              package = EzConfig.get(leftPackageKey);
            } else if (details.primaryVelocity! > 0) {
              package = EzConfig.get(rightPackageKey);
            } // No action for 0

            if (package != null && package.isNotEmpty) launchApp(package);
          }
        },
        child: EzScreen(
          child: Column(
            children: <Widget>[
              EzSpacer(space: safeTop),
              header(),
              separator,

              // App list
              EzScrollView(key: UniqueKey(), children: homeA2T()),
            ],
          ),
        ),
      ),
      fab: Visibility(
        visible: editing,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AddFAB(
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
                          .where((AppInfo app) => !homeApps.contains(app))
                          .map((AppInfo app) => Padding(
                                padding: modalPadding,
                                child: EzTextButton(
                                  key: ValueKey<String>(app.package),
                                  text: app.label,
                                  onPressed: () async {
                                    homePackages.add(app.package);
                                    homeApps.add(app);

                                    await EzConfig.setStringList(
                                      homePackagesKey,
                                      homePackages,
                                    );

                                    setState(() {});
                                    setModalState(() {});
                                  },
                                ),
                              ))
                          .toList(), // TODO: Move me to setup
                    );
                  },
                ),
              ),
            ),
            separator,
            SettingsFAB(context, () async {
              await context.pushNamed(settingsHomePath);
              setState(() => editing = false);
            })
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}
