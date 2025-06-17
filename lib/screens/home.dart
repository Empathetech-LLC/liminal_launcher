/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';
import '../utils/export.dart';
import '../widgets/export.dart';

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

  late final double safeTop = MediaQuery.paddingOf(context).top;
  late final double safeBottom = MediaQuery.paddingOf(context).bottom;

  late final TextTheme textTheme = Theme.of(context).textTheme;

  // Define the build data //

  final bool homeTime = EzConfig.get(homeTimeKey) ?? defaultConfig[homeTimeKey];
  final bool homeDate = EzConfig.get(homeDateKey) ?? defaultConfig[homeDateKey];

  // TODO: Shared DateTime listener

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final List<String> homeList =
      EzConfig.get(homePackagesKey) ?? <String>[];
  late final List<AppInfo> homeApps = provider.apps
      .where((AppInfo app) => homeList.contains(app.package))
      .toList(); // TODO: faster

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => context.goNamed(settingsHomePath),
        onVerticalDragEnd: (DragEndDetails details) async {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swiped up
              context.goNamed(appListPath);
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

            if (package != null && package.isNotEmpty) {
              launchApp(provider.apps
                  .firstWhere((AppInfo app) => app.package == package)
                  .package);
            } // TODO: faster
          }
        },
        child: EzScreen(
          child: Column(
            children: <Widget>[
              // Header
              EzSpacer(space: safeTop),
              // TODO: Function for this
              if (homeTime) ...<Widget>[
                EzText(
                  '${DateTime.now().hour} : ${DateTime.now().minute.toString().padLeft(2, '0')}',
                  style: textTheme.headlineLarge,
                ),
              ],
              if (homeDate) ...<Widget>[
                EzText(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: textTheme.labelLarge,
                ),
              ],

              // App list
              EzScrollView(
                children: homeApps.expand((AppInfo app) {
                  return <Widget>[
                    EzTextButton(
                      text: app.label,
                      onPressed: () => launchApp(app.package),
                    ),
                    spacer,
                  ];
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
