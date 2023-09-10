import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/screens/product/StoreItemsListShop.dart';
import 'package:avauserapp/screens/product/favProductList.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/material.dart';

class FavoriteItems extends StatefulWidget {
  @override
  _FavoriteItemsState createState() => _FavoriteItemsState();
}

class _FavoriteItemsState extends State<FavoriteItems> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          bottom: TabBar(
            tabs: [
              setText(allTranslations.text('store')),
              setText(allTranslations.text('product')),
            ],
          ),
          centerTitle: true,
          title: Text(
            allTranslations.text('FavoriteList'),
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            StoreShopDetail(
              type: "4",
              category: '',
              merchant_id: '',
              isFav: true,
            ),
            FavProduct(storeName: '', Id: '', isFav: true),
          ],
        ),
      ),
    );
  }

  setText(String textString) {
    return Text(
      textString,
      style: TextStyle(color: Colors.black),
    );
  }
}
