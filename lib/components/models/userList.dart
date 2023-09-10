class userProfile {
 late String groupId;
 late String profile;
 late String userId;
 late String profileThumb;

  userProfile({required this.groupId, required this.profile, required this.userId, required this.profileThumb});

  userProfile.fromJson(Map<String, dynamic> json) {
    groupId = json['group_id'];
    profile = json['profile'];
    userId = json['user_id'];
    profileThumb = json['profile_thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['group_id'] = this.groupId;
    data['profile'] = this.profile;
    data['user_id'] = this.userId;
    data['profile_thumb'] = this.profileThumb;
    return data;
  }
}