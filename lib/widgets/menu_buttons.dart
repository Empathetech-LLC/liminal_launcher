/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../screens/export.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:go_router/go_router.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SettingsButton extends StatelessWidget {
  final BuildContext parentContext;

  /// [EzMenuButton] for opening the settings
  const SettingsButton(this.parentContext, {super.key});

  @override
  Widget build(BuildContext context) => EzMenuButton(
        onPressed: () => parentContext.goNamed(settingsHomePath),
        icon: EzIcon(PlatformIcons(context).settings),
        label: ezL10n(context).ssPageTitle,
      );
}

class EFUICredits extends StatelessWidget {
  final BuildContext parentContext;

  /// [EzMenuButton] for opening Open UI's product page
  /// Honor system: keep a version of this in your app
  /// Remove iff appropriate contributions have been made to Empathetech LLC
  /// https://www.empathetech.net/#/contribute
  const EFUICredits(this.parentContext, {super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLefty = EzConfig.get(isLeftyKey) ?? false;

    final EFUILang l10n = ezL10n(context);
    final String label = isLefty ? l10n.gMadeBy : l10n.gCreator;
    final String tip = l10n.gOpenEmpathetech;
    final String settings = l10n.ssPageTitle;

    return Link(
      uri: Uri.parse('https://www.empathetech.net/#/products/open-ui'),
      builder: (_, FollowLink? followLink) => Tooltip(
        message: tip,
        excludeFromSemantics: true,
        child: EzMenuButton(
          onPressed: followLink,
          icon: EzIcon(PlatformIcons(context).settings),
          label: label,
          semanticsLabel:
              '${isLefty ? '$settings $label' : '$label $settings'}. $tip',
        ),
      ),
    );
  }
}
