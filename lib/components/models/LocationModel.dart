class LocationModel {
  var id,
      merchant_id,
      store_name,
      store_logo,
      store_country,
      store_state,
      store_city,
      store_address,
      store_latitude,
      store_longitude,
      status,
      open_time,
      close_time,
      distance,
      store_on,
      beacon_on,
      store_description,
      distance_unit;
  LocationModel._(
      {this.id,
      this.merchant_id,
      this.store_name,
      this.store_logo,
      this.store_country,
      this.store_state,
      this.store_city,
      this.store_address,
      this.store_latitude,
      this.store_longitude,
      this.status,
      this.open_time,
      this.close_time,
      this.distance,
      this.store_on,
      this.beacon_on,
      this.store_description,
      this.distance_unit});
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return new LocationModel._(
        id: json['id'],
        merchant_id: json['merchant_id'],
        store_name: json['store_name'],
        store_logo: json['store_logo'],
        store_country: json['store_country'],
        store_state: json['store_state'],
        store_city: json['store_city'],
        store_address: json['store_address'],
        store_latitude: json['store_latitude'],
        store_longitude: json['store_longitude'],
        status: json['status'],
        open_time: json['open_time'],
        close_time: json['close_time'],
        distance: json['distance'],
        store_on: json['store_on'],
        beacon_on: json['beacon_on'],
        store_description: json['store_description'],
        distance_unit: json['distance_unit']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
