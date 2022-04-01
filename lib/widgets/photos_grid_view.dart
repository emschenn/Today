import 'dart:typed_data';

import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/photo/photo_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/api_service.dart';

class PhotosGridView extends StatelessWidget {
  final List<PhotoData> photos;

  const PhotosGridView({
    Key? key,
    required this.photos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      primary: false,
      shrinkWrap: true,
      itemCount: photos.length,
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemBuilder: (context, index) {
        return PhotoCard(photo: photos[index]);
      },
      staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
    );
  }
}

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
          elevation: 5,
          shadowColor: Theme.of(context).primaryColorLight.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(borderRadius)),
                child: Hero(
                    tag: widget.photo.pid!,
                    child:
                        // SizedBox(
                        //   width: 200,
                        //   height: 200,
                        //   // aspectRatio: 1.6,
                        //   child: BlurHash(
                        //       imageFit: BoxFit.fill,
                        //       hash: "LAIX?C?fNVgi5m_1NLRW4m-;_4IA",
                        //       image: imgPath),
                        // ),
                        Image.network(imgPath)),
              ),
              Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
                  child: Text(
                    '${widget.photo.author!}',
                    style: Theme.of(context).textTheme.caption!.merge(
                        const TextStyle(color: Colors.black87, fontSize: 11)),
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                  child: Text(
                    widget.photo.description!.length > 10
                        ? widget.photo.description!.substring(0, 10)
                        : widget.photo.description!,
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
