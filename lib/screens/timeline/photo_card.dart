import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:page_transition/page_transition.dart';

import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/photo/photo_screen.dart';

import '../../services/api_service.dart';

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

  // Future<String> blurHashEncode(path) async {
  //   ByteData bytes = await NetworkAssetBundle(Uri.parse(path)).load("");
  //   Uint8List pixels = bytes.buffer.asUint8List();
  //   String blurHash = await BlurHash.encode(pixels, 4, 3);
  //   return blurHash;
  // }

  // void getImage() async {
  //   String path = '${ApiService().baseUrl}/img/${widget.photo.filename!}';
  //   ByteData bytes = await NetworkAssetBundle(Uri.parse(path)).load("");
  //   Uint8List pixels = bytes.buffer.asUint8List();
  //   String blurHash = await BlurHash.encode(pixels, 4, 3);
  //   setState(() {
  //     imgPath = path;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var borderRadius = 6.0;

    return InkWell(
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
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                            height: 120,
                            child: BlurHash(
                                imageFit: BoxFit.fill,
                                hash: widget.photo.blurHash!));
                      },
                    )),
              ),
              // Container(
              //     alignment: Alignment.topLeft,
              //     padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              //     child: Text(
              //       '${widget.photo.author!}',
              //       style: Theme.of(context).textTheme.caption!.merge(
              //           const TextStyle(color: Colors.black87, fontSize: 11)),
              //     )),
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
        ));
  }
}
