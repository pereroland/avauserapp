class NearByEvents {
  var id;
  var userId;
  var title;
  var type;
  var category;
  var description;
  var startDateTime;
  var endDateTime;
  var country;
  var state;
  var city;
  var address;
  var longitude;
  var latitude;
  var accessOption;
  var uniqId;
  var imgs;
  var documents;
  var urls;
  var status;
  var totalSeats;
  var addedOn;
  var updateOn;
  var distance;
  var distanceUnit;
  var imgsThumb;

  NearByEvents(
      {this.id,
        this.userId,
        this.title,
        this.type,
        this.category,
        this.description,
        this.startDateTime,
        this.endDateTime,
        this.country,
        this.state,
        this.city,
        this.address,
        this.longitude,
        this.latitude,
        this.accessOption,
        this.uniqId,
        this.imgs,
        this.documents,
        this.urls,
        this.status,
        this.totalSeats,
        this.addedOn,
        this.updateOn,
        this.distance,
        this.distanceUnit,
        this.imgsThumb});

  NearByEvents.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    type = json['type'];
    category = json['category'];
    description = json['description'];
    startDateTime = json['start_date_time'];
    endDateTime = json['end_date_time'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    address = json['address'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    accessOption = json['access_option'];
    uniqId = json['uniq_id'];
    imgs = json['imgs'].cast<String>();
    documents = json['documents'];
    urls = json['urls'];
    status = json['status'];
    totalSeats = json['total_seats'];
    addedOn = json['added_on'];
    updateOn = json['update_on'];
    distance = json['distance'];
    distanceUnit = json['distance_unit'];
    imgsThumb = json['imgs_thumb'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['type'] = this.type;
    data['category'] = this.category;
    data['description'] = this.description;
    data['start_date_time'] = this.startDateTime;
    data['end_date_time'] = this.endDateTime;
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['address'] = this.address;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['access_option'] = this.accessOption;
    data['uniq_id'] = this.uniqId;
    data['imgs'] = this.imgs;
    data['documents'] = this.documents;
    data['urls'] = this.urls;
    data['status'] = this.status;
    data['total_seats'] = this.totalSeats;
    data['added_on'] = this.addedOn;
    data['update_on'] = this.updateOn;
    data['distance'] = this.distance;
    data['distance_unit'] = this.distanceUnit;
    data['imgs_thumb'] = this.imgsThumb;
    return data;
  }
}