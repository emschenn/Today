import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/timeline/photo_card.dart';

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
