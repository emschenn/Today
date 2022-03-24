import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    return Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.fromLTRB(20, 30, 10, 4),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formattedDateTime(date),
              style: const TextStyle(
                  fontFamily: 'LeagueSpartan',
                  fontSize: 24,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w300),
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
                  fontWeight: FontWeight.w200),
            )
          ],
        ));
    // textAlign: TextAlign.left,
    // style: GoogleFonts.getFont('League Spartan')));
  }
}
