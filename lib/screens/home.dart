/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:empathetech_launcher/screens/export.dart';

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

  late final Lang l10n = Lang.of(context)!;

  late final TextTheme textTheme = Theme.of(context).textTheme;
  late final TextStyle? subTitle = ezSubTitleStyle(textTheme);

  // Define the build data //

  late final AppInfoProvider provider = Provider.of<AppInfoProvider>(context);

  late final List<AppInfo> homeApps = provider.apps
      .where((AppInfo app) => EzConfig.get(homePackages).any(
          (List<String>? packages) => packages?.contains(app.package) ?? false))
      .toList(); // TODO: faster

  // Set the page title //

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ezWindowNamer(context, appTitle);
  }

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
              // TODO: not a sheet
              await showModalBottomSheet(
                context: context,
                builder: (_) => StatefulBuilder(
                  builder: (_, StateSetter setModalState) {
                    return EzScrollView(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: provider.apps.expand((AppInfo app) {
                        return <Widget>[
                          EzTextButton(
                            text: app.label,
                            onPressed: () => launchApp(app.package),
                          ),
                          spacer,
                        ];
                      }).toList(),
                    );
                  },
                ),
              );
            }
          }
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            late final String? package;

            if (details.primaryVelocity! < 0) {
              package = EzConfig.get(leftPackage);
            } else if (details.primaryVelocity! > 0) {
              package = EzConfig.get(rightPackage);
            } // No action for 0

            if (package != null) {
              launchApp(provider.apps
                  .firstWhere((AppInfo app) => app.package == package)
                  .package);
            } // TODO: faster
          }
        },
        child: EzScreen(
          child: Center(
            child: EzScrollView(
              mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ),
      ),
    );
  }
}
