import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

extension DateUtils on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }
}

class DateText extends StatelessWidget {
  final DateTime date;
  const DateText({Key? key, required this.date}) : super(key: key);

  String formattedDateTime(dateTime) {
    var month =
        dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
    var date = dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();
    return "$month.$date";
  }

  String getDay(dateTime) {
    var day = DateFormat('EEEE').format(dateTime).substring(0, 3).toUpperCase();
    return day;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .copyWith(boldText: false),
        child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.fromLTRB(20, 14, 10, 10),
            child: date.isToday
                ? const Text(
                    'Today',
                    style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontSize: 24,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500),
                  )
                : date.isYesterday
                    ? const Text(
                        'Yesterday',
                        style: TextStyle(
                            fontFamily: 'LeagueSpartan',
                            fontSize: 24,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w500),
                      )
                    : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            formattedDateTime(date),
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontSize: 24,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            '⎯ ' + getDay(date),
                            style: const TextStyle(
                                fontFamily: 'LeagueSpartan',
                                fontSize: 14,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      )));
  }
}
