import 'package:flutter/material.dart';
import 'package:pichint/models/photo_model.dart';

class DataProvider extends InheritedWidget {
  const DataProvider({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final List<PhotoData> data;

  static DataProvider of(BuildContext context) {
    final DataProvider? result =
        context.dependOnInheritedWidgetOfExactType<DataProvider>();
    // assert(result != null, 'No DataProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DataProvider old) => data != old.data;
}
