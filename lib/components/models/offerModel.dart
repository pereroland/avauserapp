class OfferModel {
  final String? product_id,
      category_id,
      id,
      campaign_id,
      murchant_id,
      code,
      start_time,
      end_time,
      offer_amount,
      amount_unit,
      amount_currency,
      minimum_shoping,
      single_customer_can_use,
      status,
      added_on,
      update_on,
      offerId;

  OfferModel._(
      {this.product_id,
      this.category_id,
      this.id,
      this.campaign_id,
      this.murchant_id,
      this.code,
      this.start_time,
      this.end_time,
      this.offer_amount,
      this.amount_unit,
      this.amount_currency,
      this.minimum_shoping,
      this.single_customer_can_use,
      this.status,
      this.added_on,
      this.update_on,
      this.offerId});

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return new OfferModel._(
        product_id: json['product_id'],
        category_id: json['category_id'],
        id: json['id'],
        campaign_id: json['campaign_id'],
        murchant_id: json['murchant_id'],
        code: json['code'],
        start_time: json['start_time'],
        end_time: json['end_time'],
        offer_amount: json['offer_amount'],
        amount_unit: json['amount_unit'],
        amount_currency: json['amount_currency'],
        minimum_shoping: json['minimum_shoping'],
        single_customer_can_use: json['single_customer_can_use'],
        status: json['status'],
        added_on: json['added_on'],
        update_on: json['update_on'],
        offerId: json['offerId']);
  }
}
