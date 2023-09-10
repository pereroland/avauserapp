class OrderDetailModel {
  var id,
      order_id,
      product_id,
      store_id,
      quantity,
      sub_total,
      offer_price,
      applied_offer,
      status,
      update_on,
      added_on,
      update_by,
      product_name,
      product_description,
      product_price,
      item_price,
      product_qty,
      imgs,
      imgs_thumb,
      size,
      color;

  OrderDetailModel._(
      {this.id,
      this.order_id,
      this.product_id,
      this.store_id,
      this.quantity,
      this.sub_total,
      this.offer_price,
      this.applied_offer,
      this.status,
      this.update_on,
      this.added_on,
      this.update_by,
      this.product_name,
      this.product_description,
      this.product_price,
      this.item_price,
      this.product_qty,
      this.imgs,
      this.imgs_thumb,
      this.color,
      this.size});

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return new OrderDetailModel._(
        id: json['id'],
        order_id: json['order_id'],
        product_id: json['product_id'],
        store_id: json['store_id'],
        quantity: json['quantity'],
        sub_total: json['sub_total'],
        offer_price: json['offer_price'],
        applied_offer: json['applied_offer'],
        status: json['status'],
        update_on: json['update_on'],
        added_on: json['added_on'],
        update_by: json['update_by'],
        product_name: json['product_name'],
        product_description: json['product_description'],
        product_price: json['product_price'],
        item_price: json['item_price'],
        product_qty: json['product_qty'],
        imgs: json['imgs'],
        imgs_thumb: json['imgs_thumb'],
        color: json["product_colors"].toString() != "[]"
            ? json["product_colors"][0]["option_name"]
            : "",
        size: json["product_size"].toString() != "[]"
            ? json["product_size"][0]["option_name"]
            : "");
  }
}
