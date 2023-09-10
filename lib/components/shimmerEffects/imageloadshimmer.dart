import 'package:flutter/material.dart';

import 'shimmer.dart';

Widget imageShimmer(context,size) {
  return Container(
      width: size,
      height: size,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          color: Colors.white,
        ),
      ));
}
