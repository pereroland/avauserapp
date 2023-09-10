class disputeList {
  var id;
  var title;
  var description;
  var orderId;
  var images;
  var disputeBy;
  var disputeTo;
  var status;
  var addedOn;
  var updatedOn;
  var storeName;
  var storeLogo;
  var fullName;
  var merchantProfile;
  var bookingId;
  var totalPayedAmount;
  var currencySign;
  var thumbImages;
  var storeLogoThumb;

  disputeList(
      {this.id,
        this.title,
        this.description,
        this.orderId,
        this.images,
        this.disputeBy,
        this.disputeTo,
        this.status,
        this.addedOn,
        this.updatedOn,
        this.storeName,
        this.storeLogo,
        this.fullName,
        this.merchantProfile,
        this.bookingId,
        this.totalPayedAmount,
        this.currencySign,
        this.thumbImages,
        this.storeLogoThumb});

  disputeList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    orderId = json['order_id'];
    images = json['images'].cast<String>();
    disputeBy = json['dispute_by'];
    disputeTo = json['dispute_to'];
    status = json['status'];
    addedOn = json['added_on'];
    updatedOn = json['updated_on'];
    storeName = json['store_name'];
    storeLogo = json['store_logo'];
    fullName = json['full_name'];
    merchantProfile = json['merchant_profile'];
    bookingId = json['booking_id'];
    totalPayedAmount = json['total_payed_amount'];
    currencySign = json['currency_sign'];
    thumbImages = json['thumb_images'].cast<String>();
    storeLogoThumb = json['store_logo_thumb'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['order_id'] = this.orderId;
    data['images'] = this.images;
    data['dispute_by'] = this.disputeBy;
    data['dispute_to'] = this.disputeTo;
    data['status'] = this.status;
    data['added_on'] = this.addedOn;
    data['updated_on'] = this.updatedOn;
    data['store_name'] = this.storeName;
    data['store_logo'] = this.storeLogo;
    data['full_name'] = this.fullName;
    data['merchant_profile'] = this.merchantProfile;
    data['booking_id'] = this.bookingId;
    data['total_payed_amount'] = this.totalPayedAmount;
    data['currency_sign'] = this.currencySign;
    data['thumb_images'] = this.thumbImages;
    data['store_logo_thumb'] = this.storeLogoThumb;
    return data;
  }
}