/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Liminal launcher
const String appTitle = 'Liminal launcher';

// Top third
const String homeTime = 'home_time';
const String homeDate = 'home_date';
const String homeWeather = 'home_weather';
const String weatherPosition = 'weather_position';
const String hideStatusBar = 'hide_status_bar';

// Home list
const String homeLength = 'home_length';
const String homePackages = 'home_packages';
const String homeAlignment = 'home_alignment';
const String leftPackage = 'left_package';
const String rightPackage = 'right_package';

// Wallpaper(s)
const String wallpapers = 'wallpapers';
const String dailyWallpapers = 'daily_wallpapers';

// Full list
const String fullListAlignment = 'full_list_alignment';
const String extendTile = 'extend_tile';
const String autoSearch = 'auto_search';
const String hiddenPackages = 'hidden_packages';
const String nonZenPackages = 'non_zen_packages';
const String zenStream = 'zen_stream'; // Extreme zen

// Design
const String notificationIcon = 'notification_icon';
const String buttonType = 'button_type';
const String tapLock = 'tap_lock';

/// [mobileEmpathConfig] with Liminal additions
const Map<String, Object> defaultConfig = <String, Object>{
  ...mobileEmpathConfig,

  // Top third
  homeTime: true,
  homeDate: true,
  homeWeather: true,
  weatherPosition: 'top_right',
  hideStatusBar: false,

  // Home list
  homeLength: 5,
  homePackages: <String>[],
  homeAlignment: 'center',
  leftPackage: '',
  rightPackage: '',

  // Wallpaper(s)
  wallpapers: <String>[],
  dailyWallpapers: false,

  // Full list
  fullListAlignment: 'center',
  extendTile: false,
  autoSearch: false,
  hiddenPackages: <String>[],
  nonZenPackages: <String>[],
  zenStream: false,

  // Design
  notificationIcon: '',
  buttonType: 'text',
  tapLock: false,
};

// TODO: turn the values above into an enum (probs on the relevant page)
// TODO: make a model or equivalent for zen schedule
