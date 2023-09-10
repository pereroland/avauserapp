import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/launchurl.dart';
import 'package:avauserapp/components/models/linkModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/profiledetailshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/screens/Item/detailPayment.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductItemAllDetail extends StatefulWidget {
  ProductItemAllDetail({Key? key, this.product_id, this.campaignData})
      : super(key: key);
  var product_id;
  Map? campaignData;

  @override
  _ItemAllDetail createState() => _ItemAllDetail();
}

class _ItemAllDetail extends State<ProductItemAllDetail> {
  var dataLoad = false;
  var dataAvaialble = false;
  var STORES = "",
      id = "",
      merchant_id = "",
      store_id = "",
      name = "",
      category = "",
      currency_code = "",
      price = "",
      discount = "",
      description = "",
      status = "";

  var variants;
  var imgs;
  var offers;
  var linkShare = '';
  var offfer_price = '';
  var _current = 0;
  Map? myLang;
  var addToCart = true;
  var loading = false;
  List list = [];
  var cardCountNotVisible = true;
  var cardCount = 0;
  var animate = false;
  var qtyCheck = 0;
  late List linkUrlList;
  List<linkEvent> eventLink = [];
  var applyOfferEnable = false;
  var record;
  late List<Map> ProductSizesList;
  late List<Map> ProductColorsList;
  int SizeSelected = 0;
  int colourSelected = 0;

  @override
  void initState() {
    super.initState();
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: dataAvaialble
          ? qtyCheck > 0
              ? addToCart
                  ? addToCartButton(context)
                  : goToCart(context)
              : outOfStock(context)
          : SizedBox.shrink(),
      appBar: new AppBar(
        title: Text(
          name,
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Container(
                height: 150.0,
                width: 30.0,
                child: new GestureDetector(
                    onTap: () {
                      /* Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new CartItemsScreen()));*/
                    },
                    child: GestureDetector(
                      child: new Stack(
                        children: <Widget>[
                          IconButton(
                            icon: new Icon(
                              Icons.shopping_cart,
                              color: Colors.black,
                              size: 32.0,
                            ),
                            onPressed: null,
                          ),
                          cardCountNotVisible
                              ? new Container()
                              : new Positioned(
                                  child: Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                  child: new Stack(
                                    children: <Widget>[
                                      Center(
                                        child: new Icon(
                                          Icons.brightness_1,
                                          size: 30.0,
                                          color: AppColours.appTheme,
                                        ),
                                      ),
                                      Center(
                                        child: new Text(
                                          cardCount.toString(),
                                          style: new TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                        ],
                      ),
                      onTap: () {
                        {
                          if (cardCount > 0) {
                            navigateCartPage(context);
                          }
                        }
                      },
                    ))),
          )
        ],
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: dataLoad
          ? dataAvaialble
              ? SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CarouselSlider(
                      options: CarouselOptions(
                          height: MediaQuery.of(context).size.height / 1.5,
                          viewportFraction: 1.0,
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                            });
                          }),
                      items: imgs.map<Widget>((card) {
                        return Builder(builder: (BuildContext context) {
                          return CachedNetworkImage(
                            imageUrl: card,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => sizeImageShimmer(
                                context,
                                MediaQuery.of(context).size.width,
                                340.0),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/nodata.webp",
                              fit: BoxFit.fill,
                            ),
                            width: MediaQuery.of(context).size.width,
                          );
                        });
                      }).toList(),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: mapSlider<Widget>(imgs, (index, url) {
                        return Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 2.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == index
                                ? AppColours.appTheme
                                : Colors.black38,
                          ),
                        );
                      }),
                    ),
                    ItemDetail(),
                    eventLink.length > 0 ? linkBox() : SizedBox.shrink(),
                    shareBox(),
                  ],
                ))
              : profileDetail(context)
          : Container(
              child: profileDetail(context),
            ),
    );
  }

  ItemDetail() {
    return Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          spaceHeight(),
          Container(
            width: MediaQuery.of(context).size.width,
            color: AppColours.whiteColour,
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spaceHeight(),
                ItemFullDetail(),
                spaceHeight(),
              ],
            ),
          ),
          spaceHeight(),
          Container(
            color: AppColours.whiteColour,
            width: MediaQuery.of(context).size.width,
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allTranslations.text('ProductDetails'),
                        style: TextStyle(fontSize: 16.0),
                      ),
                      spaceHeight(),
                      Text(
                        description,
                        style: TextStyle(
                            color: AppColours.blacklightLineColour,
                            letterSpacing:
                                0.5 // the white space between letter, default is 0.0
                            ),
                      ),
                      spaceHeight(),
                      spaceHeight(),
                      productSizeFiled(),
                    ])),
          ),
        ],
      ),
    );
  }

  shareBox() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
        child: new Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(10.0),
                border: Border.all(width: 0.5, color: Colors.black38)),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(allTranslations.text('LikedThisProduct')),
                      Text(allTranslations.text('ShareWithYourFriends')),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Text(
                      allTranslations.text('Share'),
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      var message = allTranslations.text('productShareMessage');
                      Share.share(message + "\n" + linkShare, subject: '');

                      //Check out this product
                      // https://alphaxtech.net/ecity/index.php/api/users/Products/detail/10
                    },
                  ),
                )
              ],
            )));
  }

  linkBox() {
    return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
        child: new Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(10.0),
                border: Border.all(width: 0.5, color: Colors.black38)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(allTranslations.text('webLink')),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: eventLink.length,
                    itemBuilder: (BuildContext context, int index) {
                      return linkList(eventLink, index, context);
                    })
              ],
            )));
  }

  linkList(List<linkEvent> eventLink, int index, BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                child: Text(eventLink[index].name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
                onTap: () {
                  launchURL(eventLink[index].url);
                },
              ),
            ),
          ],
        ));
  }

  ItemFullDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
//        Row(
//          children: <Widget>[
//            Expanded(
//              flex: 5,
//              child: Text(
//                "Campaing Name",
//                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
//              ),
//            ),
//            Expanded(
//              flex: 1,
//              child: Text(":"),
//            ),
//            Expanded(
//              flex: 5,
//              child: Text(
//                "Domino's Pizza",
//                textAlign: TextAlign.end,
//                style: TextStyle(fontSize: 18.0),
//              ),
//            ),
//          ],
//        ),
//        spaceHeight(),

//      STORES = "",
//id = "",
//merchant_id = "",
//store_id = "",
//name = "",
//category = "",
//price = "",
//offers = "",
//discount = "",
//description = "",
//status = "";
        Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        SizedBox(
          height: 10.0,
        ),
        offerCheck(),
//        spaceHeight(),
        /* Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                "Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(":"),
            ),
            Expanded(
              flex: 5,
              child: Text(
                category,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
        spaceHeight(),
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                "Price",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(":"),
            ),
            Expanded(
              flex: 5,
              child: Text(
                price,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
        spaceHeight(),
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                "Offers",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(":"),
            ),
            Expanded(
              flex: 5,
              child: Text(
                offers,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
        spaceHeight(),
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Text(
                "Discount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(":"),
            ),
            Expanded(
              flex: 5,
              child: Text(
                discount,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
        spaceHeight(),*/
      ],
    );
  }

  spaceHeight() {
    return SizedBox(height: 10.0);
  }

  void getDetail() async {
    var callUserLoginCheck = await internetConnectionState();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (callUserLoginCheck == true) {
      var url = productDetailUrl + widget.product_id;
      Map decoded = jsonDecode(await getApiDataRequest(url, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        record = decoded['record'];
        cardCount = int.parse(decoded['record']['cart_total_items'].toString());
        id = record['id'];
        merchant_id = record['merchant_id'];
        store_id = record['store_id'];
        name = record['name'];
        category = record['category'];
        currency_code = record['currency_code'];
        variants = record['variants'];
        price = record['price'].toString();
        offers = record['offers'];
        discount = record['discount'];
        description = record['description'];
        sizeAdded(variants);
        var qty = int.parse(record['qty']);
        linkUrlList = record['urls'] as List;
        if (linkUrlList.length > 0) {
          eventLink = linkUrlList
              .map<linkEvent>((json) => linkEvent.fromJson(json))
              .toList();
        }
        if (qty > 0) {
          if (mounted)
            setState(() {
              qtyCheck = qty;
            });
        }
        status = record['status'];
        imgs = record['imgs'];
        linkShare = record['link'];
        offfer_price = record['offfer_price'];
        setState(() {
          dataAvaialble = true;
        });
        var cart_qty = prefs.getString('cart_qty') ?? "0";
        if (cart_qty == 'null') {
        } else {
          if (int.parse(cart_qty) > 0) {
            cardCountNotVisible = false;
            cardCount = int.parse(cart_qty);
          }
        }
      } else if (status == unauthorized_status) {
        await checkLoginStatus(context);
      } else if (status == already_login_status) {
        _showToast(message);
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        getDetail();
      } else {
        _showToast(message);
      }
      setState(() {
        dataLoad = true;
      });
//      _showToast(message);
    }
  }

  void _showToast(String mesage) {
    Fluttertoast.showToast(
        msg: mesage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  goToCart(context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Hero(
          tag: 'go to bag',
          child: Row(
            children: <Widget>[
              Expanded(
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  buttonColor: AppColours.appOrangeColour,
                  child: MaterialButton(
                    color: AppColours.appOrangeColour,
                    elevation: 16.0,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColours.appOrangeColour),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    onPressed: () async {
                      navigateCartPage(context);
                    },
                    child: Text(
                      allTranslations.text('GoToCart'),
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  outOfStock(context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Hero(
          tag: 'out of stock',
          child: Row(
            children: <Widget>[
              Expanded(
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  buttonColor: AppColours.whiteColour,
                  child: MaterialButton(
                    color: AppColours.whiteColour,
                    elevation: 16.0,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColours.redColour),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    onPressed: () {},
                    child: Text(
                      allTranslations.text('OutOfStock'),
                      style: TextStyle(
                          fontSize: 16.0, color: AppColours.redColour),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  addToCartButton(context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Hero(
          tag: 'registration',
          child: Row(
            children: <Widget>[
              Expanded(
                child: ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  buttonColor: AppColours.appTheme,
                  child: MaterialButton(
                    elevation: 16.0,
                    color: AppColours.appTheme,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColours.appTheme),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    onPressed: () async {
                      if (!loading) validationCheck('');
                    },
                    child: loading
                        ? CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Text(
                            allTranslations.text('AddToCart'),
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Future<void> validationCheck(action) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      if (ProductSizesList.length > 0 && SizeSelected == 0) {
        _showToast(allTranslations.text("select_size_message"));
      } else if (ProductColorsList.length > 0 && colourSelected == 0) {
        _showToast(allTranslations.text("select_color_message"));
      } else {
        callUSerStatusCheck(action, '');
      }
    }
  }

  void callUSerStatusCheck(action, type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      cardCountNotVisible = true;
      loading = true;
    });
    Map map = {
      "product_id": widget.product_id,
      "quantity": "+1",
      "action": action,
      "selected_size": SizeSelected.toString(),
      "selected_color": colourSelected.toString()
    };
    Map decoded = jsonDecode(
      await apiRequest(addtoCartUrl, map, context),
    );
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      if (type == 'update') {
        setState(() {
          cardCount = 1;
          addToCart = false;
          prefs.setString('cart_qty', '1');
        });
      } else {
        setState(() {
          cardCount = cardCount + 1;
          addToCart = false;
          prefs.setString('cart_qty', cardCount.toString());
        });
      }
    } else if (status == already_added_in_cart) {
      _cartRemoveAndUpdate(message);
    } else if (status == unauthorized_status) {
    } else if (status == already_login_status) {
    } else if (status == "408") {
      callUSerStatusCheck(action, type);
    } else {
      _showToast(message);
    }
    setState(() {
      cardCountNotVisible = false;
      loading = false;
    });
  }

  Future<bool> _cartRemoveAndUpdate(String message) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            allTranslations.text('Are_you_sure'),
          ),
          content: Text(
            message,
          ),
          actions: <Widget>[
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('no'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            MaterialButton(
              elevation: 0.0,
              child: Text(
                allTranslations.text('yes'),
                style: TextStyle(color: AppColours.appTheme),
              ),
              onPressed: () {
                callUSerStatusCheck('1', 'update');
                Navigator.of(context).pop(false);
              },
            )
          ],
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(10.0),
          ),
        );
      },
    );
    return Future.value(false);
  }

  List<T> mapSlider<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  void navigateCartPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetail(
          campaignData: widget.campaignData ?? {},
        ),
      ),
    );
  }

  priceSet() {
    if (record['applyed_offer']['amount_unit'].toString() == '1') {
      return Row(
        children: [
          Expanded(
            flex: 9,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Text(
                currency_code.toString() + " " + price,
                style: TextStyle(
                  fontSize: 16.0,
                  decoration: TextDecoration.lineThrough,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Text(
                record['applyed_offer']['offer_amount'].toString() + " % Off",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColours.appTheme,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 9,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Text(
                currency_code.toString() + " " + price,
                style: TextStyle(
                  fontSize: 16.0,
                  decoration: TextDecoration.lineThrough,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  record['applyed_offer']['amount_currency'].toString() +
                      " " +
                      record['applyed_offer']['offer_amount'].toString() +
                      " off",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColours.appTheme,
                  ),
                  textAlign: TextAlign.start,
                )),
          ),
        ],
      );
    }
  }

  offerCheck() {
    if (offers == 'null') {
      return Text(
        currency_code + " " + price,
        style: TextStyle(fontSize: 16.0),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          priceSet(),
          spaceHeight(),
          Text(
            currency_code + " " + record['offfer_price'],
            style: TextStyle(fontSize: 16.0),
          )
        ],
      );
    } else {
      if (offers.toString() != "[]") {
        return Row(
          children: [
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  currency_code + " " + price,
                  style: TextStyle(
                    fontSize: 16.0,
                    decoration: TextDecoration.lineThrough,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  currency_code + " " + offfer_price.toString(),
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        );
        ;
      } else {
        return Text(
          currency_code + " " + price,
          maxLines: 1,
          style: TextStyle(
            fontSize: 15.0,
            color: AppColours.blackColour,
          ),
        );
      }
    }
  }

  productSizeFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductSizesList.length > 0
                ? Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                    child: Text(
                      allTranslations.text("product_size"),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            ProductSizesList.length > 0
                ? Container(
                    height: 40.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ProductSizesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return listProductSizesItems(
                          ProductSizesList,
                          index,
                          context,
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            ProductColorsList.length > 0
                ? productColourFiled()
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  listProductSizesItems(
    List<Map> productSizesList,
    int index,
    BuildContext context,
  ) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: SelectionSize(
                productSizesList,
                int.parse(productSizesList[index]['id']),
              ),
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              child: Text(
                productSizesList[index]['name'],
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        if (mounted) {
          setState(() {
            SizeSelected = int.parse(productSizesList[index]['id']);
            ColourAddingList(productSizesList[index]['colors']);
          });
        }
      },
    );
  }

  SelectionSize(List<Map<dynamic, dynamic>> productSizesList, int index) {
    if (SizeSelected == index) {
      return Colors.black;
    } else {
      return Colors.grey;
    }
  }

  void ColourAddingList(productSizesList) {
    if (mounted) {
      setState(() {
        ProductColorsList = [];
        for (int i = 0; i < productSizesList.length; i++) {
          ProductColorsList.add({
            "id": productSizesList[i]['id'],
            "option_name": productSizesList[i]['option_name'],
            "option_value": productSizesList[i]['option_value'],
          });
        }
      });
    }
  }

  productColourFiled() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 20.0, 10.0, 10.0),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
              child: Text(
                allTranslations.text("product_color"),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            new Container(
              height: 40.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ProductColorsList.length,
                itemBuilder: (BuildContext context, int index) {
                  return listColorItems(ProductColorsList, index, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  listColorItems(List<Map> colorListJson, int index, BuildContext context) {
    var colour = "0xff" +
        colorListJson[index]['option_value'].toString().replaceAll("#", "");
    return InkWell(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
        child: CircleAvatar(
          backgroundColor: SelectionColour(
              colorListJson, int.parse(colorListJson[index]['id'])),
          radius: 20.0,
          child: CircleAvatar(
            backgroundColor: Color(
              int.parse(colour),
            ),
            radius: 18,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          colourSelected = int.parse(colorListJson[index]['id']);
        });
      },
    );
  }

  SelectionColour(List<Map<dynamic, dynamic>> colorListJson, int index) {
    if (colourSelected == index) {
      return Colors.black;
    } else {
      return Colors.transparent;
    }
  }

  void sizeAdded(variants) {
    if (mounted)
      setState(
        () {
          ProductSizesList = [];
          ProductColorsList = [];
          if (variants.length > 0) {
            var product_sizes = variants['product_sizes'];
            ProductSizesList = [];
            ProductColorsList = [];
            for (int i = 0; i < product_sizes.length; i++) {
              ProductSizesList.add(
                {
                  "id": product_sizes[i]['id'],
                  "name": product_sizes[i]['option_name'],
                  "option_value": product_sizes[i]['option_value'],
                  "colors": product_sizes[i]['colors'],
                },
              );
            }
            if (product_sizes.toString() != "[]")
              ColourAddingList(product_sizes[0]['colors']);
          }
        },
      );
  }
}
