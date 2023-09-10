import 'package:flutter/material.dart';

class customInfoWindow {
  /// Creates an immutable representation of a label on for [Marker].
  const customInfoWindow({
    this.title,
    this.snippet,
    this.anchor = const Offset(0.5, 0.0),
    this.onTap,
  });

  /// Text labels specifying that no text is to be displayed.
  static const customInfoWindow noText = customInfoWindow();

  /// Text displayed in an info window when the user taps the marker.
  ///
  /// A null value means no title.
  final String? title;

  /// Additional text displayed below the [title].
  ///
  /// A null value means no additional text.
  final String? snippet;

  /// The icon image point that will be the anchor of the info window when
  /// displayed.
  ///
  /// The image point is specified in normalized coordinates: An anchor of
  /// (0.0, 0.0) means the top left corner of the image. An anchor
  /// of (1.0, 1.0) means the bottom right corner of the image.
  final Offset anchor;

  /// onTap callback for this [customInfoWindow].
  final VoidCallback? onTap;

  /// Creates a new [customInfoWindow] object whose values are the same as this instance,
  /// unless overwritten by the specified parameters.
  customInfoWindow copyWith({
    String? titleParam,
    String? snippetParam,
    Offset? anchorParam,
    VoidCallback? onTapParam,
  }) {
    return customInfoWindow(
      title: titleParam ?? title,
      snippet: snippetParam ?? snippet,
      anchor: anchorParam ?? anchor,
      onTap: onTapParam ?? onTap,
    );
  }

  dynamic _toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('title', title);
    addIfPresent('snippet', snippet);
    addIfPresent('anchor', _offsetToJson(anchor));

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final customInfoWindow typedOther = other as customInfoWindow;
    return title == typedOther.title &&
        snippet == typedOther.snippet &&
        anchor == typedOther.anchor;
  }

  @override
  int get hashCode => hashValues(title.hashCode, snippet, anchor);

  @override
  String toString() {
    return 'customInfoWindow{title: $title, snippet: $snippet, anchor: $anchor}';
  }
}

dynamic _offsetToJson(Offset offset) {
  if (offset == null) {
    return null;
  }
  return <dynamic>[offset.dx, offset.dy];
}
