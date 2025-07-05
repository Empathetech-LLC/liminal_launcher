/* liminal_launcher
 * Copyright (c) 2025 Empathetech LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import './export.dart';
import 'package:flutter/material.dart';

// BTS settings //

enum ListSort { name, publisher }

const String _name = 'name';
const String _publisher = 'publisher';

extension AppListSortConfig on ListSort {
  String get configValue {
    switch (this) {
      case ListSort.name:
        return _name;
      case ListSort.publisher:
        return _publisher;
    }
  }

  static ListSort fromValue(String value) {
    switch (value) {
      case _publisher:
        return ListSort.publisher;
      default:
        return ListSort.name;
    }
  }
}

// Layout settings //

enum HeaderOrder { timeFirst, weatherFirst }

const String _timeFirst = 'time_first';
const String _weatherFirst = 'weather_first';

extension HeaderOrderConfig on HeaderOrder {
  String get configValue {
    switch (this) {
      case HeaderOrder.timeFirst:
        return _timeFirst;
      case HeaderOrder.weatherFirst:
        return _weatherFirst;
    }
  }

  static HeaderOrder fromValue(String value) {
    switch (value) {
      case _weatherFirst:
        return HeaderOrder.weatherFirst;
      default:
        return HeaderOrder.timeFirst;
    }
  }
}

enum ListAlignment { center, start, end }

const String _center = 'center';
const String _start = 'start';
const String _end = 'end';

extension ListAlignmentConfig on ListAlignment {
  String get configValue {
    switch (this) {
      case ListAlignment.center:
        return _center;
      case ListAlignment.start:
        return _start;
      case ListAlignment.end:
        return _end;
    }
  }

  Alignment get alignment {
    switch (this) {
      case ListAlignment.center:
        return Alignment.center;
      case ListAlignment.start:
        return Alignment.centerLeft;
      case ListAlignment.end:
        return Alignment.centerRight;
    }
  }

  MainAxisAlignment get mainAxis {
    switch (this) {
      case ListAlignment.center:
        return MainAxisAlignment.center;
      case ListAlignment.start:
        return MainAxisAlignment.start;
      case ListAlignment.end:
        return MainAxisAlignment.end;
    }
  }

  CrossAxisAlignment get crossAxis {
    switch (this) {
      case ListAlignment.center:
        return CrossAxisAlignment.center;
      case ListAlignment.start:
        return CrossAxisAlignment.start;
      case ListAlignment.end:
        return CrossAxisAlignment.end;
    }
  }

  TextAlign get textAlign {
    switch (this) {
      case ListAlignment.center:
        return TextAlign.center;
      case ListAlignment.start:
        return TextAlign.start;
      case ListAlignment.end:
        return TextAlign.end;
    }
  }

  static ListAlignment fromValue(String value) {
    switch (value) {
      case _start:
        return ListAlignment.start;
      case _end:
        return ListAlignment.end;
      default:
        return ListAlignment.center;
    }
  }
}

// Design settings //

enum LabelType { none, initials, full, wingding }

const String _none = 'none';
const String _initials = 'initials';
const String _full = 'full';

extension LabelTypeConfig on LabelType {
  String get configValue {
    switch (this) {
      case LabelType.none:
        return _none;
      case LabelType.initials:
        return _initials;
      case LabelType.full:
        return _full;
      case LabelType.wingding:
        return wingding;
    }
  }

  static LabelType fromValue(String value) {
    switch (value) {
      case _none:
        return LabelType.none;
      case _initials:
        return LabelType.initials;
      case wingding:
        return LabelType.wingding;
      default:
        return LabelType.full;
    }
  }
}
