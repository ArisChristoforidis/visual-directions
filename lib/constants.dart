import 'package:flutter/material.dart';

class Constants {
  static const double panelPadding = 16;
  static const EdgeInsets sidePanelPadding = EdgeInsets.only(left: panelPadding, right: panelPadding / 2, top: panelPadding, bottom: panelPadding);
  static const EdgeInsets mainPanelPadding = EdgeInsets.only(left: panelPadding / 2, right: panelPadding, top: panelPadding, bottom: panelPadding);

  static BorderRadius panelBorderRadius = BorderRadius.circular(8.0);
  static const EdgeInsets sidePanelElementPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
}
