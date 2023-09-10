class invoice {
  var id;
  String? newClan;
  String? newClanDetails;
  var invoiceId;
  var detailsStatus;
  var createdBy;
  var invoiceTotalAmount;
  var invoiceCurrency;
  var invoiceText;
  var requestDate;
  var addedOn;
  var updateOn;
  var status;
  var invoiceType;
  var invoiceTypeId;
  var bookingId;
  var title;
  var share;

  invoice(
      {this.id,
      this.newClan,
      this.invoiceId,
      this.createdBy,
      this.invoiceTotalAmount,
      this.invoiceCurrency,
      this.invoiceText,
      this.requestDate,
      this.addedOn,
      this.newClanDetails,
      this.detailsStatus,
      this.updateOn,
      this.status,
      this.invoiceType,
      this.invoiceTypeId,
      this.bookingId,
      this.title,
      this.share});

  invoice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    newClan = json["new_clan"];
    invoiceId = json['invoiceId'];
    createdBy = json['created_by'];
    invoiceTotalAmount = json['invoice_total_amount'];
    invoiceCurrency = json['invoice_currency'];
    invoiceText = json['invoice_text'];
    requestDate = json['request_date'];
    detailsStatus = json["clandetailstatus"];
    addedOn = json['added_on'];
    updateOn = json['update_on'];
    newClanDetails = json["detailnewclan"];
    status = json['status'];
    invoiceType = json['invoice_type'];
    invoiceTypeId = json['invoice_type_id'];
    bookingId = json['booking_id'];
    title = json['title'];
    share = json['share'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['invoiceId'] = this.invoiceId;
    data["detailnewclan"] = this.newClanDetails;
    data['created_by'] = this.createdBy;
    data["clandetailstatus"] = this.detailsStatus;
    data['invoice_total_amount'] = this.invoiceTotalAmount;
    data['invoice_currency'] = this.invoiceCurrency;
    data['invoice_text'] = this.invoiceText;
    data['request_date'] = this.requestDate;
    data['added_on'] = this.addedOn;
    data['update_on'] = this.updateOn;
    data['status'] = this.status;
    data["newClan"] = this.newClan;
    data['invoice_type'] = this.invoiceType;
    data['invoice_type_id'] = this.invoiceTypeId;
    data['booking_id'] = this.bookingId;
    data['title'] = this.title;
    data['share'] = this.share;
    return data;
  }
}
