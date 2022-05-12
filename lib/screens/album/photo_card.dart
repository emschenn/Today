import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pichint/config/icons.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/photo/photo_screen.dart';
import 'package:pichint/services/firebase_service.dart';
import 'package:pichint/services/api_service.dart';

class PhotoCard extends StatefulWidget {
  final PhotoData photo;

  const PhotoCard({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  late String imgPath;

  @override
  void initState() {
    super.initState();
    imgPath = '${ApiService().baseUrl}/img/${widget.photo.filename!}';
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var borderRadius = 6.0;

    return MediaQuery(
        data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
            .copyWith(boldText: false),
        child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade,
                  duration: const Duration(milliseconds: 200),
                  reverseDuration: const Duration(milliseconds: 250),
                  child: PhotoScreen(photo: widget.photo),
                ),
              );
            },
            child: Card(
              elevation: 2,
              shadowColor: Theme.of(context).primaryColorLight.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Column(
                children: [
                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(borderRadius),
                          bottom: widget.photo.description!.isEmpty
                              ? Radius.circular(borderRadius)
                              : const Radius.circular(0)),
                      child: Hero(
                          tag: widget.photo.pid!,
                          child: Image.network(
                            imgPath,
                            height: size.width * 0.45,
                            width: size.width * 0.5,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return SizedBox(
                                  height: size.width * 0.45,
                                  child: BlurHash(
                                      imageFit: BoxFit.fill,
                                      hash: widget.photo.blurHash!));
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              Widget showWidget;
                              if (loadingProgress == null) {
                                showWidget = child;
                              } else {
                                showWidget = SizedBox(
                                    height: size.width * 0.45,
                                    child: BlurHash(
                                        imageFit: BoxFit.fill,
                                        hash: widget.photo.blurHash!));
                              }
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: showWidget,
                              );
                            },
                          )),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10))),
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                        child: FutureBuilder(
                          initialData: '',
                          future: FirebaseService()
                              .getUserName(widget.photo.authorId),
                          builder: (context, snapshot) {
                            return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Transform.translate(
                                      offset: const Offset(0.0, 1),
                                      child: const Icon(
                                        CustomIcon.user,
                                        size: 12,
                                      )),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    snapshot.data.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .merge(const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  )
                                ]);
                          },
                        ),
                      ),
                    )
                  ]),
                  if (widget.photo.description!.isNotEmpty)
                    Container(
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                        child: Text(
                          widget.photo.description!,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .merge(const TextStyle(color: Colors.black87)),
                        )),
                ],
              ),
            )));
  }
}
