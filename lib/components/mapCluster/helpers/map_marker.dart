import 'package:fluster/fluster.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

/// [Fluster] can only handle markers that conform to the [Clusterable] abstract class.
///
/// You can customize this class by adding more parameters that might be needed for
/// your use case. For instance, you can pass an onTap callback or add an
/// [InfoWindow] to your marker here, then you can use the [toMarker] method to convert
/// this to a proper [Marker] that the [GoogleMap] can read.
class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  Function? onTapIcon;
  InfoWindow infoWindows;
  BitmapDescriptor? icon;

  MapMarker({
    required this.id,
    required this.position,
    this.icon,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
    this.onTapIcon,
    required this.infoWindows,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  Marker toMarker() => Marker(
      infoWindow: infoWindows,
      markerId: MarkerId(isCluster! ? 'cl_$id' : id),
      position: LatLng(
        position.latitude,
        position.longitude,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      onTap: () {
        if (!isCluster!) {
          if (this.onTapIcon != null) {
            this.onTapIcon!();
          }
        }
      });
}
