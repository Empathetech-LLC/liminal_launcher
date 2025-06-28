/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import '../utils/export.dart';

import 'package:flutter/material.dart';

class AppFolder extends StatefulWidget {
  final List<AppInfo> apps;
  final bool editing;

  const AppFolder({super.key, required this.apps, required this.editing});

  @override
  State<AppFolder> createState() => _AppFolderState();
}

class _AppFolderState extends State<AppFolder> {
  // Return the build //

  @override
  Widget build(BuildContext context) {
    return const Text("I'm a folder!");
  }
}
