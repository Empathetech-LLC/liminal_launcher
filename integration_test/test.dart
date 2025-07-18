/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:empathetech_launcher/main.dart';
import 'package:empathetech_launcher/widgets/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

void main() async {
  // Setup the test environment //

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues(mobileEmpathConfig);
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  EzConfig.init(
    preferences: prefs,
    defaults: mobileEmpathConfig,
    fallbackLang: await EFUILang.delegate.load(english),
    assetPaths: <String>{},
  );

  // Run the tests //

  group(
    'Generated tests',
    () {
      testWidgets('Test randomizer', (WidgetTester tester) async {
        // Load localization(s) //

        ezLog('Loading localizations');
        final EFUILang l10n = await EFUILang.delegate.load(english);

        // Load the app //

        ezLog('Loading Empathetech Launcher');
        await tester.pumpWidget(const EmpathetechLauncher());
        await tester.pumpAndSettle();

        // Randomize the settings //

        // Open the settings menu
        await ezTouch(tester, find.byIcon(Icons.more_vert));

        // Go to the settings page
        await ezTouchText(tester, l10n.ssPageTitle);

        // Randomize the settings
        await ezTouchText(tester, l10n.ssRandom);
        await ezTouchText(tester, l10n.gYes);

        // Return to home screen
        await ezTapBack(tester, l10n.gBack);
      });

      testWidgets('Test CountFAB', (WidgetTester tester) async {
        // Re-load the app //

        ezLog('Loading Empathetech Launcher');
        await tester.pumpWidget(const EmpathetechLauncher());
        await tester.pumpAndSettle();

        // ♫ It's as Ez as... ♫ //

        await ezTouch(tester, find.byType(CountFAB)); // 1
        await ezTouch(tester, find.byType(CountFAB)); // 2
        await ezTouch(tester, find.byType(CountFAB)); // 3
      });
    },
  );
}
