import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/api_service.dart';

class PhotosGridView extends StatelessWidget {
  final List<PhotoData> photos;
  final PanelController panelController;
  final Function setPhotoData;

  const PhotosGridView(
      {Key? key,
      required this.photos,
      required this.panelController,
      required this.setPhotoData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      primary: false,
      shrinkWrap: true,
      itemCount: photos.length,
      padding: const EdgeInsets.symmetric(vertical: 0),
      itemBuilder: (context, index) {
        return PhotoCard(
            panelController: panelController,
            setPhotoData: setPhotoData,
            photo: photos[index]);
      },
      staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
    );
  }
}

class PhotoCard extends StatefulWidget {
  final PhotoData photo;
  final PanelController panelController;
  final Function setPhotoData;

  const PhotoCard(
      {Key? key,
      required this.photo,
      required this.panelController,
      required this.setPhotoData})
      : super(key: key);

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  Widget img = const CircularProgressIndicator(
    backgroundColor: Color(0xFFE3DFCC),
    valueColor: AlwaysStoppedAnimation(Color(0xFF6093AF)),
  );
  ApiService apiHandler = ApiService();

  @override
  void initState() {
    loadImgData();
    super.initState();
  }

  loadImgData() async {
    var t = await apiHandler.getImage(widget.photo.path!);
    setState(() {
      img = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius = 6.0;

    return InkWell(
        onTap: () {
          widget.setPhotoData(widget.photo, img);
          widget.panelController.open();
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
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: img,
              ),
            ],
          ),
        ));
  }
}
