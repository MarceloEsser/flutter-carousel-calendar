import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/string_extension.dart';
import 'package:intl/intl.dart';
import 'default_styles.dart' show defaultHeaderTextStyle;

class CalendarHeader extends StatelessWidget {
  /// Passing in values for [leftButtonIcon] or [rightButtonIcon] will override [headerIconColor]
  CalendarHeader(
      {required this.headerTitle,
      this.headerMargin,
      required this.showHeader,
      this.headerTextStyle,
      this.showHeaderButtons = true,
      this.headerIconColor,
      this.leftButtonIcon,
      this.rightButtonIcon,
      required this.onLeftButtonPressed,
      required this.onRightButtonPressed,
      this.onHeaderTitlePressed,
      required this.locale,
      required this.dates,
      required this.pageNum})
      : isTitleTouchable = onHeaderTitlePressed != null;

  final String headerTitle;
  final EdgeInsetsGeometry? headerMargin;
  final bool showHeader;
  final String locale;
  final TextStyle? headerTextStyle;
  final bool showHeaderButtons;
  final Color? headerIconColor;
  final Widget? leftButtonIcon;
  final Widget? rightButtonIcon;
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;
  final bool isTitleTouchable;
  final List<DateTime> dates;
  final int pageNum;
  final VoidCallback? onHeaderTitlePressed;

  TextStyle get getTextStyle => headerTextStyle ?? defaultHeaderTextStyle;
  Widget _leftButton() => IconButton(
        onPressed: onLeftButtonPressed,
        icon:
            leftButtonIcon ?? Icon(Icons.chevron_left, color: headerIconColor),
      );

  Widget _rightButton() => IconButton(
        onPressed: onRightButtonPressed,
        icon: rightButtonIcon ??
            Icon(Icons.chevron_right, color: headerIconColor),
      );

  Widget _headerTouchable() => FlatButton(
        onPressed: onHeaderTitlePressed,
        child: Text(
          headerTitle,
          semanticsLabel: headerTitle,
          style: getTextStyle,
        ),
      );

  String formattedDate() =>
      '${DateFormat.MMMM(locale).format(dates[pageNum])} ${dates[pageNum].year}'
          .capitalize();

  @override
  Widget build(BuildContext context) => showHeader
      ? Container(
          child: DefaultTextStyle(
              style: getTextStyle,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showHeaderButtons ? _leftButton() : Container(),
                    isTitleTouchable
                        ? _headerTouchable()
                        : Text(formattedDate(), style: getTextStyle),
                    showHeaderButtons ? _rightButton() : Container(),
                  ])),
        )
      : Container();
}
