import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/ProductModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ProductItemDetail.dart';

class ProductListOnTags extends StatefulWidget {
  final String pushId;

  ProductListOnTags({Key? key, required this.pushId}) : super(key: key);

  @override
  State<ProductListOnTags> createState() => _ProductListOnTagsState();
}

class _ProductListOnTagsState extends State<ProductListOnTags> {
  List<ProductModel> _list = [];
  List<dynamic> idsOnLoading = [];
  String storeName = "Store";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    validationCheck();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 1.8;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            storeName,
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: !isLoading
            ? _list.isNotEmpty
                ? GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: (itemWidth / itemHeight),
                    children: List.generate(
                      _list.length,
                      (index) {
                        return Center(
                          child: listItems(index, itemHeight),
                        );
                      },
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(30),
                    child: Center(
                      child: Image.asset("assets/noproductfound.webp"),
                    ),
                  )
            : Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Center(
                  child: Image.asset("assets/storeloadding.gif"),
                ),
              ),
      ),
    );
  }

  Future<void> validationCheck() async {
    if (mounted)
      setState(() {
        _list = [];
      });
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck(1);
    }
  }

  void callUSerStatusCheck(int page) async {
    try {
      if (mounted && page == 1)
        setState(() {
          isLoading = true;
        });
      String data = await getApiDataRequest(
          "$productListOnTagUrl/${widget.pushId}/$page", context);
      if (mounted && page == 1)
        setState(() {
          isLoading = false;
        });
      Map decoded = jsonDecode(data);
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        var data = decoded['record']['data'];
        List<ProductModel> _listGet = data
            .map<ProductModel>((json) => ProductModel.fromJson(json))
            .toList();
        if (page == 1) {
          storeName = decoded["store"]["store_name"] ?? "Store";
          if (mounted) setState(() {});
          _list = _listGet;
        } else {
          _list.addAll(_listGet);
        }
        callUSerStatusCheck(page + 1);
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == "408") {
        jsonDecode(await apiRefreshRequest(context));
        callUSerStatusCheck(page);
      } else {
        if (page == 1) _showToast(message);
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _showToast(allTranslations.text("no_data_found"));
          isLoading = false;
        });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  listItems(int index, itemHeight) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductItemAllDetail(product_id: _list[index].id)),
          );
        },
        child: Container(
          color: Colors.white,
          margin: EdgeInsets.all(2.0),
          padding: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 10.0),
          child: Column(
            children: <Widget>[
              Container(
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        height: itemHeight / 1.5,
                        width: MediaQuery.of(context).size.width,
                        child: CachedNetworkImage(
                          imageUrl: _list[index].imgs[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              imageShimmer(context, 40.0),
                          errorWidget: (context, url, error) => Image.asset(
                            "assets/nodata.webp",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: likeButtonShow(
                            _list[index],
                          ),
                        ),
                      )
                    ],
                  ),
                  width: MediaQuery.of(context).size.width),
              Expanded(
                child: Align(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Align(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            _list[index].name,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                          priceCheck(_list, index),
                        ],
                      ),
                      alignment: Alignment.bottomLeft,
                    ),
                  ),
                  alignment: Alignment.bottomRight,
                ),
              )
            ],
          ),
        ));
  }

  likeButtonShow(ProductModel productModel) {
    return SizedBox(
      height: 40.0,
      width: 50.0,
      child: idsOnLoading.contains(productModel.id)
          ? Padding(
              padding:
                  const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 8),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColours.appTheme),
              ),
            )
          : GestureDetector(
              child: Icon(
                Icons.favorite,
                size: 35,
                color: productModel.is_favourite == "1"
                    ? Colors.red
                    : Colors.black38,
              ),
              onTap: () => getDetail(productModel),
            ),
    );
  }

  Future<void> getDetail(ProductModel productModel) async {
    var callUserLoginCheck = await internetConnectionState();
    idsOnLoading.add(productModel.id);
    if (mounted) setState(() {});
    if (callUserLoginCheck == true) {
      var api = favUnfavoriteProductUrl + productModel.id;
      Map decoded = jsonDecode(await getApiDataRequest(api, context));
      idsOnLoading.remove(productModel.id);
      if (mounted) setState(() {});
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status && mounted) {
        _list[_list.indexWhere((element) => element.id == productModel.id)]
            .is_favourite = productModel.is_favourite == "1" ? "0" : "1";
        if (mounted) setState(() {});
      } else {
        _showToast(message);
      }
    } else {
      idsOnLoading.remove(productModel.id);
      if (mounted) setState(() {});
    }
  }

  priceCheck(list, index) {
    if (list[index].offers.toString() == 'null' ||
        list[index].offers.toString() == '') {
      return Text(
        _list[index].currency_code + " " + _list[index].price,
        maxLines: 1,
        style: TextStyle(fontSize: 15.0, color: AppColours.blackColour),
      );
    } else {
      if (list[index].offers.toString() != "[]") {
        return Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
              child: Text(
                _list[index].currency_code + " " + _list[index].price,
                style: TextStyle(
                    fontSize: 14.0, decoration: TextDecoration.lineThrough),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 2.0, 0.0),
              child: Text(
                _list[index].currency_code +
                    " " +
                    _list[index].offfer_price.toString(),
                style: TextStyle(fontSize: 14.0),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        );
      } else {
        return Text(
          _list[index].currency_code + " " + _list[index].price,
          maxLines: 1,
          style: TextStyle(fontSize: 15.0, color: AppColours.blackColour),
        );
      }
    }
  }
}
