/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CountFAB extends StatelessWidget {
  /// [FloatingActionButton.onPressed] passthrough
  final void Function() count;

  /// Increases the count (for the home screen)
  const CountFAB(this.count, {super.key});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: count,
        child: EzIcon(PlatformIcons(context).add),
      );
}
