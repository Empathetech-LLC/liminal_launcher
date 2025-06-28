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

  final EdgeInsets modalPadding = EzInsets.col(EzConfig.get(spacingKey));

  late final TextTheme textTheme = Theme.of(context).textTheme;
  late final MaterialLocalizations localizations =
      MaterialLocalizations.of(context);

  // Define the build data //

  final bool homeTime =
      EzConfig.get(homeTimeKey) ?? EzConfig.getDefault(homeTimeKey);
  final bool homeDate =
      EzConfig.get(homeDateKey) ?? EzConfig.getDefault(homeDateKey);

  DateTime now = DateTime.now();
  late Timer ticker;

  final bool homeWeather =
      EzConfig.get(homeWeatherKey) ?? EzConfig.getDefault(homeWeatherKey);

  final HeaderOrder headerOrder = HeaderOrderConfig.fromValue(
      EzConfig.get(headerOrderKey) ?? EzConfig.getDefault(headerOrderKey));

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  final ListAlignment homeAlign = ListAlignmentConfig.fromValue(
      EzConfig.get(homeAlignmentKey) ?? EzConfig.getDefault(homeAlignmentKey));

  /// Ordered list of home package [String]s
  late final List<String> homePackages = List<String>.from(
      EzConfig.get(homePackagesKey) ?? EzConfig.getDefault(homePackagesKey));

  /// Ordered list of home [AppInfo]s
  late final List<AppInfo> homeApps = homeP2A();

  final LabelType labelType = LabelTypeConfig.fromValue(
      EzConfig.get(labelTypeKey) ?? EzConfig.getDefault(labelTypeKey));

  final bool showIcon =
      EzConfig.get(showIconKey) ?? EzConfig.getDefault(showIconKey);

  bool editing = false;

  // Define custom Widgets //

  Widget header() {
    final List<Widget> rowChildren = <Widget>[];
    final List<Widget> colChildren = <Widget>[];

    if (homeTime) {
      colChildren.add(EzText(
        TimeOfDay.fromDateTime(now).format(context),
        style: textTheme.headlineLarge,
      ));
    }

    if (homeDate) {
      colChildren.add(EzText(
        localizations.formatMediumDate(now),
        style: textTheme.labelLarge,
      ));
    }

    if (homeTime || homeDate) {
      rowChildren.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: homeAlign.crossAxis,
          children: colChildren,
        ),
      );
    }

    if (homeWeather) {
      rowChildren.add(EzText(
        'Weather', // TODO: Weather widget
        style: textTheme.headlineLarge,
      ));
    }

    if (rowChildren.length == 2) rowChildren.insert(1, rowSpacer);

    return Row(
      mainAxisAlignment: homeAlign.mainAxis,
      children: headerOrder == HeaderOrder.timeFirst
          ? rowChildren
          : rowChildren.reversed.toList(),
    );
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
            onHomeScreen: true,
            editing: editing,
            stateSetter: () => setState(() {}),
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
            crossAxisAlignment: homeAlign.crossAxis,
            children: <Widget>[
              header(),
              separator,

              // App list
              EzScrollView(
                key: UniqueKey(),
                crossAxisAlignment: homeAlign.crossAxis,
                children: homeA2T(),
              ),
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
                                child: TileButton(
                                  key: ValueKey<String>(app.package),
                                  app: app,
                                  type: labelType,
                                  showIcon: showIcon,
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
            SettingsFAB(context, () => context.goNamed(settingsHomePath))
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
