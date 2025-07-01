/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../utils/export.dart';
import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class ImageSettingsScreen extends StatefulWidget {
  const ImageSettingsScreen({super.key});

  @override
  State<ImageSettingsScreen> createState() => _ImageSettingsScreenState();
}

class _ImageSettingsScreenState extends State<ImageSettingsScreen> {
  // Gather the theme data //

  static const EzSpacer spacer = EzSpacer();
  static const EzSeparator separator = EzSeparator();

  final EzSpacer margin = EzMargin();

  late bool isDark = isDarkTheme(context);
  late final EFUILang el10n = ezL10n(context);

  // Define the build data //

  late final String themeProfile =
      isDark ? el10n.gDark.toLowerCase() : el10n.gLight.toLowerCase();

  bool useOS =
      EzConfig.get(useOSWallpaperKey) ?? EzConfig.getDefault(useOSWallpaperKey);

  // Return the build //

  @override
  Widget build(BuildContext context) {
    return LiminalScaffold(
      LiminalScreen(
        child: EzScrollView(
          children: <Widget>[
            // Current theme reminder
            EzText(
              el10n.gEditingTheme(themeProfile),
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
            useOS ? spacer : margin,

            // Wallpaper
            if (!useOS) ...<Widget>[
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
              spacer,
            ],

            // Use built in?
            EzSwitchPair(
              text: 'Use OS wallpaper',
              value: useOS,
              onChanged: (bool? choice) async {
                if (choice == null) return;

                if (choice == true) {
                  final PermissionStatus status =
                      await Permission.storage.request();

                  if (status.isDenied ||
                      status.isRestricted ||
                      status.isPermanentlyDenied) {
                    return;
                  }
                }

                await EzConfig.setBool(useOSWallpaperKey, choice);
                setState(() => useOS = choice);
              },
            ),

            // Local reset all
            separator,
            EzResetButton(
              dialogTitle: el10n.isResetAll(themeProfile),
              onConfirm: () async {
                await EzConfig.removeKeys(<String>{
                  ...imageKeys.keys,
                  useOSWallpaperKey,
                });

                setState(() =>
                    useOS = EzConfig.getDefault(useOSWallpaperKey) ?? true);
              },
            ),
            separator,
          ],
        ),
      ),
      fab: EzBackFAB(context),
    );
  }
}
