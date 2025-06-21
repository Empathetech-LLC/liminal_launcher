/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../../widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

class LayoutSettingsScreen extends StatelessWidget {
  const LayoutSettingsScreen({super.key});

  static const EzSpacer spacer = EzSpacer();

  @override
  Widget build(BuildContext context) => LiminalScaffold(
        const SafeArea(
          child: EzLayoutSettings(additionalSettings: <Widget>[
            EzRow(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                EzText('Weather layout'),
                //DropdownMenu(dropdownMenuEntries: blarg),
              ],
            ),
            spacer,
            EzText('Home list alignment'),
            spacer,
            EzText('Full list alignment'),
          ]),
        ),
        fab: EzBackFAB(context),
      );
}

// const EzDominantHandSwitch(),
//               spacer,
