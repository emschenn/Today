import 'package:flutter/material.dart';

import '../config/icons.dart';
import '../models/photo_model.dart';
import '../widgets/custom_button.dart';

class PhotoScreen extends StatelessWidget {
  final PhotoData photo;
  final Image image;

  const PhotoScreen({Key? key, required this.photo, required this.image})
      : super(key: key);

  String formattedDateTime(dateTime) {
    var month =
        dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
    var date = dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();
    return "${dateTime.year}.$month.$date";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(children: [
      Positioned(
          child: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            child: Column(
              children: [
                image,
                Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              CustomIcon.user,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              photo.author!,
                              strutStyle: const StrutStyle(
                                height: 1.5,
                              ),
                              style: const TextStyle(
                                  fontFamily: 'LeagueSpartan',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        Text(
                          formattedDateTime(photo.date!),
                          strutStyle: const StrutStyle(
                            height: 1.5,
                          ),
                          style: const TextStyle(
                              fontFamily: 'LeagueSpartan',
                              fontSize: 14,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w200),
                        )
                      ],
                    )),
                Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      photo.description!,
                      style: const TextStyle(
                          fontFamily: 'LeagueSpartan',
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    )),
              ],
            )),
      )),
      Positioned(
          bottom: 0.0,
          child: Container(
            width: size.width,
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 30.0, 20.0),
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton(
                    color: Theme.of(context).primaryColorLight,
                    text: '我想多看到此類內容',
                    textColor: Colors.black,
                    onClick: () {},
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Icon(
                    CustomIcon.export_icon,
                  ),
                ]),
          ))
    ]);
  }
}
