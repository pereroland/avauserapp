import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/credential.dart';
import 'package:avauserapp/components/dataLoad/homeDataLoad.dart';
import 'package:avauserapp/components/dataLoad/myWallettModeLoad.dart';
import 'package:avauserapp/components/dialog/walletCheck.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/components/shimmerEffects/sizeImageShimmer.dart';
import 'package:avauserapp/screens/kiosk/invoice_web_view_screen.dart';
import 'package:avauserapp/screens/notification/NotificationTab.dart';
import 'package:avauserapp/screens/product/StoreItemsListShop.dart';
import 'package:avauserapp/screens/product/productList.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:place_picker/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/Location/CurrentLocation.dart';
import '../../components/language/languageSelected.dart';
import 'baseTabClass.dart';

class HomeScreen extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen>, WidgetsBindingObserver {
  var dataLoad = true;
  var home = "";
  var city = "";
  Map? myLang;
  var userId = "",
      profilePic = "",
      userFullName = "",
      userEmail = "",
      userImage = "";
  var apiDataLoad = false;
  List? top_slider, category, grid_view, footer_view;
  var _current = 0;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  var _locationPick = true;
  TextEditingController serchCityController = TextEditingController();
  var showSearch = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getBannerData();
    checkCampaign();
    myLangGet();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // checkCampaign();
        break;
      case AppLifecycleState.inactive:
        // checkCampaign();
        break;
      case AppLifecycleState.paused:
        // checkCampaign();
        break;
      case AppLifecycleState.detached:
        ;
        break; // checkCampaign()
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      drawer: dataLoad
          ? drawerData(
              context, userId, profilePic, userFullName, userEmail, userImage)
          : Text(allTranslations.text('Home')),
      appBar: AppBar(
        title: Text(
          allTranslations.text('Home'),
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          _locationPick
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _locationPick = false;
                    });
                  },
                  icon: Icon(
                    Icons.location_on,
                    color: AppColours.appTheme,
                  ),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      _locationPick = true;
                    });
                  },
                  icon: Icon(
                    Icons.location_off,
                    color: AppColours.blacklightLineColour,
                  ),
                ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationTabs()),
              );
            },
            icon: Icon(
              Icons.notifications_active,
              color: AppColours.appTheme,
            ),
          )
        ],
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: apiDataLoad
          ? RefreshIndicator(
              key: refreshKey,
              child: new ListView(
                children: <Widget>[
                  _locationPick
                      ? SizedBox.shrink()
                      : locationPickAddress(context),
                  imageCarousel(top_slider),
                  HorizontalList(categoryList: category ?? []),
                  shortBanner(grid_view ?? []),
                  fullBanner(footer_view ?? [])
                ],
              ),
              onRefresh: getBannerData,
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
    );
  }

  Widget imageCarousel(topSlider) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 250,
          child: CarouselSlider(
            options: CarouselOptions(
                height: MediaQuery.of(context).size.height / 1.5,
                viewportFraction: 1.0,
                autoPlay: true,
                enableInfiniteScroll: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: topSlider.map<Widget>((card) {
              return Builder(builder: (BuildContext context) {
                return GestureDetector(
                  child: CachedNetworkImage(
                    imageUrl: card['banner'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => sizeImageShimmer(
                        context, MediaQuery.of(context).size.width, 340.0),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/nodata.webp",
                      fit: BoxFit.fill,
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                  onTap: () {
                    callNavigationProduct(card['title'], card['store_id']);
                  },
                );
              });
            }).toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: mapSlider<Widget>(topSlider, (index, url) {
            return Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _current == index ? AppColours.whiteColour : Colors.black38,
              ),
            );
          }),
        )
      ],
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
      city = prefs.getString('city') ?? "";
      serchCityController.text = city;
      myLang = myLangData;
      home = myLang!['Home'];
      dataLoad = true;
    });
  }

  Map? locationData;

  @override
  bool get wantKeepAlive => true;

  Future<void> checkCampaign() async {
    if (locationData == null) {
      locationData = await getLocation(context) ?? {};
    }
    if (mounted && locationData != null) {
      callCampaign(
        context,
        long: locationData!['Longitude'].toString(),
        lat: locationData!['Latitude'].toString(),
      );
    }
    Timer.periodic(Duration(minutes: 5), (timer) {
      if (mounted) checkCampaign();
    });
  }

  Future<void> getBannerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var decoded = await callHomeLoad(context, city);
    String status = decoded!['status'];
    String message = decoded['message'];
    if (status == success_status) {
      var record = decoded['record'];
      var cartQty = decoded['cart_qty'].toString();
      top_slider = record['top_slider'];
      category = record['category'];
      grid_view = record['grid_view'];
      footer_view = record['footer_view'];
      if (mounted)
        setState(() {
          apiDataLoad = true;
        });
      if (cartQty == 'null') {
        prefs.setString('cart_qty', '0');
      } else {
        prefs.setString('cart_qty', cartQty.toString());
      }
      checkWallet();
    } else if (status == unauthorized_status) {
      await checkLoginStatus(context);
    } else if (status == "408") {
      jsonDecode(await apiRefreshRequest(context));
      getBannerData();
    } else {
      setState(() {
        apiDataLoad = true;
      });
      _showToast(message);
    }
  }

  shortBanner(List gridView) {
    return Container(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5),
        itemCount: gridView.length,
        itemBuilder: (context, index) {
          return Container(
            height: 60,
            child: Card(
              child: Material(
                child: InkWell(
                  onTap: () {
                    callNavigationProduct(
                        gridView[index]['title'], gridView[index]['store_id']);
                  },
                  child: GridTile(
                    child: CachedNetworkImage(
                      imageUrl: '${gridView[index]['banner']}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          imageShimmer(context, 48.0),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/nodata.webp",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  fullBanner(List footerView) {
    return ListView.builder(
        itemCount: footerView.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(5, 10, 10, 0),
            child: InkWell(
              onTap: () {
                callNavigationProduct(
                    footerView[index]['title'], footerView[index]['store_id']);
              },
              child: CachedNetworkImage(
                imageUrl: footerView[index]['banner'],
                fit: BoxFit.cover,
                placeholder: (context, url) => imageShimmer(context, 48.0),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/nodata.webp",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        });
  }

  List<T> mapSlider<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
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

  void callNavigationProduct(title, storeId) {
    if (storeId.toString() == "0" || storeId.toString() == "*") {
      callNavigationStore('3', '', '', context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Product(storeName: title, Id: storeId, isFav: false)),
      );
    }
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
    getBannerData();

    /*   LocationResult result = await showLocationPicker(context, googlePlaceKey);
    var latitude = result.latLng.latitude;
    var longitude = result.latLng.longitude;
    Map decoded = await getUserLocationDetailByLatLng(latitude, longitude);
    setState(() {
      city = decoded['city'].toString();
      serchCityController.text=city;
    });
    getBannerData();
    */
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
                          child: Icon(
                            Icons.location_on,
                            color: AppColours.appTheme,
                          ),
                          onPressed: () {
                            addressSearch(context);
                          },
                          backgroundColor: AppColours.blacklightColour,
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
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColours.appTheme,
                          ),
                          onPressed: () {
                            getBannerData();
                            FocusScope.of(context).unfocus();
                          },
                          backgroundColor: AppColours.blacklightColour,
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

  Future<void> checkWallet() async {
    if (mounted) {
      Map? detail = await myWalletModeLoad(context);
      if (detail != null) {
        if (detail['status'] == "200") {
        } else {
          WalletSetupDialog(context);
        }
      }
    }
  }
}

class HorizontalList extends StatefulWidget {
  HorizontalList({Key? key, required this.categoryList}) : super(key: key);

  List categoryList;

  @override
  State<StatefulWidget> createState() {
    return _HorizontalViewState();
  }
}

class _HorizontalViewState extends State<HorizontalList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        itemCount: widget.categoryList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width / 3 - 6,
              margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              color: Colors.blue,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: '${widget.categoryList[index]['icon_thumb']}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => imageShimmer(context, 48.0),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/nodata.webp",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 5,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 3 - 6,
                      child: Text(
                        '${widget.categoryList[index]['name']}',
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Montserrat-Medium',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              callNavigationStore(
                '3',
                widget.categoryList[index]['id'],
                '',
                context,
              );
            },
          );
        },
      ),
    );
  }
}

/*
class PostTile extends StatelessWidget {
  final Post post;

  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: post.postId,
          userId: post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: imageCheck(post.mediaUrl),
    );
  }

  imageCheck(mediaUrl) {
    var imageUrl=mediaUrl.toString();
    if(imageUrl=='null'){
      imageUrl='https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png';
    }
    return cachedNetworkImage(post.mediaUrl);
  }
}
*/
void callNavigationStore(type, categoryId, merchantId, context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => StoreShopDetail(
              type: type,
              category: categoryId,
              merchant_id: merchantId,
              isFav: false,
            )),
  );
}
