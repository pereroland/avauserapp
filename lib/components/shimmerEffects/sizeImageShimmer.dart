
import 'package:flutter/material.dart';

import 'shimmer.dart';

Widget sizeImageShimmer(context,width,height) {
  return Container(
      width: width,
      height: height,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ));
}