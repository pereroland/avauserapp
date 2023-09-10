import 'package:cached_network_image/cached_network_image.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/shimmerEffects/imageloadshimmer.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/product/product_list_with_tags_filter.dart';
import 'package:flutter/material.dart';

class PushCampDetails extends StatelessWidget {
  final Map details;

  const PushCampDetails({Key? key, required this.details}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ADJMI ${details}");
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: AppColours.whiteColour,
          title: Text(
            allTranslations.text('New_Campaign'),
            style: TextStyle(color: AppColours.blackColour),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: details['notification_image'],
                fit: BoxFit.cover,
                placeholder: (context, url) => imageShimmer(context, 240.0),
                errorWidget: (context, url, error) => Image.asset(
                  "assets/nodata.webp",
                  fit: BoxFit.fill,
                ),
                height: 500.0,
                width: MediaQuery.of(context).size.width,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            allTranslations.text('title') + " : ",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                              details['title'] ??
                                  details["notification_title"] ??
                                  "Title",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                        details["notification_description"] ??
                            details['type_id_detail']['description'] ??
                            "",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.normal)),
                    SizedBox(
                      height: 10.0,
                    ),
                    setBottomButton(context)
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  setBottomButton(context) {
    return Container(
      height: 150,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Hero(
              tag: 'offerApply',
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
                          Navigator.push(
                            navigatorKey.currentContext!,
                            MaterialPageRoute(
                              builder: (context) => ProductListOnTags(
                                  pushId: details['campaign_id']),
                            ),
                          );
                        },
                        child: Text(
                          allTranslations.text('Apply_Offer'),
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Hero(
                tag: 'cancelOfferApply',
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        buttonColor: AppColours.redColour,
                        child: MaterialButton(
                          color: AppColours.redColour,
                          elevation: 16.0,
                          shape: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColours.redColour),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text(
                            allTranslations.text('Cancel_Offer'),
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
