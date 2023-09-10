import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/CategoryModel.dart';
import 'package:avauserapp/components/models/ProductModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ProductItemDetail.dart';

class Product extends StatefulWidget {
  Product({Key? key, this.storeName, this.Id, this.isFav, this.campaignData})
      : super(key: key);
  var storeName;
  var Id;
  var isFav;
  Map? campaignData;

  @override
  _StoreItemDetail createState() => _StoreItemDetail();
}

class _StoreItemDetail extends State<Product> {
  var dataLoad = false;
  var STORES = "";
  Map? myLang;
  var dataFound = false;
  List<ProductModel> _list = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List<bool> inputsRecently = [];
  var page_no = 1;
  var itemChangeLoadding = false;
  RangeValues _currentRangeValues = RangeValues(0, 100);
  var filterShow = false;
  var start_range = '1';
  var end_range = '1';
  var category;
  List<CategoryModel> _listCategory = [];
  var categoryId = '';
  var categorySelect = '';
  var minPriceSelect = '';
  var maxPriceSelect = '';
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
          Navigator.pop(context, "data");
          return Future.value(false);
        },
        child: new Scaffold(
            appBar: widget.isFav
                ? null
                : AppBar(
                    title: Text(
                      widget.storeName,
                      style: TextStyle(color: Colors.black),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context, "data");
                      },
                    ),
                    iconTheme: IconThemeData(color: Colors.black),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    actions: [
                      filterShow
                          ? IconButton(
                              icon: Icon(Icons.filter_list),
                              onPressed: () {
                                setData('', '', '', '');
                                double startRange = 1;
                                double endRange = 1;
                                startRange =
                                    double.parse(start_range.toString());
                                endRange = double.parse(end_range.toString());
                                _currentRangeValues =
                                    RangeValues(startRange, endRange);
                                showModal(context, startRange, endRange,
                                    _listCategory);
                              },
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
            body: Stack(
              children: <Widget>[
                dataLoad
                    ? dataFound
                        ? RefreshIndicator(
                            key: refreshKey,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!isLoading &&
                                    scrollInfo.metrics.pixels ==
                                        scrollInfo.metrics.maxScrollExtent) {
                                  callUSerStatusCheck();
                                  // start loading data
                                  setState(() {
                                    isLoading = true;
                                  });
                                  return false;
                                } else {
                                  return false;
                                }
                              },
                              child: GridView.count(
                                  crossAxisCount: 2,
                                  childAspectRatio: (itemWidth / itemHeight),
                                  children:
                                      List.generate(_list.length, (index) {
                                    return Center(
                                      child: listItems(_list, inputsRecently,
                                          index, context, itemHeight),
                                    );
                                  })),
                            ),
                            onRefresh: validationCheck,
                          )
                        : RefreshIndicator(
                            key: refreshKey,
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
                            onRefresh: validationCheck,
                          )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Center(
                          child: Image.asset("assets/storeloadding.gif"),
                        ),
                      ),
                itemChangeLoadding
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox.shrink()
              ],
            )));
  }

  Future<void> validationCheck() async {
    if (mounted)
      setState(() {
        page_no = 1;
        _list = [];
      });
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck();
    }
  }

  void callUSerStatusCheck() async {
    Map map = {
      "store_id": widget.Id,
      "category": categoryId,
      "page_no": page_no,
      "search": "",
      "min_price": minPriceSelect,
      "max_price": maxPriceSelect
    };
    Map decoded = jsonDecode(await apiRequest(productlistUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var data = decoded['record']['data'];
      if (page_no == 1) {
        var filters = decoded['filters'];
        var priceRange = filters['priceRange'];
        setState(() {
          category = filters['category'] as List;
          _listCategory = category
              .map<CategoryModel>((json) => CategoryModel.fromJson(json))
              .toList();
          start_range = priceRange['start_range'];
          end_range = priceRange['end_range'];
          filterShow = true;
        });
      }
      List<ProductModel> _listGet = [];
      _listGet = data
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
      _list.addAll(_listGet);
      if (_list.length > 0) {
        setState(() {
          dataFound = true;
        });
      }
      likeCountSet(_list);
      page_no = page_no + 1;
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == data_not_found_status) {
      if (page_no == 1)
        setState(() {
          dataFound = false;
        });
    } else if (status == already_login_status) {
      _showToast(message);
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      callUSerStatusCheck();
    } else {
      _showToast(message);
    }
    setState(() {
      dataLoad = true;
    });
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

  listItems(_list, input, index, context, itemHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductItemAllDetail(product_id: _list[index].id)),
        );
      },
      child: Padding(
          padding: EdgeInsets.all(2.0),
          child: Container(
              color: Colors.white,
              child: Padding(
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
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  "assets/nodata.webp",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(0.0),
                              child: Align(
                                  alignment: Alignment.topRight,
                                  child: likeButtonShow(_list, input, index)),
                            )
                          ],
                        ),
                        width: MediaQuery.of(context).size.width),
                    Expanded(
                      // height: itemHeight / 5.4,
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
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
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
              ))),
    );
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

  Future<void> ItemChangeLikeStatus(
      List list, List input, bool val, int index) async {
    setState(() {
      itemChangeLoadding = true;
    });

    bool? success = await getDetail(!val, list[index].store_id, list[index].id);

    setState(() {
      if (success != null) {
        if (success) if (val == true) {
          input[index] = false;
        } else {
          input[index] = true;
        }
      }
      itemChangeLoadding = false;
    });
  }

  Future<bool?> getDetail(
      bool isLiked, String storeId, String productId) async {
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      var api = favUnfavoriteProductUrl + productId;
      Map decoded = jsonDecode(await getApiDataRequest(api, context));
      String status = decoded['status'];
      String message = decoded['message'];
      if (status == success_status) {
        decoded['record']['status'].toString();
        return true;
      } else if (status == unauthorized_status) {
        return false;
      } else if (status == already_login_status) {
        return false;
      } else if (status == expire_token_status) {
        jsonDecode(await apiRefreshRequest(context));
        getDetail(isLiked, storeId, productId);
      } else {
        _showToast(message);
        return false;
      }
    }
  }

  void likeCountSet(_list) {
    for (int i = 0; i < _list.length; i++) {
      if (_list[i].is_favourite == 1 || _list[i].is_favourite == "1") {
        inputsRecently.add(true);
      } else {
        inputsRecently.add(false);
      }
    }
  }

  void showModal(context, startRange, endRange, _listCategory) {
    var listShow = false;
    // var heightDefault = 300.0;
    var divisions = 5;
    var range = endRange - startRange;
    if (range > 15) {
      divisions = 10;
    } else {
      if (range > 5) {
        divisions = 10;
      } else {
        divisions = 5;
      }
    }
    var categoryhint = "Select Category Range";
    var categoryName = categoryhint;
    var categoryId = "";
    List<int> _radioValue = [];

    /*  void _handleRadioValueChange(int value,index) {

      setState(() {

        _radioValue[index] = value;
      });
   }*/
    _listCategory.forEach((m) {
      _radioValue.add(1);
//like N or something
    });
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBar(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      centerTitle: true,
                      leading: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppColours.blacklightLineColour,
                        ),
                      ),
                      title: Text(
                        allTranslations.text('Filter'),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    /*  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: 0,
                          groupValue: _radioValue,
                          onChanged: (value) {
                            stateSetter(() {
                              _radioValue = value;
                            });

                            _handleRadioValueChange(value);
                          },
                        ),
                        Text(
                          'Single Date',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: (value) {
                            stateSetter(() {
                              _radioValue = value;
                            });

                            _handleRadioValueChange(value);
                          },
                        ),
                        Text(
                          'Dual Date',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),*/
                    GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                listShow ? categoryhint : categoryName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(listShow
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        stateSetter(() {
                          categoryName = categoryhint;
                          listShow = !listShow;
                          // heightDefault = listShow
                          //     ? MediaQuery.of(context).size.height
                          //     : 300.0;
                        });
                      },
                    ),
                    listShow
                        ? ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _listCategory.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 10.0, 10.0, 10.0),
                                    child: GestureDetector(
                                      child: Text(
                                        _listCategory[index].name,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColours.appTheme,
                                            fontSize: 20.0),
                                      ),
                                      onTap: () {
                                        stateSetter(() {
                                          _radioValue[index] = 0;
                                          categoryName =
                                              _listCategory[index].name;
                                          categoryId = _listCategory[index].id;

                                          listShow = !listShow;
                                        });
                                      },
                                    )),
                              );
                            })
                        : SizedBox.shrink(),
                    Divider(
                      height: 1.0,
                      color: AppColours.blacklightColour,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      child: Text(
                        "Select Price",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    ),
                    RangeSlider(
                      values: _currentRangeValues,
                      min: startRange,
                      max: endRange,
                      divisions: divisions,
                      labels: RangeLabels(
                        _currentRangeValues.start.round().toString(),
                        _currentRangeValues.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        stateSetter(() => _currentRangeValues = values);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: AppColours.appTheme)),
                          onPressed: () {
                            var categorySelected = '';
                            var minPriceSelect =
                                _currentRangeValues.start.round().toString();
                            var maxPriceSelect =
                                _currentRangeValues.end.round().toString();
                            if (categoryName != categoryhint) {
                              categorySelected = categoryName;
                            }
                            setData(categoryId, categorySelected,
                                minPriceSelect, maxPriceSelect);
                            Navigator.pop(context);
                          },
                          color: AppColours.appTheme,
                          textColor: Colors.white,
                          child: Text(allTranslations.text('Ok').toUpperCase(),
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )),
          );
        });
  }

  void setData(categoryIdSelected, category, minPrice, maxPrice) {
    setState(() {
      categoryId = categoryIdSelected;
      categorySelect = category;
      minPriceSelect = minPrice;
      maxPriceSelect = maxPrice;
    });
    if (category != '' || minPrice != '' || maxPrice != '') {
      validationCheck();
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

class HorizontalList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HorizontalViewState();
  }
}

class _HorizontalViewState extends State<HorizontalList> {
  final List<String> images = <String>[
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRc-7cHH9YpmnE6U-UrpN2Vm74ov70Ht4TU1QnJiMlIw1R8hA4y&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRmpDo41KS70hJmUN21qi6ZbLHgFqgsDmdgcuZaxLFeuh9giLzN&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQbdVuLmWT8hY28UcS_E2dLCGW7vYPNjx5q26IpYI5pNghJpQLl&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSjbz6-d1FAHpD_cf9AI_9I2u9GCenZ16KRcRkAIbwn24hPl2bb&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTPPeHurB2nDs6IYcpYEW5l64iVB5e64J9lkfIPcVa_KXyDlYUD&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT4FDQbhlykwH2rdxf2eRB6k4Abdz3EDcaaO24E-vBTzqCyH1g8&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTFzogPZ2STZhoWqT10bk2R1cknBOxT5HCDJEs3cTCvt5hF3dLX&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR2G9e6_BvREp89RagzvPyvf1X78kg17TCnRcqXng-F0bQqz5nP&usqp=CAU",
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 2;
    return Text('');
  }
}
