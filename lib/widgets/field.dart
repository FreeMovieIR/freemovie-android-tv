import 'package:flutter/material.dart';

import '../gen/assets.gen.dart';

class Field extends StatelessWidget {
  final bool isFocused;
  final FocusNode focusNode;
  final int index;

  const Field({super.key, required this.isFocused, required this.focusNode, required this.index});

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      focusNode: focusNode,
      textDirection: TextDirection.rtl,
      // textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13),
      decoration: InputDecoration(
          prefixIcon: Assets.images.icons.searchIcon.svg(fit: BoxFit.scaleDown),
          // icon: Assets.images.icons.searchIcon.svg(width: 10, height: 10),
          constraints: BoxConstraints(minHeight: 24, minWidth: 280, maxHeight: 36, maxWidth: 280),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(9999)),
            borderSide: BorderSide(color: Color(0xFF314158)),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(9999)),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(9999)),
            borderSide: BorderSide(color: Color(0xFF314158)),
          ),
          hintText: 'اسم فیلم یا سریالی که دنبالشی رو بنویس',
          hintTextDirection: TextDirection.rtl,
          hintStyle: TextStyle(fontSize: 11, color: Color(0xFF314158))),
    );
    // );
  }
}
