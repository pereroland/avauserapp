import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/models/CategoryModel.dart';
import 'package:avauserapp/components/models/StoreModel.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/screens/home/stores.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/language/languageSelected.dart';

class StoreShopDetail extends StatefulWidget {
  StoreShopDetail({
    Key? key,
    this.type,
    this.merchant_id,
    this.category,
    this.isFav,
  }) : super(key: key);
  var type, merchant_id, category, isFav;

  @override
  _ItemsDetail createState() => _ItemsDetail();
}

class _ItemsDetail extends State<StoreShopDetail> {
  var dataLoad = false;
  var Detail = "";
  var Online = "";
  var StorePickup = "";
  var PaymentInfo = "";
  var PriceDetails = "";
  var ListPrice = "";
  var itemChangeLoadding = false;
  var SellingPrice = "";
  var Total = "";
  Map? myLang;
  int? selectedRadio;
  List<StoreModel> _list = [];
  var dataFound = false;
  List<bool> inputsRecently = [];
  var page_no = 1;
  var category;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var userId = "", userImage = "", userFullName = "", userEmail = "";
  RangeValues _currentRangeValues = RangeValues(0, 100);
  List<CategoryModel> _listCategory = [];
  var filterShow = false;
  var start_range = '1';
  var end_range = '1';
  bool isLoading = false;

/*
  var categoryId = '';
*/
  var categoryCheck = '';
  var categorySelect = '';
  var minPriceSelect = '';
  var maxPriceSelect = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedRadio = 1;
    myLangGet();
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 1.8;

    return new Scaffold(
      appBar: widget.isFav
          ? null
          : AppBar(
              title: Text(
                allTranslations.text('STORES'),
                style: TextStyle(color: Colors.black),
              ),
              actions: [
                filterShow
                    ? IconButton(
                        icon: Icon(Icons.filter_list),
                        onPressed: () {
                          // setData('', '', '', '');
                          double startRange = 1;
                          double endRange = 1;
                          startRange = double.parse(start_range.toString());
                          endRange = double.parse(end_range.toString());
                          _currentRangeValues =
                              RangeValues(startRange, endRange);
                          showModal(
                              context, startRange, endRange, _listCategory);
                        },
                      )
                    : SizedBox.shrink(),
              ],
              iconTheme: IconThemeData(color: Colors.black),
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
      body: dataLoad
          ? dataFound
              ? Container(
                  child: RefreshIndicator(
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
                      }
                      return false;
                    },
                    child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: (itemWidth / itemHeight),
                        children: List.generate(_list.length, (index) {
                          return Center(
                            child: listItems(_list, index, context, itemHeight),
                          );
                        })),
                  ),
                  onRefresh: validationCheck,
                ))
              : RefreshIndicator(
                  key: refreshKey,
                  child: Container(
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Image.asset(
                                "assets/noproductfound.webp",
                              ),
                            ),
                            Text(
                              allTranslations.text("no_store_found"),
                              style: TextStyle(fontSize: 20.0),
                            )
                          ],
                        ),
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
    );
  }

  Future<void> myLangGet() async {
    Map myLangData = await langTxt(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userEmail = prefs.getString('email') ?? "";
      userId = prefs.getString('id') ?? "";
      userFullName = prefs.getString('full_name') ?? "";
      userImage = prefs.getString('image') ?? "";
      myLang = myLangData;
      if (myLang != null) {
        Detail = myLang!['Detail'];
        Online = myLang!['Online'];
        StorePickup = myLang!['StorePickup'];
        PaymentInfo = myLang!['PaymentInfo'];
        PriceDetails = myLang!['PriceDetails'];
        ListPrice = myLang!['ListPrice'];
        SellingPrice = myLang!['SellingPrice'];
        Total = myLang!['Total'];
      }
      // categoryId = widget.category;
      categoryCheck = widget.category;
    });
    var check = myLangData['email'];
    validationCheck();
  }

  Future<void> validationCheck() async {
    page_no = 1;
    _list = [];
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck == true) {
      callUSerStatusCheck();
    }
  }

  void callUSerStatusCheck() async {
    Map map = {
      "category": categoryCheck,
      "page_no": page_no,
      "search": "",
      "type": widget.type,
      "merchant_id": widget.merchant_id
    };
    print("Objectssss:$map");
    Map decoded = jsonDecode(await apiRequest(listStoresUrl, map, context));
    String status = decoded['status'];
    String message = decoded['message'];
    if (status == success_status) {
      List<StoreModel> _listGet = [];
      var data = decoded['record']["data"];
      _listGet =
          data.map<StoreModel>((json) => StoreModel.fromJson(json)).toList();
      _list.addAll(_listGet);
      if (_list.length > 0) {
        if (mounted)
          setState(() {
            dataFound = true;
          });
        likeCountSet(_list);
      }
      if (page_no == 1) {
        var filters = decoded['filterCategories'];
        // var priceRange = filters['priceRange'];
        if (mounted)
          setState(() {
            category = filters as List;
            _listCategory = category
                .map<CategoryModel>((json) => CategoryModel.fromJson(json))
                .toList();
            // start_range = priceRange['start_range'];
            // end_range = priceRange['end_range'];
            filterShow = true;
          });
      }
      page_no = page_no + 1;
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
    if (_list.length < 1) {
      if (mounted)
        setState(() {
          dataFound = false;
        });
    }
    if (mounted)
      setState(() {
        dataLoad = true;
      });
  }

  listItems(_list, index, context, itemHeight) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Product(
                  storeName: _list[index].store_name,
                  Id: _list[index].id,
                  isFav: false)),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                    child: Stack(
                      children: <Widget>[
                        SizedBox(
                          height: itemHeight - itemHeight / 2.5,
                          width: MediaQuery.of(context).size.width / 2,
                          child: CachedNetworkImage(
                            imageUrl: _list[index].store_logo,
                            fit: BoxFit.fill,
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
                              child:
                                  likeButtonShow(_list, inputsRecently, index)),
                        )
                      ],
                    ),
                    width: MediaQuery.of(context).size.width / 2),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Align(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _list[index].store_name,
                                  style: TextStyle(fontSize: 20.0),
                                  maxLines: 1,
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  _list[index].store_address,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: AppColours.blacklightLineColour),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      alignment: Alignment.bottomRight,
                    ))
              ],
            ),
          ),
        ),
      ),
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
          ItemChangeLikeStatus(list, input, input[index], index, context);
        },
      ),
    );
  }

  Future<void> ItemChangeLikeStatus(
      List list, List input, bool val, int index, context) async {
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

  void likeCountSet(_list) {
    for (int i = 0; i < _list.length; i++) {
      if (_list[i].is_favourite == 1 || _list[i].is_favourite == "1") {
        inputsRecently.add(true);
      } else {
        inputsRecently.add(false);
      }
    }
  }

  void setData(categoryIdSelected, category, minPrice, maxPrice) {
    setState(() {
      // categoryId = categoryIdSelected;
      categoryCheck = categoryIdSelected;
      categorySelect = category;
      minPriceSelect = minPrice;
      maxPriceSelect = maxPrice;
    });
    if (category != '' || minPrice != '' || maxPrice != '') {
      validationCheck();
    } else {
      setState(() {
        // categoryId = widget.category;
        categoryCheck = widget.category;
        validationCheck();
      });
    }
  }

  void showModal(context, startRange, endRange, _listCategory) {
    var listShow = true;
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

    _listCategory.forEach((m) {
      _radioValue.add(1);
    });
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter stateSetter) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBar(
                        elevation: 0,
                        backgroundColor: AppColours.appTheme,
                        centerTitle: true,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.clear,
                            color: AppColours.whiteColour,
                          ),
                        ),
                        title: Text(
                          allTranslations.text('Filter'),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
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
                              /*Expanded(
                              flex: 1,
                              child: Icon(listShow
                                  ? Icons.expand_less
                                  : Icons.expand_more),
                            )*/
                            ],
                          ),
                        ),
                        onTap: () {
                          /*stateSetter(() {
                          categoryName = categoryhint;
                          listShow = !listShow;
                          // heightDefault = listShow
                          //     ? MediaQuery.of(context).size.height
                          //     : 300.0;
                        });*/
                        },
                      ),
                      listShow
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _listCategory.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var id = false;
                                        if (_listCategory[index].id ==
                                            categoryCheck) {
                                          id = true;
                                        }
                                        return Row(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: GestureDetector(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10.0,
                                                            10.0,
                                                            10.0,
                                                            10.0),
                                                    child: GestureDetector(
                                                      child: Text(
                                                        _listCategory[index]
                                                            .name,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: id
                                                                ? AppColours
                                                                    .appTheme
                                                                : AppColours
                                                                    .blackColour,
                                                            fontSize: 20.0),
                                                      ),
                                                      onTap: () {
                                                        stateSetter(() {
                                                          _radioValue[index] =
                                                              0;
                                                          categoryName =
                                                              _listCategory[
                                                                      index]
                                                                  .name;
                                                          categoryId =
                                                              _listCategory[
                                                                      index]
                                                                  .id;

                                                          listShow = !listShow;
                                                        });
                                                      },
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(
                                                  icon: Icon(
                                                    id
                                                        ? Icons.check_circle
                                                        : Icons
                                                            .radio_button_unchecked,
                                                    color: id
                                                        ? AppColours.appTheme
                                                        : AppColours
                                                            .blackColour,
                                                  ),
                                                  onPressed: () {
                                                    stateSetter(() {
                                                      _radioValue[index] = 0;
                                                      categoryName =
                                                          _listCategory[index]
                                                              .name;
                                                      categoryId =
                                                          _listCategory[index]
                                                              .id;

                                                      // listShow = !listShow;
                                                    });
                                                    var categorySelected = '';
                                                    var minPriceSelect =
                                                        _currentRangeValues
                                                            .start
                                                            .round()
                                                            .toString();
                                                    var maxPriceSelect =
                                                        _currentRangeValues.end
                                                            .round()
                                                            .toString();
                                                    if (categoryName !=
                                                        categoryhint) {
                                                      categorySelected =
                                                          categoryName;
                                                    }
                                                    if (categoryId == "") {
                                                      categoryId =
                                                          categoryCheck;
                                                    }
                                                    setData(
                                                        categoryId,
                                                        categorySelected,
                                                        minPriceSelect,
                                                        maxPriceSelect);
                                                    Navigator.pop(context);
                                                  }),
                                            )
                                          ],
                                        );
                                      }),
                                  categorySelect != ""
                                      ? Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10.0, 10.0, 10.0, 10.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  "Clear",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: IconButton(
                                                    icon: Icon(
                                                      Icons.cancel,
                                                      color:
                                                          AppColours.appTheme,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      setData('', '', '', '');
                                                    }),
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox.shrink()
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                      Divider(
                        height: 1.0,
                        color: AppColours.blacklightColour,
                      ),
                      /*Padding(
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
                    ),*/
                      /* Padding(
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
                            if (categoryId == "") {
                              categoryId = categoryCheck;
                            }
                            setData(categoryId, categorySelected,
                                minPriceSelect, maxPriceSelect);
                            Navigator.pop(context);
                          },
                          color: AppColours.appTheme,
                          textColor: Colors.white,
                          child: Text("Ok".toUpperCase(),
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ),*/
                    ],
                  );
                },
              ),
            ),
          );
        });
  }

/*
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

    */
/*  void _handleRadioValueChange(int value,index) {
      setState(() {

        _radioValue[index] = value;
      });

    }*/ /*

    _listCategory.forEach((m) {
      _radioValue.add(1);
//like N or something
    });
    showModalBottomSheet(
        isScrollControlled: true,
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
                    */
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
                    ),*/ /*

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
                          child: Text("Ok".toUpperCase(),
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
*/
}

/*class _ItemsDetail extends State<StoreShopDetail> {
  int page = 1;
  List<String> items = [
    'item 1',
    'item 2',
  ];
  bool isLoading = false;

  Future _loadData() async {
    // perform fetching data delay
    await new Future.delayed(new Duration(seconds: 2));

    // update data and loading status
    setState(() {
      items.addAll(['item 1']);

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("widget"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadData();
                  // start loading data
                  setState(() {
                    isLoading = true;
                  });
                }
              },
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${items[index]}'),
                  );
                },
              ),
            ),
          ),
          Container(
            height: isLoading ? 50.0 : 0,
            color: Colors.transparent,
            child: Center(
              child: new CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}*/
