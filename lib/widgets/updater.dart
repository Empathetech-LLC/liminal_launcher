/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// 'https://raw.githubusercontent.com/Empathetech-LLC/liminal_launcher/refs/heads/main/APP_VERSION'
const String _versionSource =
    'https://raw.githubusercontent.com/Empathetech-LLC/liminal_launcher/refs/heads/main/APP_VERSION';

/// 1.0.0
const String _appVersion = '1.0.0';

class EzUpdater extends StatefulWidget {
  /// Checks for Open UI updates
  /// [FloatingActionButton] (wrapped in a [Visibility]) that links to the latest version
  const EzUpdater({super.key});

  @override
  State<EzUpdater> createState() => _EzUpdaterState();
}

class _EzUpdaterState extends State<EzUpdater> {
  // Define build data //

  String? latestVersion;

  bool isLatest = true; // True to start to prevent flickering

  // Define custom functions //

  /// Check for Open UI updates (Desktop only)
  void checkVersion() async {
    if (isMobile()) return;

    final http.Response response = await http.get(Uri.parse(_versionSource));

    if (response.statusCode != 200) return;

    latestVersion = response.body;
    if (latestVersion != _appVersion && latestVersion != null) {
      final List<int> latestDigits =
          latestVersion!.split('.').map(int.parse).toList();

      if (latestDigits.length != 3) return;

      final List<int> appDigits =
          _appVersion.split('.').map(int.parse).toList();

      for (int i = 0; i < latestDigits.length; i++) {
        if (latestDigits[i] > appDigits[i]) {
          setState(() => isLatest = false);
          return;
        } else if (latestDigits[i] < appDigits[i]) {
          return;
        } // if == continue
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) => Visibility(
        visible: !isLatest,
        child: IconButton(
          onPressed: () => launchUrl(Uri.parse(
              'https://github.com/Empathetech-LLC/liminal_launcher/releases')),
          tooltip: ezL10n(context).gUpdates,
          icon: EzIcon(Icons.update),
        ),
      );
}
