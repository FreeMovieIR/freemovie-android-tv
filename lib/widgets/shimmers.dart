import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Shimmer defShim({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[850]!,
    highlightColor: Colors.grey[800]!,
    child: child,
  );
}

Shimmer defBoxShim({required double height, required double? width, double radius = 12}) {
  return defShim(
      child: Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      color: Colors.grey,
    ),
  ));
}
