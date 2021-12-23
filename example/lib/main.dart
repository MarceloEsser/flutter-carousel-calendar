import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/week.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:jiffy/jiffy.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'dooboolab flutter calendar',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Calendar Carousel Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<int> completedWeeks = [51, 50, 49];

  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _currentDate = DateTime(2019, 2, 3);
  DateTime _currentDate2 = DateTime(2019, 2, 3);
  List<Week> completedWeeks = [];
  String _currentMonth = DateFormat.yMMM().format(DateTime(2019, 2, 3));
  DateTime _targetDateTime = DateTime(2019, 2, 3);

//  List<DateTime> _markedDate = [DateTime(2018, 9, 20), DateTime(2018, 10, 11)];
  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Colors.amber,
    ),
  );

  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {
      new DateTime.now(): [
        new Event(
          date: DateTime.now(),
          title: 'Event 1',
          icon: _eventIcon,
          dot: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            color: Colors.red,
            height: 5.0,
            width: 5.0,
          ),
        ),
      ],
    },
  );

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  @override
  void initState() {
    super.initState();
    _currentDate2 = DateTime.now();
    widget.completedWeeks.forEach((element) {
      DateTime subtractedDateTime = Jiffy(DateTime.now())
          .subtract(weeks: weekNumber(DateTime.now()) - element)
          .dateTime;

      List<DateTime> days = [];

      days.add(subtractedDateTime);

      for (int i = 1; i <= subtractedDateTime.weekday;) {
        var date = subtractedDateTime.subtract(Duration(days: i));
        if (!days.contains(date)) days.add(date);
        i++;
      }

      int daysToAdd = 7 - subtractedDateTime.weekday;

      for (int add = 1; add < daysToAdd;) {
        var date = subtractedDateTime.add(Duration(days: add));
        if (!days.contains(date)) days.add(date);
        add++;
      }

      days.sort((a, b) => a.weekday.compareTo(b.weekday));
      completedWeeks.add(new Week(days, element));
    });
  }



  @override
  Widget build(BuildContext context) {

    final _calendarCarouselNoHeader = CalendarCarousel<Event>(
      markedDatesMap: _markedDateMap,
      todayBorderColor: Colors.deepOrange,
      todayButtonColor: Colors.amber,
      selectedDateTime: _currentDate2,
      completedWeeks: completedWeeks,
      weekDayFormat: WeekdayFormat.narrow,
      locale: Platform.localeName,
      selectedDayButtonColor: Colors.pink,
      selectedDayTextStyle: TextStyle(color: Colors.white),
      daysTextStyle: TextStyle(color: Colors.grey),
      weekendTextStyle: TextStyle(color: Colors.grey),
      dayButtonColor: Colors.limeAccent,
      onDayPressed: (date, events) {
        this.setState(() => _currentDate2 = date);
      },
      height: 550.0,
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.greenAccent,
            padding: EdgeInsets.only(bottom: 10),
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: _calendarCarouselNoHeader,
          ),
        ));
  }
}
