class chatMessage {
  var id;
  var groupId;
  var sendBy;
  var sendTo;
  var message;
  List<String>? file;
  var status;
  var addedOn;
  var updateOn;
  var fullName;
  var profile;
  String? localTime;
  var profileThumb;
  var message_time;
  List<String>? thumbFile;

  chatMessage(
      {this.id,
      this.groupId,
      this.sendBy,
      this.sendTo,
      this.message,
      this.file,
      this.status,
      this.localTime,
      this.addedOn,
      this.updateOn,
      this.fullName,
      this.profile,
      this.profileThumb,
      this.message_time,
      this.thumbFile});

  chatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupId = json['group_id'];
    sendBy = json['send_by'];
    sendTo = json['send_to'];
    message = json['message'];
    file = json['file'].cast<String>();
    status = json['status'];
    addedOn = json['added_on'];
    updateOn = json['update_on'];
    fullName = json['full_name'];
    localTime = json["chat_time"];
    profile = json['profile'];
    profileThumb = json['profile_thumb'];
    message_time = json['message_time'];
    thumbFile = json['thumb_file'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['group_id'] = this.groupId;
    data['send_by'] = this.sendBy;
    data['send_to'] = this.sendTo;
    data['message'] = this.message;
    data['file'] = this.file;
    data['status'] = this.status;
    data['added_on'] = this.addedOn;
    data['update_on'] = this.updateOn;
    data['chat_time'] = this.localTime;
    data['full_name'] = this.fullName;
    data['profile'] = this.profile;
    data['profile_thumb'] = this.profileThumb;
    data['message_time'] = this.message_time;
    data['thumb_file'] = this.thumbFile;
    return data;
  }
}
