/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';
import '../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:installed_apps/index.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Gather the theme data //

  late final Lang l10n = Lang.of(context)!;

  late final TextTheme textTheme = Theme.of(context).textTheme;
  late final TextStyle? subTitle = ezSubTitleStyle(textTheme);

  // Define the build data //

  int count = 0;

  // Set the page title //

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ezWindowNamer(context, appTitle);
  }

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return EmpathetechLauncherScaffold(
      title: appTitle,
      body: EzScreen(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: Provider.of<AppInfoProvider>(context)
                .apps
                .map((AppInfo app) => Text(app.name))
                .toList(),
          ),
        ),
      ),
    );
  }
}
