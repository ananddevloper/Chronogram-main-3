class UserDetailModal {
  int? userId;
  String? name;
  String? email;
  String? mobileNumber;
  String? dob;
  String? profilePictureUrl;
  bool? mobileVerified;
  bool? emailVerified;
  String? status;

  UserDetailModal(
      {this.userId,
      this.name,
      this.email,
      this.mobileNumber,
      this.dob,
      this.profilePictureUrl,
      this.mobileVerified,
      this.emailVerified,
      this.status});

  UserDetailModal.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] is int ? json['userId'] : (json['user_id'] is int ? json['user_id'] : int.tryParse(json['userId']?.toString() ?? json['user_id']?.toString() ?? ""));
    name = json['name']?.toString();
    email = json['email']?.toString();
    mobileNumber = json['mobileNumber']?.toString() ?? json['mobile_number']?.toString();
    dob = json['dob']?.toString();
    profilePictureUrl = json['profilePictureUrl']?.toString() ?? json['profile_picture_url']?.toString();
    mobileVerified = json['mobileVerified'] == true || json['mobile_verified'] == true;
    emailVerified = json['emailVerified'] == true || json['email_verified'] == true;
    status = json['status']?.toString() ?? json['user_status_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobileNumber'] = this.mobileNumber;
    data['dob'] = this.dob;
    data['profilePictureUrl'] = this.profilePictureUrl;
    data['mobileVerified'] = this.mobileVerified;
    data['emailVerified'] = this.emailVerified;
    data['status'] = this.status;
    return data;
  }
  
}