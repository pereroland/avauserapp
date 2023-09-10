class ContactsData {
  var name,
      number,
      id,
      name_in_app,
      user_type,
      country_code,
      email,
      profile;

  ContactsData(
      this.name,
      this.number,
      this.id,
      this.name_in_app,
      this.user_type,
      this.country_code,
      this.email,
      this.profile
      );

  ContactsData.map(dynamic obj) {
    this.name = obj["name"];
    this.number = obj["number"];
    this.id = obj["id"];
    this.name_in_app = obj["name_in_app"];
    this.user_type = obj["user_type"];
    this.country_code = obj["country_code"];
    this.email = obj["email"];
    this.profile = obj["profile"];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["number"] = number;
    map["id"] = id;
    map["name_in_app"] = name_in_app;
    map["user_type"] = user_type;
    map["country_code"] = country_code;
    map["email"] = email;
    map["profile"] = profile;
    return map;
  }

  void setUserId(int id) {
    this.id = id;
  }
}

