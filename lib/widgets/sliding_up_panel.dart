import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CustomSlidingUpPanel extends StatelessWidget {
  final PanelController panelController;
  final Widget content;

  const CustomSlidingUpPanel(
      {Key? key, required this.panelController, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SlidingUpPanel(
      controller: panelController,
      panelSnapping: false,
      backdropOpacity: 0.5,
      backdropColor: Colors.black,
      backdropEnabled: true,
      minHeight: 0,
      maxHeight: size.height * 0.88,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      panel: content,
      onPanelClosed: () {
        print('close');
      },
    );
  }
}
