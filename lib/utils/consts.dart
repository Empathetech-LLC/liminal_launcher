/* empathetech_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';

import 'package:empathetech_flutter_ui/empathetech_flutter_ui.dart';

/// Liminal Launcher
const String appTitle = 'Liminal Launcher';

/// [AppInfo] with package 'net.empathetech.liminal'
const AppInfo self = AppInfo(
  label: 'Liminal Launcher',
  package: 'net.empathetech.liminal',
);

// BTS
const String homePackagesKey = 'home_packages';
const String hiddenPackagesKey = 'hidden_packages';
const String appListSortKey = 'app_list_sort';
const String appListOrderKey = 'app_list_order';

// Functionality
const String leftPackageKey = 'left_package';
const String rightPackageKey = 'right_package';
const String autoSearchKey = 'auto_search';
const String authToEditKey = 'auth_to_edit';

// Layout
const String headerOrderKey = 'header_order';
const String homeAlignmentKey = 'home_alignment';
const String fullListAlignmentKey = 'full_list_alignment';

// Design
const String homeTimeKey = 'home_time';
const String homeDateKey = 'home_date';
const String homeWeatherKey = 'home_weather';
const String showIconKey = 'show_icon';
const String labelTypeKey = 'label_type';
const String extendTileKey = 'extend_tile';

/// [mobileEmpathConfig] with Liminal additions
final Map<String, Object> defaultConfig = <String, Object>{
  ...mobileEmpathConfig,

  // BTS
  homePackagesKey: <String>[],
  hiddenPackagesKey: <String>[],
  appListSortKey: ListSort.name.configValue,
  appListOrderKey: true,

  // Functionality
  leftPackageKey: '',
  rightPackageKey: '',
  autoSearchKey: false,
  authToEditKey: false,

  // Layout
  headerOrderKey: HeaderOrder.timeFirst.configValue,
  homeAlignmentKey: ListAlignment.center.configValue,
  fullListAlignmentKey: ListAlignment.center.configValue,

  // Design
  homeTimeKey: true,
  homeDateKey: true,
  homeWeatherKey: true,
  showIconKey: false,
  labelTypeKey: LabelType.full.configValue,
  extendTileKey: false,
};
