/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './models.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Liminal Launcher
const String appTitle = 'Liminal Launcher';

/// [AppInfo] with package 'net.empathetech.liminal'
const AppInfo self = AppInfo(
  label: 'Liminal Launcher',
  package: 'net.empathetech.liminal',
);

// Header
const String homeTimeKey = 'home_time';
const String homeDateKey = 'home_date';
const String homeWeatherKey = 'home_weather';
const String weatherPositionKey = 'weather_position';
const String hideStatusBarKey = 'hide_status_bar';

// Home list
const String homePackagesKey = 'home_packages';
const String homeAlignmentKey = 'home_alignment';
const String leftPackageKey = 'left_package';
const String rightPackageKey = 'right_package';

// Full list
const String fullListAlignmentKey = 'full_list_alignment';
const String extendTileKey = 'extend_tile';
const String autoSearchKey = 'auto_search';
const String hiddenPackagesKey = 'hidden_packages';
const String nonZenPackagesKey = 'non_zen_packages';
const String zenStreamKey = 'zen_stream'; // Extreme zen

// Design
const String notificationIconKey = 'notification_icon';
const String buttonTypeKey = 'button_type';
const String authToEditKey = 'auth_to_edit';
const String tapLockKey = 'tap_lock';

// Wallpaper(s)
const String wallpapersKey = 'wallpapers';
const String dailyWallpapersKey = 'daily_wallpapers';

/// [mobileEmpathConfig] with Liminal additions
final Map<String, Object> defaultConfig = <String, Object>{
  ...mobileEmpathConfig,
  hideScrollKey: true,

  // Header
  homeTimeKey: true,
  homeDateKey: true,
  homeWeatherKey: true,
  weatherPositionKey: 'top_right',
  hideStatusBarKey: false,

  // Home list
  homePackagesKey: <String>[],
  homeAlignmentKey: 'center',
  leftPackageKey: '',
  rightPackageKey: '',

  // Full list
  fullListAlignmentKey: 'center',
  extendTileKey: false,
  autoSearchKey: false,
  hiddenPackagesKey: <String>[],
  nonZenPackagesKey: <String>[],
  zenStreamKey: false,

  // Design
  notificationIconKey: '',
  buttonTypeKey: 'text',
  authToEditKey: false,
  tapLockKey: false,

  // Wallpaper(s)
  wallpapersKey: <String>[],
  dailyWallpapersKey: false,
};

// TODO: turn the values above into an enum (probs on the relevant page)
// TODO: make a model or equivalent for zen schedule
