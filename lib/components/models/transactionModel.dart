class transactionModel {
  var id;
  var paymentBy;
  var paymentTo;
  var refrenceId;
  var paymentMethod;
  var currency;
  var currencySign;
  var totalAmount;
  var commision;
  var txId;
  var paymentFor;
  var paymentStatus;
  var status;
  var response;
  var addedOn;
  var updateOn;
  var userPhone;
  var userCountryCode;
  var paymentType;
  var paymentMode;
  var originalAmount;
  var market;
  var operator;
  var description;

  transactionModel(
      {this.id,
      this.paymentBy,
      this.paymentTo,
      this.refrenceId,
      this.paymentMethod,
      this.currency,
      this.currencySign,
      this.totalAmount,
      this.commision,
      this.txId,
      this.paymentFor,
      this.paymentStatus,
      this.status,
      this.response,
      this.addedOn,
      this.updateOn,
      this.userPhone,
      this.originalAmount,
      this.userCountryCode,
      this.paymentType,
      this.paymentMode,
      this.market,
      this.operator,
      this.description});

  transactionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    paymentBy = json['payment_by'];
    paymentTo = json['payment_to'];
    refrenceId = json['refrence_id'];
    paymentMethod = json['payment_method'];
    currency = json['currency'];
    currencySign = json['currency_sign'];
    totalAmount = json['total_amount'];
    commision = json['commision'];
    txId = json['tx_id'];
    originalAmount = json["orginal_amount"];
    paymentFor = json['payment_for'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    response = json['response'];
    addedOn = json['added_on'];
    updateOn = json['update_on'];
    userPhone = json['user_phone'];
    userCountryCode = json['user_country_code'];
    paymentType = json['payment_type'];
    paymentMode = json['payment_mode'];
    market = json['market'];
    operator = json['operator'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['payment_by'] = this.paymentBy;
    data['payment_to'] = this.paymentTo;
    data['refrence_id'] = this.refrenceId;
    data['payment_method'] = this.paymentMethod;
    data['currency'] = this.currency;
    data['currency_sign'] = this.currencySign;
    data['total_amount'] = this.totalAmount;
    data['commision'] = this.commision;
    data['tx_id'] = this.txId;
    data["orginal_amount"] = this.originalAmount;
    data['payment_for'] = this.paymentFor;
    data['payment_status'] = this.paymentStatus;
    data['status'] = this.status;
    data['response'] = this.response;
    data['added_on'] = this.addedOn;
    data['update_on'] = this.updateOn;
    data['user_phone'] = this.userPhone;
    data['user_country_code'] = this.userCountryCode;
    data['payment_type'] = this.paymentType;
    data['payment_mode'] = this.paymentMode;
    data['market'] = this.market;
    data['operator'] = this.operator;
    data['description'] = this.description;
    return data;
  }
}
