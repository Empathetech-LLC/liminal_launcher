/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './screens/export.dart';
import './utils/export.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:feedback/feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

void main() async {
  // Setup the app //

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize EzConfig //

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  EzConfig.init(
    preferences: prefs,
    defaults: defaultConfig,
    fallbackLang: await EFUILang.delegate.load(english),
    assetPaths: <String>{},
  );

  // Run the app //
  // With a feedback wrapper

  late final TextStyle lightFeedbackText = ezBodyStyle(Colors.black);
  late final TextStyle darkFeedbackText = ezBodyStyle(Colors.white);

  runApp(BetterFeedback(
    theme: FeedbackThemeData(
      background: Colors.grey,
      feedbackSheetColor: Colors.white,
      activeFeedbackModeColor: empathPurple,
      bottomSheetDescriptionStyle: lightFeedbackText,
      bottomSheetTextInputStyle: lightFeedbackText,
      sheetIsDraggable: true,
      dragHandleColor: Colors.black,
    ),
    darkTheme: FeedbackThemeData(
      background: Colors.grey,
      feedbackSheetColor: Colors.black,
      activeFeedbackModeColor: empathEucalyptus,
      bottomSheetDescriptionStyle: darkFeedbackText,
      bottomSheetTextInputStyle: darkFeedbackText,
      sheetIsDraggable: true,
      dragHandleColor: Colors.white,
    ),
    themeMode: EzConfig.getThemeMode(),
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[EzFeedbackLD()],
    localeOverride: EzConfig.getLocale(),
    child: EmpathetechLauncher(await getApps()),
  ));
}

/// Initialize a path based router for web-enabled apps
/// Or any other app that requires deep linking
/// https://docs.flutter.dev/ui/navigation/deep-linking
final GoRouter router = GoRouter(
  initialLocation: homePath,
  errorBuilder: (_, GoRouterState state) => ErrorScreen(state.error),
  routes: <RouteBase>[
    GoRoute(
      path: homePath,
      name: homePath,
      builder: (_, __) => const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: appListPath,
          name: appListPath,
          builder: (_, __) => const AppListScreen(),
        ),
        GoRoute(
          path: hiddenListPath,
          name: hiddenListPath,
          builder: (_, __) => const HiddenAppListScreen(),
        ),
        GoRoute(
          path: settingsHomePath,
          name: settingsHomePath,
          builder: (_, __) => const SettingsHomeScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: ezSettingsHomePath,
              name: ezSettingsHomePath,
              builder: (_, __) => const EzSettingsHomeScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: textSettingsPath,
                  name: textSettingsPath,
                  builder: (_, __) => const TextSettingsScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: EzTSType.quick.path,
                      name: EzTSType.quick.name,
                      builder: (_, __) =>
                          const TextSettingsScreen(target: EzTSType.quick),
                    ),
                    GoRoute(
                      path: EzTSType.advanced.path,
                      name: EzTSType.advanced.name,
                      builder: (_, __) =>
                          const TextSettingsScreen(target: EzTSType.advanced),
                    ),
                  ],
                ),
                GoRoute(
                  path: layoutSettingsPath,
                  name: layoutSettingsPath,
                  builder: (_, __) => const LayoutSettingsScreen(),
                ),
                GoRoute(
                  path: colorSettingsPath,
                  name: colorSettingsPath,
                  builder: (_, __) => const ColorSettingsScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: EzCSType.quick.path,
                      name: EzCSType.quick.name,
                      builder: (_, __) =>
                          const ColorSettingsScreen(target: EzCSType.quick),
                    ),
                    GoRoute(
                      path: EzCSType.advanced.path,
                      name: EzCSType.advanced.name,
                      builder: (_, __) =>
                          const ColorSettingsScreen(target: EzCSType.advanced),
                    ),
                  ],
                ),
                GoRoute(
                  path: imageSettingsPath,
                  name: imageSettingsPath,
                  builder: (_, __) => const ImageSettingsScreen(),
                ),
                GoRoute(
                  path: designSettingsPath,
                  name: designSettingsPath,
                  builder: (_, __) => const DesignSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class EmpathetechLauncher extends StatelessWidget {
  final List<AppInfo> installedApps;

  const EmpathetechLauncher(this.installedApps, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppInfoProvider>(
      create: (_) => AppInfoProvider(installedApps),
      child: EzAppProvider(
        app: PlatformApp.router(
          debugShowCheckedModeBanner: false,

          // Language handlers
          localizationsDelegates: <LocalizationsDelegate<dynamic>>{
            const LocaleNamesLocalizationsDelegate(),
            ...EFUILang.localizationsDelegates,
            ...Lang.localizationsDelegates,
          },

          // Supported languages
          supportedLocales: Lang.supportedLocales,

          // Current language
          locale: EzConfig.getLocale(),

          title: appTitle,
          routerConfig: router,
        ),
      ),
    );
  }
}
