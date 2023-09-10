import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/credential.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/StoreModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/screens/Item/detailPayment.dart';
import 'package:avauserapp/screens/product/StoreItemsListShop.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'baseTabClass.dart';

class StoreDetail extends StatefulWidget {
  @override
  _StoreDetail createState() => _StoreDetail();
}

class _StoreDetail extends State<StoreDetail>
    with AutomaticKeepAliveClientMixin<StoreDetail> {
  var dataLoad = false;
  var dataFound = true;
  var STORES = "";
  List<StoreModel> _listRecently = [];
  List<StoreModel> _listTrends = [];
  List<StoreModel> _listOther = [];
  List<bool> inputsRecently = [];
  List<bool> inputsTrends = [];
  List<bool> inputsOther = [];
  var cardCount = 0;
  var cardCountNotVisible = true;
  var itemChangeLoadding = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  var userId = "",
      profilePic = "",
      userFullName = "",
      userEmail = "",
      userImage = "";
  var _locationPick = true;
  TextEditingController serchCityController = TextEditingController();
  var showSearch = true;
  var city = "";

  bool? get vas => null;

  Future<void> ItemChangeLikeStatus(
      List list, List input, bool val, int index) async {
    setState(() {
      itemChangeLoadding = true;
    });
    bool? success = await getDetail(!val, list[index].id, context);

    setState(() {
      if (success != null) {
        if (success) if (val == true) {
          input[index] = false;
        } else {
          input[index] = true;
        }
        itemChangeLoadding = false;
      }
    });
    validationCheck();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    myLangGet();
    validationCheck();
  }

  Future<void> myLangGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? "";
      userId = prefs.getString('id') ?? "";
      userFullName = prefs.getString('full_name') ?? "";
      userImage = prefs.getString('image') ?? "";
      var cart_qty = prefs.getString('cart_qty') ?? "0";
      if (cart_qty == 'null') {
      } else {
        if (int.parse(cart_qty) > 0) {
          cardCountNotVisible = false;
          cardCount = int.parse(cart_qty);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        drawer: dataLoad
            ? drawerData(
                context, userId, profilePic, userFullName, userEmail, userImage)
            : Text(allTranslations.text('STORES')),
        appBar: AppBar(
          title: Text(
            allTranslations.text('STORES'),
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            /*_locationPick
                ? IconButton(
              onPressed: () {
                setState(() {
                  _locationPick = false;
                });
              },
              icon: Icon(
                Icons.location_on,
                color: AppColours.appTheme,
                size: 32.0,
              ),
            ): IconButton(
              onPressed: () {
                setState(() {
                  _locationPick = true;
                });
              },
              icon: Icon(
                Icons.location_off,
                color: AppColours.blacklightLineColour,
                size: 32.0,
              ),
            ),*/
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
                          if (cardCount > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentDetail(
                                        campaignData: {},
                                      )),
                            );
                          } else {
                            _showToast(allTranslations.text("NoItemFound"));
                          }
                        },
                      ))),
            )
          ],
          // actions: <Widget>[
          //   IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => NotificationTabs()),
          //       );
          //     },
          //     icon: Icon(
          //       Icons.notifications_active,
          //       color: AppColours.appTheme,
          //     ),
          //   )
          // ],
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: <Widget>[
            dataLoad
                ? dataFound
                    ? RefreshIndicator(
                        key: refreshKey,
                        onRefresh: myLangGet,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _locationPick
                                  ? SizedBox.shrink()
                                  : locationPickAddress(context),
                              _listRecently.length > 0
                                  ? RecentlyColumn()
                                  : SizedBox.shrink(),
                              _listTrends.length > 0
                                  ? TrendsColumn()
                                  : SizedBox.shrink(),
                              _listOther.length > 0
                                  ? OtherColumn()
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        key: refreshKey,
                        onRefresh: myLangGet,
                        child: Container(
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              child: Center(
                                  child: Image.asset(
                                      "assets/noproductfound.webp")),
                            ),
                          ),
                        ),
                      )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                      child: Center(
                        child: Image.asset("assets/storeloadding.gif"),
                      ),
                    ),
                  ),
            itemChangeLoadding
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox.shrink()
          ],
        ));
  }

  Widget horizontalList1 = new Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 200.0,
      child: new ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          Container(
            width: 160.0,
            color: Colors.red,
          ),
          Container(
            width: 160.0,
            color: Colors.orange,
          ),
          Container(
            width: 160.0,
            color: Colors.pink,
          ),
          Container(
            width: 160.0,
            color: Colors.yellow,
          ),
        ],
      ));

  listItems(
      List<StoreModel> list, input, int index, type, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3.9,
      width: MediaQuery.of(context).size.width - 20,
      child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
          child: GestureDetector(
            child: Card(
              child: Container(
                height: MediaQuery.of(context).size.height / 2.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                      color: Colors.blue,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: '${list[index].store_logo}',
                            fit: BoxFit.fill,
                            placeholder: (context, url) =>
                                imageShimmer(context, 48.0),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/nodata.webp",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(0.0),
                            child: Align(
                                alignment: Alignment.topRight,
                                child: likeButtonShow(list, input, index)),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child: Text(
                        list[index].store_name,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 16,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 0.0, 10.0, 0.0),
                            child: Wrap(
                              children: <Widget>[
                                Text(
                                  list[index].store_address,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: AppColours.blacklightLineColour,
                                      height:
                                          1.5 //You can set your custom height here
                                      ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async {
              List list = [];
              if (type == "Recently") {
                list = _listRecently;
              }
              if (type == "Trends") {
                list = _listTrends;
              }
              if (type == "Other") {
                list = _listOther;
              }
              productNavigate(list, index);
            },
          )),
    );
  }

  Future<void> validationCheck() async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck();
    }
  }

  void callUSerStatusCheck() async {
    Map map = {"page_no": "", "search": "", "merchant_id": "", "category": ""};
    Map decoded = jsonDecode(await apiRequestMainPage(recentallStoresUrl, map));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var recently = decoded['record']['recently'];
      var trends = decoded['record']['trends'];
      var other = decoded['record']['other'];
      if (mounted)
        setState(() {
          _listRecently = [];
          _listTrends = [];
          _listOther = [];
          inputsRecently = [];
          inputsTrends = [];
          inputsOther = [];
        });
      _listRecently = recently
          .map<StoreModel>((json) => StoreModel.fromJson(json))
          .toList();
      _listTrends =
          trends.map<StoreModel>((json) => StoreModel.fromJson(json)).toList();
      _listOther =
          other.map<StoreModel>((json) => StoreModel.fromJson(json)).toList();
      likeCountSet(_listRecently, _listTrends, _listOther);
      if (_listRecently.length > 0 ||
          _listTrends.length > 0 ||
          _listOther.length > 0) {
        if (mounted)
          setState(() {
            dataFound = true;
          });
      } else {
        setState(() {
          dataFound = false;
        });
      }
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == already_login_status) {
      _showToast(message);
    } else if (status == data_not_found_status) {
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      callUSerStatusCheck();
    } else {
      _showToast(message);
    }
    if (mounted)
      setState(() {
        dataLoad = true;
      });
  }

  Widget recentlyList(_list, input, type) {
    return Container(
        height: MediaQuery.of(context).size.height / 2.3,
        width: MediaQuery.of(context).size.width - 10,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: _list.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    return listItems(_list, input, index, type, context);
                  }),
              _list.length > 4
                  ? GestureDetector(
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 2.6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height / 3.5,
                                width: MediaQuery.of(context).size.width / 2,
                                color: Colors.white,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        allTranslations.text('SeeMore'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                      Icon(Icons.keyboard_arrow_right)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        var typeset = '1';
                        if (type == "Recently") {
                          typeset = '3';
                        }
                        if (type == "Trends") {
                          typeset = '2';
                        }
                        if (type == "Other") {
                          typeset = '1';
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StoreShopDetail(
                                    type: typeset,
                                    // merchant_id: widget.categoryList[index]['merchant_id'],
                                    merchant_id: '',
                                    category: '',
                                    isFav: false,
                                  )),
                        );
                      },
                    )
                  : SizedBox.shrink()
            ],
          ),
        ));
  }

  textHeader(String textHeader) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Text(
        textHeader,
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget RecentlyColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textHeader(allTranslations.text('Recently')),
        recentlyList(_listRecently, inputsRecently, "Recently")
      ],
    );
  }

  Widget TrendsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textHeader(allTranslations.text('Trends')),
        recentlyList(_listTrends, inputsTrends, "Trends")
      ],
    );
  }

  Widget OtherColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        textHeader(allTranslations.text('Discounts')),
        recentlyList(_listOther, inputsOther, "Other")
      ],
    );
  }

  void likeCountSet(_listRecently, _listTrends, _listOther) {
    for (int i = 0; i < _listRecently.length; i++) {
      if (_listRecently[i].is_favourite == 1 ||
          _listRecently[i].is_favourite == "1") {
        inputsRecently.add(true);
      } else {
        inputsRecently.add(false);
      }
    }
    for (int i = 0; i < _listTrends.length; i++) {
      if (_listTrends[i].is_favourite == 1 ||
          _listTrends[i].is_favourite == "1") {
        inputsTrends.add(true);
      } else {
        inputsTrends.add(false);
      }
    }
    for (int i = 0; i < _listOther.length; i++) {
      if (_listOther[i].is_favourite == 1 ||
          _listOther[i].is_favourite == "1") {
        inputsOther.add(true);
      } else {
        inputsOther.add(false);
      }
    }
  }

  likeButtonShow(list, input, index) {
    return SizedBox(
      height: 40.0,
      width: 50.0,
      child: GestureDetector(
        child: Icon(
          Icons.favorite,
          size: 35,
          color: input[index] ? Colors.red : Colors.black38,
        ),
        onTap: () {
          ItemChangeLikeStatus(list, input, input[index], index);
        },
      ),
    );
  }

  Future<void> productNavigate(List list, int index) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Product(
              storeName: list[index].store_name,
              Id: list[index].id,
              isFav: false)),
    );
    if (result == null) {
    } else {
      setState(() {
        myLangGet();
      });
    }
  }

  Widget locationPickAddress(BuildContext context) {
    return Container(
      child: Card(
        elevation: 4,
        color: AppColours.whiteColour,
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: TextFormField(
                controller: serchCityController,
                decoration: InputDecoration(
                    hintText: allTranslations.text("Enter_your_City")),
                onChanged: (textdata) {
                  var data = textdata.toString().trim();
                  if (data.length > 0) {
                    setState(() {
                      showSearch = false;
                    });
                    city = serchCityController.text.toString();
                  } else {
                    setState(() {
                      showSearch = true;
                    });
                  }
                },
              ),
            ),
            showSearch
                ? Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40.0,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: FloatingActionButton(
                          heroTag: "location_on",
                          onPressed: () {
                            addressSearch(context);
                          },
                          backgroundColor: AppColours.blacklightColour,
                          child: Icon(
                            Icons.location_on,
                            color: AppColours.appTheme,
                          ),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 40.0,
                      child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: FloatingActionButton(
                          heroTag: "location_on",
                          onPressed: () {
                            callUSerStatusCheck();
                            FocusScope.of(context).unfocus();
                          },
                          backgroundColor: AppColours.blacklightColour,
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColours.appTheme,
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
      color: AppColours.blacklightColour,
    );
  }

  Future<void> addressSearch(context) async {
    LocationResult result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PlacePicker(googlePlaceKey)));
    Map decoded = await AddressFilter(result);
    // var latitude = result.latLng.latitude;
    // var longitude = result.latLng.longitude;
    setState(() {
      city = decoded['city'].toString();
      serchCityController.text = city;
    });
    callUSerStatusCheck();
  }
}

Future<bool?> onLikeButtonTapped(bool isLiked, [vas]) async {
  /// send your request here
  // bool success = await getDetail(isLiked, "Id");
  // return success ? !isLiked : isLiked;
}
/*

class HorizontalList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HorizontalViewState();
  }
}

class _HorizontalViewState extends State<HorizontalList> {
  final List<String> images = <String>[
    "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT4FDQbhlykwH2rdxf2eRB6k4Abdz3EDcaaO24E-vBTzqCyH1g8&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTFzogPZ2STZhoWqT10bk2R1cknBOxT5HCDJEs3cTCvt5hF3dLX&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR2G9e6_BvREp89RagzvPyvf1X78kg17TCnRcqXng-F0bQqz5nP&usqp=CAU",
  ];

  final List<String> categories = <String>[
    "Shopping",
    "Fashion",
    "Electronics",
    "Shoes",
  ];
  List<StoreModel> _list =[];
  var dataFound = false;
  var dataLoad = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: ListView.builder(
        itemCount: images.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 5.0),
              child: GestureDetector(
                child: Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 260,
                        width: MediaQuery.of(context).size.width - 20,
                        color: Colors.blue,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: '${images[index]}',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  imageShimmer(context, 48.0),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/nodata.webp",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "Crazy catz",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Icon(Icons.location_on),
                          Text("301 old palasia,Indore")
                        ],
                      )
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductItems()),
                  );
                },
              ));
        },
      ),
    );
  }
}
*/

void _showToast(String mesage) {
  Fluttertoast.showToast(
      msg: mesage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0);
}

Future<bool?> getDetail(bool isLiked, String Id, context) async {
  var callUserLoginCheck = await internetConnectionState();
  if (callUserLoginCheck == true) {
/*      Map map = {
        "store_id": Id,
        "product_id": "",
        "status": isLiked.toString()
      };*/

    var api = favUnfavoriteStoreUrl + Id;
    Map decoded = jsonDecode(await getApiDataRequest(api, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var recordStatus = decoded['record']['status'].toString();
      return true;
    } else if (status == unauthorized_status) {
      return false;
    } else if (status == already_login_status) {
      return false;
    } else if (status == expire_token_status) {
      Map decoded = jsonDecode(await apiRefreshRequest(context));
      getDetail(isLiked, Id, context);
    } else {
      _showToast(message);
      return false;
    }
  }
}
