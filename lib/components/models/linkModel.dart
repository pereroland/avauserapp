class linkEvent {
  var name, url;

//link name
//link url
  linkEvent._({this.name, this.url});

  factory linkEvent.fromJson(Map<String, dynamic> json) {
    return new linkEvent._(name: json['name'], url: json['url']);
  }
}