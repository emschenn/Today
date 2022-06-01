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

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
  }

  List<PhotoData> _searchPhotoData(query, photos) {
    print(query);
    print(photos);
    List<PhotoData> results = [];
    photos.forEach((PhotoData photo) {
      var month = photo.date!.month;
      var day = photo.date!.day;
      if (query.length <= 2) {
        if (month == int.parse(query)) {
          results.add(photo);
        }
      } else if (query.length == 4) {
        if (month == int.parse(query.substring(0, 2)) &&
            day == int.parse(query.substring(2))) {
          results.add(photo);
        }
      }
    });
    return results;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (widget.query == '') {
      return MediaQuery(
          data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
              .copyWith(boldText: false),
          child: Center(
              child: SingleChildScrollView(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/search.png', width: size.width * 0.7),
              Text('搜尋特定日期或月份的照片',
                  style: Theme.of(context).textTheme.bodyText2),
              const SizedBox(
                height: 6,
              ),
              Text('搜尋格式範例：5月→05\n5月21日→0521',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption),
              SizedBox(
                height: 10 + AppBar().preferredSize.height,
              )
            ],
          ))));
    }
    return Consumer<AlbumModel>(builder: (context, model, child) {
      if (model.photos == null) {
        return const Center(
            child: SpinKitThreeBounce(
          color: Colors.black45,
          size: 30.0,
        ));
      }
      if (model.photos!.isNotEmpty) {
        var result = _searchPhotoData(widget.query, model.photos);
        if (result.isEmpty) {
          return MediaQuery(
              data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window)
                  .copyWith(boldText: false),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/empty.png', width: size.width * 0.6),
                  Text('查無符合搜尋日期的照片',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2),
                  const SizedBox(
                    height: 6,
                  ),
                  Text('請嘗試別的日期，搜尋格式範例：\n5月→05、5月21日→0521',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.caption),
                  SizedBox(
                    height: 10 + AppBar().preferredSize.height,
                  )
                ],
              )));
        }
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
            SizedBox(
              height: 10 + AppBar().preferredSize.height,
            )
          ],
        ));
      }
    });
  }

  // @override
  // bool get wantKeepAlive => true;
}
