import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/src/string_extension.dart';
import 'package:intl/intl.dart';

class CalendarCarouselHeader extends StatefulWidget {
  CalendarCarouselHeader({required this.pageChangeListener,
    required this.dates,
    required this.selectedIndex,
    required this.selectedDateColor,
    required this.selectedDateTextStyle,
    required this.nextAndPrevTextStyle});

  final Color selectedDateColor;
  final TextStyle selectedDateTextStyle;
  final TextStyle nextAndPrevTextStyle;
  final List<DateTime> dates;
  final Function pageChangeListener;
  final int selectedIndex;

  @override
  State<CalendarCarouselHeader> createState() => _CalendarCarouselHeaderState();
}

class _CalendarCarouselHeaderState extends State<CalendarCarouselHeader>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _animation =
  Tween(begin: 0.0, end: 1.0).animate(_controller);

  PageController? mPagerController;

  @override
  void initState() {
    mPagerController = new PageController(
        initialPage: widget.selectedIndex, viewportFraction: 0.35);
    super.initState();
  }

  @override
  void dispose() {
    mPagerController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarCarouselHeader oldWidget) {
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      mPagerController?.animateToPage(widget.selectedIndex,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: 40,
      child: Stack(
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 5),
              width: 170,
              height: 35,
              decoration: BoxDecoration(
                color: widget.selectedDateColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          PageView.builder(
              controller: mPagerController,
              onPageChanged: (selectedIndex) {
                if (selectedIndex != widget.selectedIndex) {
                  widget.pageChangeListener(selectedIndex);
                }
              },
              itemCount: widget.dates.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final isSelectedIndex = index == widget.selectedIndex;
                final String defaultLocale = Platform.localeName;
                String formattedDate =
                '${DateFormat.MMM(defaultLocale).format(widget.dates[index])}'
                    .capitalize();
                if (isSelectedIndex) {
                  formattedDate =
                      '${DateFormat.MMMM(defaultLocale).format(
                          widget.dates[index])} ${widget.dates[index].year}'
                          .capitalize();
                }
                if (isSelectedIndex) {
                  _controller.forward(from: 0.0);
                  return Center(
                    child: FadeTransition(
                      opacity: _animation,
                      child: selectedDateHeader(formattedDate),
                    ),
                  );
                }

                return GestureDetector(
                    onTap: () {
                      setState(() {
                        int indexToGo = widget.selectedIndex;
                        if (index < widget.selectedIndex) {
                          indexToGo = widget.selectedIndex - 1;
                        } else {
                          indexToGo = widget.selectedIndex + 1;
                        }

                        mPagerController?.animateToPage(indexToGo,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      });
                    },
                    child: notSelectedDateHeader(formattedDate));
              }),
        ],
      ),
    );
  }

  Widget selectedDateHeader(String formattedDate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Center(
        child: Text(
          formattedDate,
          style: widget.selectedDateTextStyle,
        ),
      ),
    );
  }

  Widget notSelectedDateHeader(String date) {
    return Center(
      child: Text(
        date,
        style: widget.nextAndPrevTextStyle,
      ),
    );
  }
}
