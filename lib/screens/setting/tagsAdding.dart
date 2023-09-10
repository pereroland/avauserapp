import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MytagsHomePage extends StatefulWidget {
  MytagsHomePage(
      {Key? key,
      required this.TagList,
      required this.tagesSelected,
      required this.id,
      required this.selectedTagList})
      : super(key: key);
  List TagList;
  List tagesSelected;
  List selectedTagList;
  List<String> id;

  @override
  _MytagsHomePageState createState() =>
      _MytagsHomePageState(tagesSelected, id, selectedTagList);
}

class _MytagsHomePageState extends State<MytagsHomePage> {
  _MytagsHomePageState(this.tagesSelected, this.id, this.selectedTagList);

  TextEditingController tagsController = TextEditingController();
  late List tagesSelected;
  late List selectedTagList;
  List showList = [];
  var datarefresh = false;
  late List AllData;
  late List<String> id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataChange(widget.TagList);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async {
          callSaveData();
          return Future.value(false);
        },
        child: Scaffold(
            bottomNavigationBar: addtToCampaignTagButton(context),
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  callSaveData();
                },
              ),
              iconTheme: IconThemeData(color: Colors.black),
              title: Text(
                'Add Tagg',
                style: TextStyle(color: AppColours.blackColour),
              ),
              backgroundColor: AppColours.whiteColour,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // searchTaggItemTextData(context),
                  tagesSelected.length > 0
                      ? datarefresh
                          ? selectedTagsData(context)
                          : SizedBox.shrink()
                      : SizedBox.shrink(),
                  SizedBox(
                    height: 10.0,
                  ),
                  tagesSelected.length > 0
                      ? Divider(
                          height: 1.0,
                          color: AppColours.blacklightLineColour,
                        )
                      : SizedBox.shrink(),
                  datarefresh
                      ? Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: showList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return listItems(showList, index, context);
                              }),
                        )
                      : SizedBox.shrink()
                ],
              ),
            )));
  }

  selectedTagsData(context) {
    return dataSet();
  }

  searchTaggItemTextData(context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
      child: new Container(
        child: TextFormField(
          controller: tagsController,
          keyboardType: TextInputType.text,
          //This will obscure text dynamically
          onChanged: (text) {
            searchTag(text);
          },
          decoration: InputDecoration(
            hintText: allTranslations.text('SelectTagshere'),
            fillColor: Colors.white,
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
        ),
      ),
    );
  }

  Widget listItems(list, int index, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        child: Card(
          child: ListTile(
            title: Text(list[index]['name']),
            trailing: Icon(Icons.add),
          ),
        ),
        onTap: () {
          selectSetItem(list, index);
        },
      ),
    );
  }

  void selectSetItem(list, int index) {
    setState(() {
      if (tagesSelected
              .contains(list[index]['name'].toString().toUpperCase()) ||
          tagesSelected
              .contains(list[index]['name'].toString().toLowerCase()) ||
          tagesSelected.contains(list[index]["name"])) {
        _showToast(allTranslations.text("already_Selected"));
      } else {
        id.add(list[index]['id'].toString());
        tagesSelected.add(list[index]['name'].toString());
        selectedTagList.add(list[index]);
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

  itemsTags(List tagesSelected, int i) {
    return Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200]!,
            ),
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: GestureDetector(
          child: Padding(
              padding: EdgeInsets.fromLTRB(5, 4, 5, 5),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                      color: AppColours.blackColour,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                  text: tagesSelected[i].toString(),
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5.0, 0.0, 2.0, 0.0),
                        child: Icon(
                          Icons.cancel,
                          color: AppColours.appTheme,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          onTap: () {
            setItemList(i);
          },
        ));
  }

  void dataChange(TagList) {
    setState(() {
      AllData = TagList;
      datarefresh = false;
      showList = TagList;
      datarefresh = true;
    });
  }

  void setItemList(i) {
    setState(() {
      datarefresh = false;
      tagesSelected.removeAt(i);
      selectedTagList.removeAt(i);
      id.removeAt(i);

      datarefresh = true;
    });
  }

  void searchTag(text) {
    for (int i = 0; i < widget.TagList.length; i++) {
      if (widget.TagList[i]['name'].toString().toUpperCase() ==
          text.toString().toUpperCase()) {
        setState(() {
          datarefresh = false;
          showList.clear();
          showList.add(widget.TagList[i]);
          datarefresh = true;
        });
      } else {
        setState(() {
          datarefresh = false;
          showList.clear();
          datarefresh = true;
        });
      }
    }
  }

  dataSet() {
    if (tagesSelected.length > 0)
      return Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
          child: Wrap(
              children: List.generate(
                  tagesSelected.length, (e) => itemsTags(tagesSelected, e))));
    else
      return Text(allTranslations.text('ChooseTagFormList'));
  }

  addtToCampaignTagButton(BuildContext context) {
    return tagesSelected.length > 0
        ? Padding(
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
                            callSaveData();
                          },
                          child: Text(
                            "Done",
                            style:
                                TextStyle(fontSize: 16.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          )
        : SizedBox.shrink();
  }

  void callSaveData() {
    Map map = {'id': id, 'items': tagesSelected, "listTags": selectedTagList};

    Navigator.pop(context, map);
  }
}

/*
///
class MytagsHomePage extends StatefulWidget {
  MytagdsHomePage({Key key,this.TagList}):super(key:key);
  List<Map> TagList;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MytagsHomePage> {
  String _selectedValuesJson = 'Nothing to show';
  List<Language> _selectedLanguages;

  @override
  void initState() {
    _selectedLanguages = [];
    super.initState();
  }

  @override
  void dispose() {
    _selectedLanguages.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),

        title: Text('Add Tagg',style: TextStyle(
          color: AppColours.blackColour
        ),),
        backgroundColor: AppColours.whiteColour,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlutterTagging<Language>(
              initialItems: _selectedLanguages,
              textFieldConfiguration: TextFieldConfiguration(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.green.withAlpha(30),
                  hintText: 'Search Tags',
                  labelText: 'Select Tags',
                ),
              ),
              findSuggestions: LanguageService.getLanguages,
              additionCallback: (value) {
                return Language(
                  name: value,
                  position: 0,
                );
              },
              onAdded: (language) {
                // api calls here, triggered when add to tag button is pressed
                return Language();
              },
              configureSuggestion: (lang) {
                return
                  SuggestionConfiguration(
                  title: Text(lang.name),
                  subtitle: Text(lang.position.toString()),
                  additionWidget: Chip(
                    avatar: Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    label: Text('Add New Tag'),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              configureChip: (lang) {
                return ChipConfiguration(
                  label: Text(lang.name),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                  deleteIconColor: Colors.white,
                );
              },
              onChanged: () {

                setState(() {
                  _selectedValuesJson = _selectedLanguages
                      .map<String>((lang) => '\n${lang.toJson()}')
                      .toList()
                      .toString();
                  _selectedValuesJson =
                      _selectedValuesJson.replaceFirst('}]', '}\n]');
                });
              },
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          // Expanded(
          //   child: SyntaxView(
          //     code: _selectedValuesJson,
          //     syntax: Syntax.JAVASCRIPT,
          //     withLinesCount: false,
          //     syntaxTheme: SyntaxTheme.standard(),
          //   ),
          // ),
        ],
      ),
    );
  }
}

/// LanguageService
class LanguageService {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Language>> getLanguages(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    return <Language>[
      Language(name: 'JavaScript', position: 1),
      Language(name: 'Python', position: 2),
      Language(name: 'Java', position: 3),
      Language(name: 'PHP', position: 4),
      Language(name: 'C#', position: 5),
      Language(name: 'C++', position: 6),
      Language(name: 'flutter', position: 6),
    ]
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Language Class
class Language extends Taggable {
  ///
  final String name;

  ///
  final int position;

  /// Creates Language
  Language({
    this.name,
    this.position,
  });

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
    "position": $position\n
  }''';
}*/
