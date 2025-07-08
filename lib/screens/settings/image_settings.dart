/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class ImageSettingsScreen extends StatefulWidget {
  const ImageSettingsScreen({super.key});

  @override
  State<ImageSettingsScreen> createState() => _ImageSettingsScreenState();
}

class _ImageSettingsScreenState extends State<ImageSettingsScreen> {
  // Gather the theme data //

  static const EzSeparator separator = EzSeparator();

  final EzSpacer margin = EzMargin();

  late bool isDark = isDarkTheme(context);
  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late final String themeProfile =
      isDark ? el10n.gDark.toLowerCase() : el10n.gLight.toLowerCase();

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      EzScreen(
        child: EzScrollView(
          children: <Widget>[
            // Current theme reminder
            EzText(
              el10n.gEditingTheme(themeProfile),
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            margin,

            // Wallpaper
            EzScrollView(
              scrollDirection: Axis.horizontal,
              startCentered: true,
              mainAxisSize: MainAxisSize.min,
              child: isDark
                  ? EzImageSetting(
                      key: UniqueKey(),
                      configKey: darkBackgroundImageKey,
                      label: 'Wallpaper',
                      updateTheme: Brightness.dark,
                    )
                  : EzImageSetting(
                      key: UniqueKey(),
                      configKey: lightBackgroundImageKey,
                      label: 'Wallpaper',
                      updateTheme: Brightness.light,
                    ),
            ),
            separator,

            // Local reset all
            // EzResetButton(
            //   dialogTitle: el10n.isResetAll(themeProfile),
            //   onConfirm: () => EzConfig.removeKeys(imageKeys.keys.toSet()),
            // ),
            // separator,
          ],
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
