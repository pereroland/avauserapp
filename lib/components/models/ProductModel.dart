class ProductModel {
  var id,
      merchant_id,
      store_id,
      name,
      category,
      price,
      offers,
      discount,
      description,
      imgs,
      status,
      currency_code,
      currency,
      is_favourite,
      applyed_offer,
      offfer_price;

  ProductModel._({
    this.id,
    this.merchant_id,
    this.store_id,
    this.name,
    this.category,
    this.price,
    this.offers,
    this.discount,
    this.description,
    this.imgs,
    this.status,
    this.currency_code,
    this.currency,
    this.is_favourite,
    this.applyed_offer,
    this.offfer_price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return new ProductModel._(
      id: json['id'],
      merchant_id: json['merchant_id'],
      store_id: json['store_id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      offers: json['offers'],
      discount: json['discount'],
      description: json['description'],
      imgs: json['imgs'],
      status: json['status'],
      currency_code: json['currency_code'],
      currency: json['currency'],
      is_favourite: json['is_favourite'].toString(),
      applyed_offer: json['applyed_offer'],
      offfer_price: json['offfer_price'],
    );
  }
}
