import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:avauserapp/components/addressFilter.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:avauserapp/components/networkConnection/apiStatus.dart';
import 'package:avauserapp/components/networkConnection/apis.dart';
import 'package:avauserapp/components/networkConnection/connectionCheck.dart';
import 'package:avauserapp/components/networkConnection/httpConnection.dart';
import 'package:avauserapp/components/widget/appbar.dart';
import 'package:avauserapp/components/widget/button.dart';
import 'package:avauserapp/components/widget/textfield.dart';
import 'package:avauserapp/main.dart';
import 'package:avauserapp/screens/Dispute/DisputeDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisputeCreate extends StatefulWidget {
  DisputeCreate({Key? key, this.order_id}) : super(key: key);
  var order_id;

  @override
  _DisputeCreateState createState() => _DisputeCreateState();
}

class _DisputeCreateState extends State<DisputeCreate> {
  List<XFile>? _imageFileList;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
          text: allTranslations.text('dispute'),
          onTap: () {
            Navigator.pop(context);
          }),
      bottomNavigationBar: despute(context),
      body: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40.0,
                  ),
                  borderTextfield(
                      controller: titleController,
                      hintText: allTranslations.text("enterProblemName"),
                      validatordata: (value) {
                        if (value!.isEmpty) {
                          return allTranslations.text("pleaseEnter") +
                              " " +
                              allTranslations.text("enterProblemName");
                        }
                        return null;
                      }),
                  SizedBox(
                    height: 20.0,
                  ),
                  borderTextfield(
                      controller: descriptionController,
                      hintText: allTranslations.text("enterProblemDetail"),
                      validatordata: (value) {
                        if (value!.isEmpty) {
                          return allTranslations.text("pleaseEnter") +
                              allTranslations.text("enterProblemDetail");
                        }
                        return null;
                      },
                      maxLines: 5),
                  SizedBox(
                    height: 20.0,
                  ),
                  _previewImages(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  despute(context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: SizedBox(
        height: 50.0,
        width: MediaQuery.of(context).size.width,
        child: _loading
            ? Center(
                child: Container(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(),
                ),
              )
            : fullColouredBtn(
                text: allTranslations.text('send'),
                radiusButtton: 10.0,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    createDisputeApiData(context);
                  }
                },
              ),
      ),
    );
  }

  Widget _previewImages(context) {
    if (_imageFileList != null) {
      return SizedBox(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Semantics(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    key: UniqueKey(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 2.0),
                        child: InkWell(
                          child: Semantics(
                            label: 'image_picker_example_picked_image',
                            child: Image.file(
                              File(_imageFileList![index].path),
                              height: 100.0,
                              width: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          onTap: () {
                            imagePickCall();
                          },
                        ),
                      );
                    },
                    itemCount: _imageFileList!.length,
                  ),
                  label: 'image_picker_example_picked_images'),
              IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    imagePickCall();
                  }),
            ],
          ));
    } else {
      return InkWell(
        child: Container(
            height: 100.0,
            width: 100.0,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red[500]!,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Icon(Icons.add)),
        onTap: () {
          imagePickCall();
        },
      );
    }
  }

  Future<void> imagePickCall() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFileList = await _picker.pickMultiImage();
    setState(() {
      _imageFileList = pickedFileList;
    });
  }

  void createDisputeApiData(context) async {
    showToast("Please wait...");
    setState(() {
      _loading = true;
    });
    var callUserLoginCheck = await internetConnectionState();
    if (callUserLoginCheck) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String authtoken = prefs.getString('authtoken') ?? "";
      Map<String, String> headers = {"authtoken": authtoken};

      var uri = Uri.parse(addDisputeUrl);
      var request = new http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      if (_imageFileList == null) {
      } else {
        for (int i = 0; i < _imageFileList!.length; i++) {
          var stream = new http.ByteStream(
              DelegatingStream.typed(_imageFileList![i].openRead()));
          var length = await _imageFileList![i].length();
          var multipartFile_identity_front = new http.MultipartFile(
              'images[]', stream, length,
              filename: basename(_imageFileList![i].path));
          request.files.add(multipartFile_identity_front);
        }
      }
      request.fields['order_id'] = widget.order_id;
      request.fields['title'] = titleController.text;
      request.fields['description'] =
          descriptionController.text; //      typeController.text;
      request.fields['Accept-Language'] =
          jsonEncode(allTranslations.locale.toString());
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) async {
        Map data = jsonDecode(value);
        String status = data['status'];
        String message = data['message'];
        String disputeId = data['record'].toString();
        if (status == "200") {
          showToast(message);
          if (disputeId != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DisputeDetail(
                          disputeId: disputeId,
                        )));
          } else {
            navigatorKey.currentState?.pop();
            navigatorKey.currentState?.pop();
          }
          // navigatorKey.currentState.pop();
        } else if (status == unauthorized_status) {
          await checkLoginStatus(context);
        } else if (status == data_not_found_status) {
        } else if (status == already_login_status) {
        } else if (status == "408") {
          Map decoded = jsonDecode(await apiRefreshRequest(context));
          createDisputeApiData(context);
        } else {
          showToast(message);
        }
      });
      setState(() {
        _loading = false;
      });
    }
  }
}
