class ClanListModel {
  var activeTime;
  var id;
  var name;
  var description;
  var addedBy;
  var addedOn;
  var updateOn;
  var status;
  var image;
  var thumbImage;
  List<Members>? members;
  var lastActiveTime;

  ClanListModel(
      {this.activeTime,
      this.id,
      this.name,
      this.description,
      this.addedBy,
      this.addedOn,
      this.updateOn,
      this.status,
      this.image,
      this.thumbImage,
      this.members,
      this.lastActiveTime});

  ClanListModel.fromJson(Map<String, dynamic> json) {
    activeTime = json['active_time'];
    id = json['id'];
    name = json['name'];
    description = json['description'];
    addedBy = json['added_by'];
    addedOn = json['added_on'];
    updateOn = json['update_on'];
    status = json['status'];
    image = json['image'];
    thumbImage = json['thumb_image'];
    if (json['members'] != null) {
      members = [];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
    lastActiveTime = json['last_active_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active_time'] = this.activeTime;
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['added_by'] = this.addedBy;
    data['added_on'] = this.addedOn;
    data['update_on'] = this.updateOn;
    data['status'] = this.status;
    data['image'] = this.image;
    data['thumb_image'] = this.thumbImage;
    if (this.members != null) {
      data['members'] = this.members?.map((v) => v.toJson()).toList();
    }
    data['last_active_time'] = this.lastActiveTime;
    return data;
  }
}

class Members {
  var profile;
  var userId;
  var fullName;

  Members({this.profile, this.userId, this.fullName});

  Members.fromJson(Map<String, dynamic> json) {
    profile = json['profile'];
    userId = json['user_id'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['profile'] = this.profile;
    data['user_id'] = this.userId;
    data['full_name'] = this.fullName;
    return data;
  }
}
