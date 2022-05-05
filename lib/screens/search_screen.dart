import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pichint/models/album_model.dart';
import 'package:pichint/models/photo_model.dart';
import 'package:pichint/screens/album/photos_grid_view.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  String query;
  SearchScreen({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  List<PhotoData> _searchPhotoData(query, photos) {
    print(query);
    return [];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (widget.query == '') {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/search.png', width: size.width * 0.7),
          Text('搜尋照片', style: Theme.of(context).textTheme.bodyText2),
          const SizedBox(
            height: 10,
          ),
          Text('在搜尋列搜尋照片',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption),
          SizedBox(
            height: AppBar().preferredSize.height,
          )
        ],
      ));
    }
    return Consumer<AlbumModel>(builder: (context, model, child) {
      _searchPhotoData(widget.query, model.photos);
      if (model.photos == null) {
        return const Center(
            child: SpinKitThreeBounce(
          color: Colors.black45,
          size: 30.0,
        ));
      }
      if (model.photos!.isNotEmpty) {
        var result = _searchPhotoData(widget.query, model.photos);
        return SingleChildScrollView(
            child: PhotosGridView(
          photos: result,
        ));
      } else {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/empty.png', width: size.width * 0.6),
            Text('目前尚未分享任何照片', style: Theme.of(context).textTheme.bodyText2),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: AppBar().preferredSize.height,
            )
          ],
        ));
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}
