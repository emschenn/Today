import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pichint/services/api_service.dart';
import 'package:pichint/services/firebase_service.dart';

import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:pichint/models/user_model.dart';
import 'package:pichint/screens/photo/edit_panel.dart';
import 'package:pichint/services/global_service.dart';
import 'package:pichint/widgets/custom_appbar.dart';

import 'package:pichint/config/icons.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/widgets/custom_button.dart';

class PhotoScreen extends StatefulWidget {
  final PhotoData photo;
  const PhotoScreen({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late PanelController _actionPanelController;
  late UserData user;

  @override
  void initState() {
    user = GlobalService().getUserData;
    _actionPanelController = PanelController();
    super.initState();
  }

  String formattedDateTime(dateTime) {
    var month =
        dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
    var date = dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();
    var hour =
        dateTime.hour < 10 ? '0${dateTime.hour}' : dateTime.hour.toString();
    var minute = dateTime.minute < 10
        ? '0${dateTime.minute}'
        : dateTime.minute.toString();
    return " $month/$date @ $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SlidingUpPanel(
        backdropEnabled: true,
        renderPanelSheet: false,
        minHeight: 0,
        controller: _actionPanelController,
        panel: EditPanel(
            photo: widget.photo,
            user: user,
            closePanel: () {
              _actionPanelController.close();
            }),
        body: Scaffold(
            appBar: CustomAppBar(
                elevation: 0,
                action: IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      _actionPanelController.open();
                    }),
                leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
            backgroundColor: Colors.white,
            body: SafeArea(
                child: Stack(children: [
              Positioned.fill(
                  child: SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                    child: Column(
                      children: [
                        Hero(
                            tag: widget.photo.pid!,
                            child: Image.network(
                                '${ApiService().baseUrl}/img/${widget.photo.filename!}')),
                        Container(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 16.0),
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
                                    FutureBuilder(
                                      future: FirebaseService()
                                          .getUserName(widget.photo.authorId),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          strutStyle: const StrutStyle(
                                            height: 1.5,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  formattedDateTime(widget.photo.date!),
                                  // strutStyle: const StrutStyle(
                                  //   height: 1,
                                  // ),
                                  style: const TextStyle(
                                      fontFamily: 'LeagueSpartan',
                                      fontSize: 13,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w300),
                                )
                              ],
                            )),
                        Container(
                            alignment: Alignment.topLeft,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              widget.photo.description!,
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                      ],
                    )),
              )),
              Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 20.0),
                    color: Colors.white,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomButton(
                            width: 180,
                            color: Theme.of(context).primaryColorLight,
                            text: '我想多看到此類內容',
                            textColor: Colors.white,
                            onClick: () {},
                          ),
                          // const SizedBox(
                          //   width: 20,
                          // ),
                          // const Icon(
                          //   CustomIcon.export_icon,
                          // ),
                        ]),
                  )),
            ]))));
  }
}
