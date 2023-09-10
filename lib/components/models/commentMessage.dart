class CommentMessage {
  String id;
  String disputeId;
  String message;
  String sendBy;
  String sendTo;
  String? file;
  String status;
  String addedOn;
  String sendByName;
  String messageTime;
  String sendToName;
  String updateOn;

  CommentMessage(
      {required this.id,
      required this.disputeId,
      required this.message,
      required this.messageTime,
      required this.sendToName,
      required this.sendBy,
      required this.sendByName,
      required this.sendTo,
      this.file,
      required this.status,
      required this.addedOn,
      required this.updateOn});

  factory CommentMessage.fromJson(Map<String, dynamic> json) {
    return CommentMessage(
      id: json['id'],
      disputeId: json['dispute_id'],
      message: json['message'],
      sendBy: json['send_by'],
      messageTime: json["chat_time"],
      sendToName: json["send_to_name"],
      sendTo: json['send_to'],
      file: json['file'],
      status: json['status'],
      sendByName: json['send_by_name'],
      addedOn: json['added_on'],
      updateOn: json['update_on'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['dispute_id'] = this.disputeId;
    data['message'] = this.message;
    data['send_by'] = this.sendBy;
    data['send_to'] = this.sendTo;
    data['file'] = this.file;
    data['status'] = this.status;
    data['added_on'] = this.addedOn;
    data['chat_time'] = this.messageTime;
    data['update_on'] = this.updateOn;
    return data;
  }
}
