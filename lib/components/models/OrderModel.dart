class OrderModel {
  //            "id": "11",
  //             "order_id": "12",
  //             "product_id": "11",
  //             "store_id": "11",
  //             "quantity": "1",
  //             "sub_total": "50",
  //             "merchant_id": "14",
  //             "name": "qwerty",
  //             "category": "0",
  //             "price": "50",
  //             "offers": "eyg",
  //             "discount": "28",
  //             "description": "wwwfffvvv",
  //             "imgs": [
  //                 "https://alphaxtech.net/ecity/default/product_default.jpg"
  //             ],
  //             "status": "2",
  //             "booking_id": "#ECITY1597833621",
  //             "user_id": "1",
  //             "group_id": "0",
  //             "delivery_amount": "100",
  //             "discounted_amount": "28",
  //             "total_amount": "122",
  //             "total_payed_amount": "122",
  //             "tx_id": "fre",
  //             "payment_status": "1",
  //             "added_on": "19-08-2020",
  //             "update_on": "1597833621",
  //             "store_name": "123",
  //             "store_logo": "",
  //             "store_country": "United States",
  //             "store_state": "California",
  //             "store_city": "Mountain View",
  //             "store_address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
  //             "store_latitude": "37.4219983",
  //             "store_longitude": "-122.084",
  //             "open_time": "",
  //             "close_time": "",
  //             "product_name": "qwerty",
  //             "product_description": "wwwfffvvv",
  //             "product_quantity": "1"
  var id,
      order_id,
      order_status,
      product_id,
      store_id,
      quantity,
      sub_total,
      merchant_id,
      name,
      category,
      price,
      offers,
      discount,
      description,
      imgs,
      status,
      booking_id,
      user_id,
      group_id,
      delivery_amount,
      discounted_amount,
      total_amount,
      total_payed_amount,
      tx_id,
      payment_status,
      added_on,
      update_on,
      store_name,
      store_description,
      store_logo,
      store_country,
      store_state,
      store_city,
      store_address,
      store_latitude,
      store_longitude,
      open_time,
      close_time,
      currency,
      detail_id,
      product_name,
      product_description,
      merchant_country_code,
      store_currency,
      store_currency_sign,
      merchant_phone,
      product_quantity;

  OrderModel._(
      {this.id,
      this.order_id,
      this.order_status,
      this.product_id,
      this.store_id,
      this.quantity,
      this.sub_total,
      this.merchant_id,
      this.name,
      this.category,
      this.price,
      this.offers,
      this.discount,
      this.description,
      this.imgs,
      this.status,
      this.booking_id,
      this.user_id,
      this.group_id,
      this.delivery_amount,
      this.discounted_amount,
      this.total_amount,
      this.total_payed_amount,
      this.tx_id,
      this.payment_status,
      this.added_on,
      this.update_on,
      this.store_name,
      this.store_description,
      this.store_logo,
      this.store_country,
      this.store_state,
      this.store_city,
      this.store_address,
      this.store_latitude,
      this.store_longitude,
      this.open_time,
      this.close_time,
      this.currency,
      this.detail_id,
      this.product_name,
      this.product_description,
      this.merchant_country_code,
        this.store_currency,
        this.store_currency_sign,
      this.merchant_phone,
      this.product_quantity});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return new OrderModel._(
      id: json['id'],
      order_id: json['order_id'],
      order_status: json['order_status'],
      product_id: json['product_id'],
      store_id: json['store_id'],
      quantity: json['quantity'],
      sub_total: json['sub_total'],
      merchant_id: json['merchant_id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
      offers: json['offers'],
      discount: json['discount'],
      description: json['description'],
      imgs: json['imgs'],
      status: json['status'],
      booking_id: json['booking_id'],
      user_id: json['user_id'],
      group_id: json['group_id'],
      delivery_amount: json['delivery_amount'],
      discounted_amount: json['discounted_amount'],
      total_amount: json['total_amount'],
      total_payed_amount: json['total_payed_amount'],
      tx_id: json['tx_id'],
      payment_status: json['payment_status'],
      added_on: json['added_on'],
      update_on: json['update_on'],
      store_name: json['store_name'],
      store_description: json['store_description'],
      store_logo: json['store_logo'],
      store_country: json['store_country'],
      store_state: json['store_state'],
      store_city: json['store_city'],
      store_address: json['store_address'],
      store_latitude: json['store_latitude'],
      store_longitude: json['store_longitude'],
      open_time: json['open_time'],
      close_time: json['close_time'],
      currency: json['currency'],
      detail_id: json['detail_id'],
      product_name: json['product_name'],
      product_description: json['product_description'],
      merchant_country_code: json['merchant_country_code'],
      store_currency_sign: json['store_currency_sign'],
      store_currency: json['store_currency'],
      merchant_phone: json['merchant_phone'],
      product_quantity: json['product_quantity'],
    );
  }
}
