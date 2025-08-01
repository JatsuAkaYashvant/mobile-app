import 'package:flutter/material.dart';

class CVTheme {
  CVTheme._();

  static Color textFieldLabelColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[600]!;
  }

  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color primaryHeading(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? CVTheme.primaryColor
        : Colors.black;
  }

  static Color boxBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? CVTheme.bgCardDark
        : CVTheme.bgCard;
  }

  static Color boxShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? CVTheme.bgCardDark
        : CVTheme.grey;
  }

  static Color appBarText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? CVTheme.primaryColor
        : Colors.black;
  }

  static Color drawerIcon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? CVTheme.primaryColor
        : Colors.black;
  }

  static Color highlightText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? CVTheme.primaryColor
        : CVTheme.primaryColorDark;
  }

  static ThemeData themeData(BuildContext context) {
    return ThemeData(
      brightness: Theme.of(context).brightness,
      colorScheme: ThemeData().colorScheme.copyWith(
        brightness: Theme.of(context).brightness,
        primary: CVTheme.secondaryColor,
      ),
    );
  }

  static const Color primaryColor = Color.fromRGBO(66, 185, 131, 1);
  static const Color primaryColorDark = Color.fromRGBO(2, 110, 87, 1);
  static const Color primaryColorLight = Color.fromRGBO(66, 185, 131, 0.5);
  static const Color primaryColorShadow = Color.fromRGBO(245, 255, 252, 1);
  static const Color imageBackground = Color.fromRGBO(63, 61, 86, 1);
  static const Color secondaryColor = Color.fromRGBO(33, 33, 33, 1);
  static const Color blue = Color.fromRGBO(66, 185, 182, 1);
  static const Color red = Color.fromRGBO(255, 89, 89, 1);
  static const Color grey = Color.fromRGBO(150, 150, 150, 1);
  static const Color lightGrey = Color.fromRGBO(150, 150, 150, 0.5);
  static const Color bgCard = Color.fromRGBO(255, 255, 255, 0.9);
  static const Color bgCardDark = Color.fromRGBO(97, 97, 97, 1);
  static const Color htmlEditorBg = Color.fromRGBO(245, 245, 245, 1);

  static const OutlineInputBorder primaryDarkOutlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: CVTheme.primaryColorDark),
  );

  static const OutlineInputBorder redOutlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: CVTheme.red),
  );

  static const InputDecoration textFieldDecoration = InputDecoration(
    contentPadding: EdgeInsetsDirectional.all(8),
    focusedBorder: CVTheme.primaryDarkOutlineBorder,
    enabledBorder: CVTheme.primaryDarkOutlineBorder,
    errorBorder: CVTheme.redOutlineBorder,
    focusedErrorBorder: CVTheme.redOutlineBorder,
  );
}
