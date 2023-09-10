class PaymentModel {
  late String id;
  late String walletOwnerId;
  late String walletID;
  late String iDProofType;
  late String iDNumber;
  late String iDImageFront;
  late String iDImageBack;
  late String authPinCode;
  late String market;
  late String currency;
  late String operator;
  late String phoneNumber;
  late String phonePrefix;
  String? description;
  late String status;
  late String addedOn;
  late String updatedOn;

  PaymentModel(
      {required this.id,
      required this.walletOwnerId,
      required this.walletID,
      required this.iDProofType,
      required this.iDNumber,
      required this.iDImageFront,
      required this.iDImageBack,
      required this.authPinCode,
      required this.market,
      required this.currency,
      required this.operator,
      required this.phoneNumber,
      required this.phonePrefix,
      this.description,
      required this.status,
      required this.addedOn,
      required this.updatedOn});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    walletOwnerId = json['wallet_owner_id'];
    walletID = json['wallet_ID'];
    iDProofType = json['ID_proof_type'];
    iDNumber = json['ID_number'];
    iDImageFront = json['ID_image_front'];
    iDImageBack = json['ID_image_back'];
    authPinCode = json['auth_pin_code'];
    market = json['market'];
    currency = json['currency'] ?? "XOF";
    operator = json['operator'];
    phoneNumber = json['phone_number'];
    phonePrefix = json['phone_prefix'];
    description = json['description'];
    status = json['status'];
    addedOn = json['added_on'] ?? "";
    updatedOn = json['updated_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['wallet_owner_id'] = this.walletOwnerId;
    data['wallet_ID'] = this.walletID;
    data['ID_proof_type'] = this.iDProofType;
    data['ID_number'] = this.iDNumber;
    data['ID_image_front'] = this.iDImageFront;
    data['ID_image_back'] = this.iDImageBack;
    data['auth_pin_code'] = this.authPinCode;
    data['market'] = this.market;
    data['currency'] = this.currency;
    data['operator'] = this.operator;
    data['phone_number'] = this.phoneNumber;
    data['phone_prefix'] = this.phonePrefix;
    data['description'] = this.description;
    data['status'] = this.status;
    data['added_on'] = this.addedOn;
    data['updated_on'] = this.updatedOn;
    return data;
  }
}
