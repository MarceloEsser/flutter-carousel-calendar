library flutter_calendar_dooboo;

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/src/string_extension.dart';
import 'package:flutter_calendar_carousel/week.dart';
import 'package:flutter_calendar_carousel/src/calendar_carrousel_header.dart';
import 'package:flutter_calendar_carousel/src/calendar_header.dart';
import 'package:flutter_calendar_carousel/src/default_styles.dart';
import 'package:flutter_calendar_carousel/src/weekday_row.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:jiffy/jiffy.dart';

import 'classes/multiple_marked_dates.dart';

export 'package:flutter_calendar_carousel/classes/event_list.dart';

typedef MarkedDateIconBuilder<T> = Widget? Function(T event);
typedef void OnDayLongPressed(DateTime day);

/// This builder is called for every day in the calendar.
/// If you want to build only few custom day containers, return null for the days you want to leave with default looks
/// All characteristics like circle border are also applied to the custom day container [DayBuilder] provides.
/// (if supplied function returns null, Calendar's function will be called for [day]).
/// [isSelectable] - is between [CalendarCarousel.minSelectedDate] and [CalendarCarousel.maxSelectedDate]
/// [index] - DOES NOT equal day number! Index of the day built in current visible field
/// [isSelectedDay] - if the day is selected
/// [isToday] - if the day is similar to [DateTime.now()]
/// [isPrevMonthDay] - if the day is from previous month
/// [textStyle] - text style that would have been applied by the calendar if it was to build the day.
/// Example: if the user provided [CalendarCarousel.todayTextStyle] and [isToday] is true,
///   [CalendarCarousel.todayTextStyle] would be sent into [DayBuilder]'s [textStyle]. If user didn't
///   provide it, default [CalendarCarousel]'s textStyle would be sent. Same applies to all text styles like
///   [CalendarCarousel.prevDaysTextStyle], [CalendarCarousel.daysTextStyle] etc.
/// [isNextMonthDay] - if the day is from next month
/// [isThisMonthDay] - if the day is from next month
/// [day] - day being built.
typedef Widget? DayBuilder(
    bool isSelectable,
    int index,
    bool isSelectedDay,
    bool isToday,
    bool isPrevMonthDay,
    TextStyle textStyle,
    bool isNextMonthDay,
    bool isThisMonthDay,
    DateTime day);

/// This builder is called for every weekday container (7 times, from Mon to Sun).
/// [weekday] - weekday built, from 0 to 6.
/// [weekdayName] - string representation of the weekday (Mon, Tue, Wed, etc).
typedef Widget WeekdayBuilder(int weekday, String weekdayName);

class CalendarCarousel<T extends EventInterface> extends StatefulWidget {
  final BoxDecoration boxDecoration;
  final double viewportFraction;
  final TextStyle? prevDaysTextStyle;
  final TextStyle? daysTextStyle;
  final TextStyle? nextDaysTextStyle;
  final Color prevMonthDayBorderColor;
  final Color thisMonthDayBorderColor;
  final Color nextMonthDayBorderColor;
  final double dayPadding;
  double height;
  final double width;
  final TextStyle? todayTextStyle;
  final Color dayButtonColor;
  final Color todayBorderColor;
  final Color todayButtonColor;
  final DateTime? selectedDateTime;
  final DateTime? targetDateTime;
  final TextStyle? selectedDayTextStyle;
  final Color selectedDayButtonColor;
  final Color selectedDayBorderColor;
  final bool? daysHaveCircularBorder;
  final bool disableDayPressed;
  final Function(DateTime, List<DateTime>)? onDayPressed;
  final TextStyle? weekdayTextStyle;
  final Color iconColor;
  final TextStyle? headerTextStyle;
  final String? headerText;
  final TextStyle? weekendTextStyle;
  final List<DateTime>? markedDatesMap;

  /// Change `makredDateWidget` when `markedDateShowIcon` is set to false.
  final Widget? markedDateWidget;

  /// Change `ShapeBorder` when `markedDateShowIcon` is set to false.
  final ShapeBorder? markedDateCustomShapeBorder;

  /// Change `TextStyle` when `markedDateShowIcon` is set to false.
  final TextStyle? markedDateCustomTextStyle;

  /// Icon will overlap the [Day] widget when `markedDateShowIcon` is set to true.
  /// This will also make below parameters work.
  final bool markedDateShowIcon;
  final Color? markedDateIconBorderColor;
  final Color? markedWeekColor;
  final int markedDateIconMaxShown;
  final double markedDateIconMargin;
  final double markedDateIconOffset;
  final MarkedDateIconBuilder<T>? markedDateIconBuilder;

  /// null - no indicator, true - show the total events, false - show the total of hidden events
  final bool? markedDateMoreShowTotal;
  final Decoration? markedDateMoreCustomDecoration;
  final TextStyle? markedDateMoreCustomTextStyle;
  final EdgeInsets headerMargin;
  final double childAspectRatio;
  final EdgeInsets weekDayMargin;
  final EdgeInsets weekDayPadding;
  final WeekdayBuilder? customWeekDayBuilder;
  final DayBuilder? customDayBuilder;
  final Color weekDayBackgroundColor;
  final bool weekFormat;
  final bool showWeekDays;
  final bool showHeader;
  final bool showHeaderButton;
  final MultipleMarkedDates? multipleMarkedDates;
  final Widget? leftButtonIcon;
  final Widget? rightButtonIcon;
  final ScrollPhysics? customGridViewPhysics;
  final Function(DateTime?, int)? onCalendarChanged;
  final String locale;
  final int? firstDayOfWeek;
  final DateTime? minSelectedDate;
  final DateTime? maxSelectedDate;
  final TextStyle? inactiveDaysTextStyle;
  final TextStyle? inactiveWeekendTextStyle;
  final bool headerTitleTouchable;
  final Function? onHeaderTitlePressed;
  final Function? onLeftArrowPressed;
  final Function? onRightArrowPressed;
  final WeekdayFormat weekDayFormat;
  final bool staticSixWeekFormat;
  final bool isScrollable;
  final Axis scrollDirection;
  final bool showOnlyCurrentMonthDate;
  final bool pageSnapping;
  final OnDayLongPressed? onDayLongPressed;
  final CrossAxisAlignment dayCrossAxisAlignment;
  final MainAxisAlignment dayMainAxisAlignment;
  final bool showIconBehindDayText;
  final ScrollPhysics pageScrollPhysics;
  final bool shouldShowTransform;

  final bool hasCarouselHeader;

  final Color headerHighlightDateColor;
  final TextStyle headerHighlightDateStyle;
  final TextStyle headerNextAndPrevDateStyle;
  final List<Week>? completedWeeks;

  int totalItemCount = -1;

  final Color markedDateColor;

  CalendarCarousel({
    Key? key,
    this.markedDateColor = Colors.purple,
    this.boxDecoration = const BoxDecoration(),
    this.markedWeekColor = Colors.cyan,
    this.completedWeeks,
    this.headerHighlightDateColor = Colors.deepPurple,
    this.headerHighlightDateStyle =
        const TextStyle(color: Colors.white, fontSize: 18),
    this.headerNextAndPrevDateStyle =
        const TextStyle(color: Colors.grey, fontSize: 16),
    this.hasCarouselHeader = false,
    this.viewportFraction = 1.0,
    this.prevDaysTextStyle,
    this.daysTextStyle,
    this.nextDaysTextStyle,
    this.prevMonthDayBorderColor = Colors.transparent,
    this.thisMonthDayBorderColor = Colors.transparent,
    this.nextMonthDayBorderColor = Colors.transparent,
    this.dayPadding = 2.0,
    this.height = double.infinity,
    this.width = double.infinity,
    this.todayTextStyle,
    this.dayButtonColor = Colors.transparent,
    this.todayBorderColor = Colors.red,
    this.todayButtonColor = Colors.red,
    this.selectedDateTime,
    this.targetDateTime,
    this.selectedDayTextStyle,
    this.selectedDayBorderColor = Colors.green,
    this.selectedDayButtonColor = Colors.green,
    this.daysHaveCircularBorder,
    this.disableDayPressed = false,
    this.onDayPressed,
    this.weekdayTextStyle = const TextStyle(),
    this.iconColor = Colors.blueAccent,
    this.headerTextStyle,
    this.headerText,
    this.weekendTextStyle,
    this.markedDatesMap,
    this.markedDateShowIcon = false,
    this.markedDateIconBorderColor,
    this.markedDateIconMaxShown = 2,
    this.markedDateIconMargin = 5.0,
    this.markedDateIconOffset = 5.0,
    this.markedDateIconBuilder,
    this.markedDateMoreShowTotal,
    this.markedDateMoreCustomDecoration,
    this.markedDateCustomShapeBorder,
    this.markedDateCustomTextStyle,
    this.markedDateMoreCustomTextStyle,
    this.markedDateWidget,
    this.multipleMarkedDates,
    this.headerMargin = const EdgeInsets.symmetric(vertical: 16.0),
    this.childAspectRatio = 1.0,
    this.weekDayMargin = const EdgeInsets.only(bottom: 4.0),
    this.weekDayPadding = const EdgeInsets.all(0.0),
    this.weekDayBackgroundColor = Colors.transparent,
    this.customWeekDayBuilder,
    this.customDayBuilder,
    this.showWeekDays = true,
    this.weekFormat = false,
    this.showHeader = true,
    this.showHeaderButton = true,
    this.leftButtonIcon,
    this.rightButtonIcon,
    this.customGridViewPhysics,
    this.onCalendarChanged,
    this.locale = "en",
    this.firstDayOfWeek,
    this.minSelectedDate,
    this.maxSelectedDate,
    this.inactiveDaysTextStyle,
    this.inactiveWeekendTextStyle,
    this.headerTitleTouchable = false,
    this.onHeaderTitlePressed,
    this.onLeftArrowPressed,
    this.onRightArrowPressed,
    this.weekDayFormat = WeekdayFormat.short,
    this.staticSixWeekFormat = false,
    this.isScrollable = true,
    this.scrollDirection = Axis.horizontal,
    this.showOnlyCurrentMonthDate = false,
    this.pageSnapping = false,
    this.onDayLongPressed,
    this.dayCrossAxisAlignment = CrossAxisAlignment.center,
    this.dayMainAxisAlignment = MainAxisAlignment.center,
    this.showIconBehindDayText = false,
    this.pageScrollPhysics = const ScrollPhysics(),
    this.shouldShowTransform = true,
  }) : super(key: key);

  @override
  _CalendarState<T> createState() => _CalendarState<T>();
}

enum WeekdayFormat {
  weekdays,
  standalone,
  short,
  standaloneShort,
  narrow,
  standaloneNarrow,
}

class _CalendarState<T extends EventInterface>
    extends State<CalendarCarousel<T>> with TickerProviderStateMixin {
  late PageController _controller;
  late List<DateTime> _dates;
  late List<List<DateTime>> _weeks;
  DateTime _selectedDate = DateTime.now();
  late DateTime _targetDate;
  int _startWeekday = 0;
  int _endWeekday = 0;
  late DateFormat _localeDate;
  int _pageNum = 0;
  late DateTime minDate;
  late DateTime maxDate;
  late double _height;

  /// When FIRSTDAYOFWEEK is 0 in dart-intl, it represents Monday. However it is the second day in the arrays of Weekdays.
  /// Therefore we need to add 1 modulo 7 to pick the right weekday from intl. (cf. [GlobalMaterialLocalizations])
  late int firstDayOfWeek;

  late AnimationController _calendarSizeController;
  late Animation<double> _calendarSizeAnimation;

  int totalItemCount = -1;

  /// If the setState called from this class, don't reload the selectedDate, but it should reload selected date if called from external class

  @override
  initState() {
    super.initState();
    initializeDateFormatting();

    minDate = widget.minSelectedDate ??
        DateTime(
            DateTime.now().year - 1, DateTime.now().month, DateTime.now().day);
    maxDate = widget.maxSelectedDate ??
        DateTime(
            DateTime.now().year + 1, DateTime.now().month, DateTime.now().day);

    final selectedDateTime = widget.selectedDateTime;
    if (selectedDateTime != null) _selectedDate = selectedDateTime;

    _init();

    _localeDate = DateFormat.yMMM(widget.locale);
    firstDayOfWeek = widget.firstDayOfWeek ??
        (_localeDate.dateSymbols.FIRSTDAYOFWEEK + 1) % 7;

    _setDate();

    if (selectedDateTime != null && _dates.isNotEmpty) {
      _dates.asMap().forEach((index, element) {
        if (element.day == selectedDateTime.day &&
            element.month == selectedDateTime.month &&
            element.year == selectedDateTime.year) {
          _pageNum = index;
        }
      });
    }

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      if (widget.onCalendarChanged != null) {
        widget.onCalendarChanged!(null, this.totalItemCount);
      }
    });

    _height = widget.height;

    _calendarHeightAnimations();

    _controller = PageController(
      initialPage: this._pageNum,
      keepPage: true,
      viewportFraction: widget.viewportFraction,
    );
  }

  @override
  void didUpdateWidget(CalendarCarousel<T> oldWidget) {
    if (widget.height != _height) {
      _height = widget.height;
    }
    if (widget.targetDateTime != null && widget.targetDateTime != _targetDate) {
      targetDateTimeTravelControl();
      // _setDatesAndWeeks();
      // _init();
      // _setDate(_pageNum);
    }

    super.didUpdateWidget(oldWidget);
  }

  void targetDateTimeTravelControl() {
    if (widget.targetDateTime != null) {
      _targetDate = widget.targetDateTime ?? DateTime.now();
      if (_targetDate.isBefore(minDate)) {
        minDate =
            DateTime(_targetDate.year - 1, _targetDate.month, _targetDate.day);
      }
      if (_targetDate.isAfter(maxDate)) {
        maxDate =
            DateTime(_targetDate.year + 1, _targetDate.month, _targetDate.day);
      }
    }
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calendarHeightAnimations() {
    _calendarSizeController = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _calendarSizeAnimation = CurvedAnimation(
      parent: _calendarSizeController,
      curve: Curves.ease,
    );

    _calendarSizeController.forward();
  }

  _init() {
    final targetDateTime = widget.targetDateTime;
    if (targetDateTime != null) {
      if (targetDateTime.difference(minDate).inDays < 0) {
        _targetDate = minDate;
      } else if (targetDateTime.difference(maxDate).inDays > 0) {
        _targetDate = maxDate;
      } else {
        _targetDate = targetDateTime;
      }
    } else {
      _targetDate = _selectedDate;
    }
    if (widget.weekFormat) {
      _pageNum = _targetDate.difference(_firstDayOfWeek(minDate)).inDays ~/ 7;
    } else {
      _pageNum = (_targetDate.year - minDate.year) * 12 +
          _targetDate.month -
          minDate.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _calendarSizeAnimation,
      axis: Axis.vertical,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          decoration: widget.boxDecoration,
          width: widget.width,
          height: _height,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: buildCalendarHeader(),
              ),
              Container(
                child: WeekdayRow(
                  firstDayOfWeek,
                  widget.customWeekDayBuilder,
                  showWeekdays: widget.showWeekDays,
                  weekdayFormat: widget.weekDayFormat,
                  weekdayMargin: widget.weekDayMargin,
                  weekdayPadding: widget.weekDayPadding,
                  weekdayBackgroundColor: widget.weekDayBackgroundColor,
                  weekdayTextStyle: widget.weekdayTextStyle,
                  localeDate: _localeDate,
                ),
              ),
              Expanded(
                  child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: this._dates.length,
                onPageChanged: (index) {
                  this._setDate(index);
                },
                controller: _controller,
                itemBuilder: (context, index) {
                  _pageNum = index;
                  return builder(index);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCalendarHeader() {
    String? headerText = widget.headerText;

    final String defaultLocale = Platform.localeName;
    DateTime mDate = _dates[this._pageNum];
    if (widget.targetDateTime != null) {
      mDate = widget.targetDateTime ?? DateTime.now();
    }
    if (headerText == null)
      headerText =
          '${DateFormat.MMMM(defaultLocale).format(mDate)} ${mDate.year}'
              .capitalize();

    return widget.hasCarouselHeader
        ? CalendarCarouselHeader(
            nextAndPrevTextStyle: widget.headerNextAndPrevDateStyle,
            selectedDateColor: widget.headerHighlightDateColor,
            selectedDateTextStyle: widget.headerHighlightDateStyle,
            selectedIndex: this._pageNum,
            pageChangeListener: (index) {
              _controller.animateToPage(index,
                  duration: Duration(milliseconds: 300), curve: Curves.easeIn);
            },
            dates: _dates,
          )
        : CalendarHeader(
            pageNum: this._pageNum,
            locale: widget.locale,
            dates: _dates,
            showHeader: widget.showHeader,
            headerMargin: widget.headerMargin,
            headerTitle: headerText,
            headerTextStyle: widget.headerTextStyle,
            showHeaderButtons: widget.showHeaderButton,
            headerIconColor: widget.iconColor,
            leftButtonIcon: widget.leftButtonIcon,
            rightButtonIcon: widget.rightButtonIcon,
            onLeftButtonPressed: () {
              if (this._pageNum > 0) _setDate(this._pageNum - 1);
              if (widget.onLeftArrowPressed != null) {
                widget.onLeftArrowPressed!(widget.staticSixWeekFormat
                    ? 42
                    : DateTime(
                          _dates[_pageNum].year,
                          _dates[_pageNum].month + 1,
                          0,
                        ).day +
                        _startWeekday +
                        (7 - _endWeekday));
              }
            },
            onRightButtonPressed: () {
              if (this._dates.length - 1 > this._pageNum)
                _setDate(this._pageNum + 1);

              if (widget.onRightArrowPressed != null) {
                widget.onRightArrowPressed!(widget.staticSixWeekFormat
                    ? 42
                    : DateTime(
                          _dates[_pageNum].year,
                          _dates[_pageNum].month + 1,
                          0,
                        ).day +
                        _startWeekday +
                        (7 - _endWeekday));
              }
            },
            onHeaderTitlePressed: widget.headerTitleTouchable
                ? () {
                    final onHeaderTitlePressed = widget.onHeaderTitlePressed;
                    if (onHeaderTitlePressed != null) {
                      onHeaderTitlePressed();
                    } else {
                      _selectDateFromPicker();
                    }
                  }
                : null,
          );
  }

  Widget getDefaultDayContainer(
    bool isSelectable,
    int index,
    bool isSelectedDay,
    bool isToday,
    bool isPrevMonthDay,
    TextStyle? textStyle,
    TextStyle defaultTextStyle,
    bool isNextMonthDay,
    bool isThisMonthDay,
    DateTime now,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Row(
        crossAxisAlignment: widget.dayCrossAxisAlignment,
        mainAxisAlignment: widget.dayMainAxisAlignment,
        children: <Widget>[
          DefaultTextStyle(
            style: getDefaultDayStyle(
                isSelectable,
                index,
                isSelectedDay,
                isToday,
                isPrevMonthDay,
                textStyle,
                defaultTextStyle,
                isNextMonthDay,
                isThisMonthDay),
            child: Text(
              '${now.day}',
              semanticsLabel: now.day.toString(),
              style: getDayStyle(
                  isSelectable,
                  index,
                  isSelectedDay,
                  isToday,
                  isPrevMonthDay,
                  textStyle,
                  defaultTextStyle,
                  isNextMonthDay,
                  isThisMonthDay,
                  now),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget renderDay(
    List<Week>? weekList,
    bool isSelectable,
    int index,
    bool isSelectedDay,
    bool isToday,
    bool isPrevMonthDay,
    TextStyle? textStyle,
    TextStyle defaultTextStyle,
    bool isNextMonthDay,
    bool isThisMonthDay,
    DateTime now,
  ) {
    final markedDatesMap = widget.markedDatesMap;
    bool isMarkedDateMap = false;
    if (markedDatesMap != null && markedDatesMap.length > 0) {
      markedDatesMap.forEach((element) {
        if (element.day == now.day &&
            element.month == now.month &&
            element.year == now.year) {
          //TODO: review this rule
          // isMarkedDateMap = true;
        }
      });
    }
    Color todayBorderColor =
        isToday ? widget.todayBorderColor : Colors.transparent;
    double todayBorderWidth = isToday ? 1 : 0;

    BoxDecoration mDecoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          width: todayBorderWidth,
          color: todayBorderColor,
        ),
        color:
            isSelectedDay ? widget.selectedDayButtonColor : Colors.transparent);

    Color markedWeekDayBorderColor = isToday
        ? widget.todayBorderColor
        : (widget.markedWeekColor ?? Colors.transparent);

    if (weekList != null) {
      for (Week week in weekList) {
        for (DateTime element in week.days) {
          if (now.day == element.day &&
              now.month == element.month &&
              now.year == element.year) {
            switch (now.weekday) {
              case 7:
                mDecoration = BoxDecoration(
                    border: Border.all(
                        width: todayBorderWidth,
                        color: markedWeekDayBorderColor),
                    color: isSelectedDay
                        ? widget.selectedDayButtonColor
                        : widget.markedWeekColor,
                    borderRadius: new BorderRadius.only(
                        bottomLeft: const Radius.circular(12.0),
                        topLeft: const Radius.circular(12.0)));
                break;
              case 6:
                mDecoration = BoxDecoration(
                    border: Border.all(
                        width: todayBorderWidth,
                        color: markedWeekDayBorderColor),
                    color: isSelectedDay
                        ? widget.selectedDayButtonColor
                        : widget.markedWeekColor,
                    borderRadius: new BorderRadius.only(
                        bottomRight: const Radius.circular(12.0),
                        topRight: const Radius.circular(12.0)));
                break;
              default:
                mDecoration = BoxDecoration(
                    border: Border.all(
                        width: todayBorderWidth,
                        color: markedWeekDayBorderColor),
                    color: isSelectedDay
                        ? widget.selectedDayButtonColor
                        : widget.markedWeekColor);
            }
          }
        }
      }
    }

    if (markedDatesMap != null) {
      markedDatesMap.forEach((element) {
        if (element.day == now.day &&
            element.month == now.month &&
            element.year == now.year) {
          mDecoration = BoxDecoration(
              border: Border.all(
                  width: todayBorderWidth, color: markedWeekDayBorderColor),
              color: isSelectedDay
                  ? widget.selectedDayButtonColor
                  : widget.markedWeekColor,
              borderRadius: new BorderRadius.circular(8));
        }
      });
    }

    final horizontalPadding =
        EdgeInsets.symmetric(horizontal: 2, vertical: 5.0);

    const mPadding = EdgeInsets.symmetric(horizontal: 0, vertical: 5.0);

    return Padding(
      padding: markedDatesMap != null && markedDatesMap.isNotEmpty
          ? horizontalPadding
          : mPadding,
      child: GestureDetector(
        onLongPress: () => _onDayLongPressed(now),
        child: Container(
          decoration: mDecoration,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _onDayPressed(now),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              child: getDayContainer(
                  isSelectable,
                  index,
                  isSelectedDay,
                  isToday,
                  isPrevMonthDay,
                  textStyle,
                  defaultTextStyle,
                  isNextMonthDay,
                  isThisMonthDay,
                  now),
            ),
          ),
        ),
      ),
    );
  }

  Widget builder(int slideIndex) {
    _startWeekday = _dates[slideIndex].weekday - firstDayOfWeek;
    if (_startWeekday == 7) {
      _startWeekday = 0;
    }
    _endWeekday =
        DateTime(_dates[slideIndex].year, _dates[slideIndex].month + 1, 1)
                .weekday -
            firstDayOfWeek;
    int totalItemCount = widget.staticSixWeekFormat
        ? 42
        : DateTime(
              _dates[slideIndex].year,
              _dates[slideIndex].month + 1,
              0,
            ).day +
            _startWeekday +
            (7 - _endWeekday);
    int year = _dates[slideIndex].year;
    int month = _dates[slideIndex].month;

    return Stack(
      children: <Widget>[
        Positioned(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 7,
              childAspectRatio: widget.childAspectRatio,
              children: List.generate(totalItemCount, (index) {
                this.totalItemCount = totalItemCount;

                final selectedDateTime = widget.selectedDateTime;

                bool isToday =
                    DateTime.now().day == index + 1 - _startWeekday &&
                        DateTime.now().month == month &&
                        DateTime.now().year == year;

                bool isPrevMonthDay = index < _startWeekday;
                bool isNextMonthDay =
                    index >= (DateTime(year, month, 0).day) + _startWeekday;

                int currentYear = year;
                int currentMonth = month;
                int currentDay = index + 1 - _startWeekday;
                int lastMonthDay = DateTime(year, month + 1, 0).day;

                if (currentDay < 1 || currentDay > lastMonthDay) {
                  if (currentDay < 1) {
                    currentMonth--;
                    if (currentMonth < 1) {
                      currentYear--;
                      currentMonth = 12;
                    }
                    lastMonthDay = DateTime(year, currentMonth + 1, 0).day;
                    currentDay = lastMonthDay + currentDay;
                  }

                  if (currentDay > lastMonthDay) {
                    currentMonth++;
                    if (currentMonth > 12) {
                      currentYear++;
                      currentMonth = 1;
                    }
                    currentDay = currentDay - lastMonthDay;
                    lastMonthDay = DateTime(year, currentMonth + 1, 0).day;
                  }
                }

                bool isSelectedDay = selectedDateTime != null &&
                    selectedDateTime.year == currentYear &&
                    selectedDateTime.month == currentMonth &&
                    selectedDateTime.day == currentDay;

                bool isThisMonthDay = !isPrevMonthDay && !isNextMonthDay;

                DateTime now = DateTime(year, month, 1);
                TextStyle? textStyle;
                TextStyle defaultTextStyle;
                if (isPrevMonthDay && !widget.showOnlyCurrentMonthDate) {
                  now = now.subtract(Duration(days: _startWeekday - index));
                  textStyle = widget.prevDaysTextStyle;
                  defaultTextStyle = defaultPrevDaysTextStyle;
                } else if (isThisMonthDay) {
                  now = DateTime(year, month, index + 1 - _startWeekday);
                  textStyle = isSelectedDay
                      ? widget.selectedDayTextStyle
                      : isToday
                          ? widget.todayTextStyle
                          : widget.daysTextStyle;
                  defaultTextStyle = isSelectedDay
                      ? defaultSelectedDayTextStyle
                      : isToday
                          ? defaultTodayTextStyle
                          : defaultDaysTextStyle;
                } else if (!widget.showOnlyCurrentMonthDate) {
                  now = DateTime(year, month, index + 1 - _startWeekday);
                  textStyle = widget.nextDaysTextStyle;
                  defaultTextStyle = defaultNextDaysTextStyle;
                } else {
                  return Container();
                }
                bool isSelectable = true;
                if (now.millisecondsSinceEpoch < minDate.millisecondsSinceEpoch)
                  isSelectable = false;
                else if (now.millisecondsSinceEpoch >
                    maxDate.millisecondsSinceEpoch) isSelectable = false;
                return renderDay(
                    widget.completedWeeks,
                    isSelectable,
                    index,
                    isSelectedDay,
                    isToday,
                    isPrevMonthDay,
                    textStyle,
                    defaultTextStyle,
                    isNextMonthDay,
                    isThisMonthDay,
                    now);
              }),
            ),
          ),
        ),
      ],
    );
  }

  AnimatedBuilder weekBuilder(int slideIndex) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<DateTime> weekDays = _weeks[slideIndex];

    weekDays = weekDays
        .map((weekDay) => weekDay.add(Duration(days: firstDayOfWeek)))
        .toList();

    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double value = 1.0;
          if (_controller.position.haveDimensions) {
            value = _controller.page! - slideIndex;
            value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
          }

          return Center(
            child: SizedBox(
              height: Curves.easeOut.transform(value) * widget.height,
              width: Curves.easeOut.transform(value) * screenWidth,
              child: child,
            ),
          );
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: GridView.count(
                  physics: widget.customGridViewPhysics,
                  crossAxisCount: 7,
                  childAspectRatio: widget.childAspectRatio,
                  padding: EdgeInsets.zero,
                  children: List.generate(weekDays.length, (index) {
                    /// last day of month + weekday
                    bool isToday = weekDays[index].day == DateTime.now().day &&
                        weekDays[index].month == DateTime.now().month &&
                        weekDays[index].year == DateTime.now().year;
                    bool isSelectedDay =
                        this._selectedDate.year == weekDays[index].year &&
                            this._selectedDate.month == weekDays[index].month &&
                            this._selectedDate.day == weekDays[index].day;
                    bool isPrevMonthDay =
                        weekDays[index].month < this._targetDate.month;
                    bool isNextMonthDay =
                        weekDays[index].month > this._targetDate.month;
                    bool isThisMonthDay = !isPrevMonthDay && !isNextMonthDay;

                    DateTime now = DateTime(weekDays[index].year,
                        weekDays[index].month, weekDays[index].day);
                    TextStyle? textStyle;
                    TextStyle defaultTextStyle;
                    if (isPrevMonthDay && !widget.showOnlyCurrentMonthDate) {
                      textStyle = widget.prevDaysTextStyle;
                      defaultTextStyle = defaultPrevDaysTextStyle;
                    } else if (isThisMonthDay) {
                      textStyle = isSelectedDay
                          ? widget.selectedDayTextStyle
                          : isToday
                              ? widget.todayTextStyle
                              : widget.daysTextStyle;
                      defaultTextStyle = isSelectedDay
                          ? defaultSelectedDayTextStyle
                          : isToday
                              ? defaultTodayTextStyle
                              : defaultDaysTextStyle;
                    } else if (!widget.showOnlyCurrentMonthDate) {
                      textStyle = widget.nextDaysTextStyle;
                      defaultTextStyle = defaultNextDaysTextStyle;
                    } else {
                      return Container();
                    }
                    bool isSelectable = true;
                    if (now.millisecondsSinceEpoch <
                        minDate.millisecondsSinceEpoch)
                      isSelectable = false;
                    else if (now.millisecondsSinceEpoch >
                        maxDate.millisecondsSinceEpoch) isSelectable = false;
                    return renderDay([],
                        isSelectable,
                        index,
                        isSelectedDay,
                        isToday,
                        isPrevMonthDay,
                        textStyle,
                        defaultTextStyle,
                        isNextMonthDay,
                        isThisMonthDay,
                        now);
                  }),
                ),
              ),
            ),
          ],
        ));
  }

  List<DateTime> _getDaysInWeek([DateTime? selectedDate]) {
    if (selectedDate == null) selectedDate = new DateTime.now();

    var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDate);
    var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDate);

    return _daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
  }

  DateTime _firstDayOfWeek(DateTime date) {
    var day = _createUTCMiddayDateTime(date);
    return day.subtract(new Duration(days: date.weekday % 7));
  }

  DateTime _lastDayOfWeek(DateTime date) {
    var day = _createUTCMiddayDateTime(date);
    return day.add(new Duration(days: 7 - day.weekday % 7));
  }

  DateTime _createUTCMiddayDateTime(DateTime date) {
    // Magic const: 12 is to maintain compatibility with date_utils
    return new DateTime.utc(date.year, date.month, date.day, 12, 0, 0);
  }

  Iterable<DateTime> _daysInRange(DateTime start, DateTime end) {
    var offset = start.timeZoneOffset;

    return List<int>.generate(end.difference(start).inDays, (i) => i + 1)
        .map((int i) {
      var d = start.add(Duration(days: i - 1));

      var timeZoneDiff = d.timeZoneOffset - offset;
      if (timeZoneDiff.inSeconds != 0) {
        offset = d.timeZoneOffset;
        d = d.subtract(new Duration(seconds: timeZoneDiff.inSeconds));
      }
      return d;
    });
  }

  void _onDayLongPressed(DateTime picked) {
    widget.onDayLongPressed?.call(picked);
  }

  void _onDayPressed(DateTime picked) {
    _selectedDate = picked;
    widget.onDayPressed?.call(picked, widget.markedDatesMap ?? const []);
  }

  Future<Null> _selectDateFromPicker() async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (selected != null) {
      // updating selected date range based on selected week
      setState(() {
        _selectedDate = selected;
      });
      widget.onDayPressed?.call(selected, widget.markedDatesMap ?? const []);
    }
  }

  void _setDatesAndWeeks() {
    /// Setup default calendar format
    List<DateTime> date = [];
    int currentDateIndex = 0;
    for (int _cnt = 0;
        0 >=
            DateTime(minDate.year, minDate.month + _cnt)
                .difference(DateTime(maxDate.year, maxDate.month))
                .inDays;
        _cnt++) {
      date.add(DateTime(minDate.year, minDate.month + _cnt, 1));
      if (0 ==
          date.last
              .difference(
                  DateTime(this._targetDate.year, this._targetDate.month))
              .inDays) {
        currentDateIndex = _cnt;
      }
    }

    /// Setup week-only format
    List<List<DateTime>> week = [];
    for (int _cnt = 0;
        0 >=
            minDate
                .add(Duration(days: 7 * _cnt))
                .difference(maxDate.add(Duration(days: 7)))
                .inDays;
        _cnt++) {
      week.add(_getDaysInWeek(minDate.add(new Duration(days: 7 * _cnt))));
    }

    _startWeekday = date[currentDateIndex].weekday - firstDayOfWeek;
    /*if (widget.showOnlyCurrentMonthDate) {
      _startWeekday--;
    }*/
    if (/*widget.showOnlyCurrentMonthDate && */ _startWeekday == 7) {
      _startWeekday = 0;
    }
    _endWeekday = DateTime(date[currentDateIndex].year,
                date[currentDateIndex].month + 1, 1)
            .weekday -
        firstDayOfWeek;
    this._dates = date;
    this._weeks = week;
//        this._selectedDate = widget.selectedDateTime != null
//            ? widget.selectedDateTime
//            : DateTime.now();
  }

  void _setDate([int page = -1]) {
    if (page == -1) {
      _setDatesAndWeeks();
    } else {
      if (widget.weekFormat) {
        this._pageNum = page;
        this._targetDate = this._weeks[page].first;

        _controller.animateToPage(page,
            duration: Duration(milliseconds: 1), curve: Threshold(0.0));
      } else {
        setState(() {
          this._pageNum = page;
          this._targetDate = this._dates[page];
          _startWeekday = _dates[page].weekday - firstDayOfWeek;
          _endWeekday = _lastDayOfWeek(_dates[page]).weekday - firstDayOfWeek;
          _controller.animateToPage(page,
              duration: Duration(milliseconds: 1), curve: Threshold(0.0));
        });
      }

      //call callback
      final onCalendarChanged = widget.onCalendarChanged;
      if (onCalendarChanged != null) {
        onCalendarChanged(
            !widget.weekFormat
                ? this._dates[page]
                : this._weeks[page][firstDayOfWeek],
            widget.staticSixWeekFormat
                ? 42
                : DateTime(
                      _dates[_pageNum].year,
                      _dates[_pageNum].month + 1,
                      0,
                    ).day +
                    _startWeekday +
                    (7 - _endWeekday));
      }
    }
  }

  TextStyle getDefaultDayStyle(
    bool isSelectable,
    int index,
    bool isSelectedDay,
    bool isToday,
    bool isPrevMonthDay,
    TextStyle? textStyle,
    TextStyle defaultTextStyle,
    bool isNextMonthDay,
    bool isThisMonthDay,
  ) {
    return !isSelectable
        ? defaultInactiveDaysTextStyle
        : (_localeDate.dateSymbols.WEEKENDRANGE
                    .contains((index - 1 + firstDayOfWeek) % 7)) &&
                !isSelectedDay &&
                !isToday
            ? (isPrevMonthDay
                ? defaultPrevDaysTextStyle
                : isNextMonthDay
                    ? defaultNextDaysTextStyle
                    : isSelectable
                        ? defaultWeekendTextStyle
                        : defaultInactiveWeekendTextStyle)
            : isToday
                ? defaultTodayTextStyle
                : isSelectable && textStyle != null
                    ? textStyle
                    : defaultTextStyle;
  }

  TextStyle? getDayStyle(
      bool isSelectable,
      int index,
      bool isSelectedDay,
      bool isToday,
      bool isPrevMonthDay,
      TextStyle? textStyle,
      TextStyle defaultTextStyle,
      bool isNextMonthDay,
      bool isThisMonthDay,
      DateTime now) {
    // If day is in multiple selection get its style(if available)
    bool isMultipleMarked = widget.multipleMarkedDates?.isMarked(now) ?? false;
    TextStyle? mutipleMarkedTextStyle =
        widget.multipleMarkedDates?.getTextStyle(now);

    return isSelectedDay && widget.selectedDayTextStyle != null
        ? widget.selectedDayTextStyle
        : isMultipleMarked
            ? mutipleMarkedTextStyle
            : (_localeDate.dateSymbols.WEEKENDRANGE
                        .contains((index - 1 + firstDayOfWeek) % 7)) &&
                    !isSelectedDay &&
                    isThisMonthDay &&
                    !isToday
                ? (isSelectable
                    ? widget.weekendTextStyle
                    : widget.inactiveWeekendTextStyle)
                : !isSelectable
                    ? widget.inactiveDaysTextStyle
                    : isPrevMonthDay
                        ? widget.prevDaysTextStyle
                        : isNextMonthDay
                            ? widget.nextDaysTextStyle
                            : isToday
                                ? widget.todayTextStyle
                                : widget.daysTextStyle;
  }

  Widget getDayContainer(
      bool isSelectable,
      int index,
      bool isSelectedDay,
      bool isToday,
      bool isPrevMonthDay,
      TextStyle? textStyle,
      TextStyle defaultTextStyle,
      bool isNextMonthDay,
      bool isThisMonthDay,
      DateTime now) {
    final customDayBuilder = widget.customDayBuilder;

    Widget? dayContainer;
    if (customDayBuilder != null) {
      final appTextStyle = DefaultTextStyle.of(context).style;

      final dayStyle = getDayStyle(
        isSelectable,
        index,
        isSelectedDay,
        isToday,
        isPrevMonthDay,
        textStyle,
        defaultTextStyle,
        isNextMonthDay,
        isThisMonthDay,
        now,
      );

      final styleForBuilder = appTextStyle.merge(dayStyle);

      dayContainer = customDayBuilder(
          isSelectable,
          index,
          isSelectedDay,
          isToday,
          isPrevMonthDay,
          styleForBuilder,
          isNextMonthDay,
          isThisMonthDay,
          now);
    }

    return dayContainer ??
        getDefaultDayContainer(
          isSelectable,
          index,
          isSelectedDay,
          isToday,
          isPrevMonthDay,
          textStyle,
          defaultTextStyle,
          isNextMonthDay,
          isThisMonthDay,
          now,
        );
  }
}
