import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:pichint/widgets/custom_appbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: '設定',
            action: TextButton(
                child: Text('完成',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
                onPressed: () {
                  Navigator.pop(context);
                }),
            leading: TextButton(
                child: Text('取消',
                    style:
                        TextStyle(color: Theme.of(context).primaryColorDark)),
                onPressed: () {
                  Navigator.pop(context);
                })),
        body: Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: BlurHash(hash: "LAIX?C?fNVgi5m_1NLRW4m-;_4IA"),
                ),
                AspectRatio(
                  aspectRatio: 1.6,
                  child: BlurHash(hash: "LAIX?C?fNVgi5m_1NLRW4m-;_4IA"),
                ),
                Text('設定通知頻率',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
              ],
            )));
  }
}
