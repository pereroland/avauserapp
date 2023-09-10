import 'package:avauserapp/components/CountryCodePicker/country_code.dart';
import 'package:avauserapp/components/colorconstants.dart';
import 'package:avauserapp/components/language/allTranslations.dart';
import 'package:flutter/material.dart';

class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final TextStyle textStyle;
  final WidgetBuilder? emptySearchBuilder;
  final bool showFlag;
  final double flagWidth;
  final Size? size;
  final bool hideSearch;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  SelectionDialog(
    this.elements,
    this.favoriteElements, {
    Key? key,
    required this.showCountryOnly,
    required this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    required this.searchStyle,
    required this.textStyle,
    required this.showFlag,
    this.flagWidth = 32,
    this.size,
    this.hideSearch = false,
  })  : this.searchDecoration =
            searchDecoration.copyWith(prefixIcon: Icon(Icons.search)),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  List<CountryCode>? filteredElements;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /* Image.asset(
               "Images/logo.webp",
               width: 40.0,
               height: 40.0,
             )*/
            Text(
              "Select Country",
              style: TextStyle(color: Colors.black),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (!widget.hideSearch)
              Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                  child: Align(
                    alignment: AlignmentDirectional.topCenter,
                    child: Card(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                          child: Container(
                            height: 50.0,
                            color: Colors.white,
                            child: TextField(
                              decoration: InputDecoration(
                                suffixIcon: Icon(Icons.search),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColours.transparentColour),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColours.transparentColour),
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColours.transparentColour),
                                ),
                              ),
                              onChanged: _filterElements,
                            ),
                          )),
                    ),
                  )),
            Container(
              width: widget.size?.width ?? MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 200,
              child: ListView(
                children: [
                  widget.favoriteElements.isEmpty
                      ? const DecoratedBox(decoration: BoxDecoration())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.favoriteElements.map(
                              (f) => SimpleDialogOption(
                                child: _buildOption(f),
                                onPressed: () {
                                  _selectItem(f);
                                },
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                  if (filteredElements != null)
                    if (filteredElements!.isEmpty)
                      _buildEmptySearchWidget(context)
                    else
                      ...filteredElements!.map(
                        (e) => SimpleDialogOption(
                          key: Key(e.toLongString()),
                          child: _buildOption(e),
                          onPressed: () {
                            _selectItem(e);
                          },
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      )
//       SimpleDialog(
//         titlePadding: const EdgeInsets.all(0),
//         title: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: <Widget>[
//             IconButton(
//               padding: const EdgeInsets.all(0),
//               iconSize: 20,
//               icon: Icon(
//                 Icons.close,
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             if (!widget.hideSearch)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: TextField(
//                   style: widget.searchStyle,
//                   decoration: widget.searchDecoration,
//                   onChanged: _filterElements,
//                 ),
//               ),
//           ],
//         ),
//         children: [
//           Container(
//             width: widget.size?.width ?? MediaQuery.of(context).size.width,
//             height:
//             widget.size?.height ?? MediaQuery.of(context).size.height * 0.7,
//             child: ListView(
//               children: [
//                 widget.favoriteElements.isEmpty
//                     ? const DecoratedBox(decoration: BoxDecoration())
//                     : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ...widget.favoriteElements.map(
//                           (f) => SimpleDialogOption(
//                         child: _buildOption(f),
//                         onPressed: () {
//                           _selectItem(f);
//                         },
//                       ),
//                     ),
//                     const Divider(),
//                   ],
//                 ),
//                 if (filteredElements.isEmpty)
//                   _buildEmptySearchWidget(context)
//                 else
//                   ...filteredElements.map(
//                         (e) => SimpleDialogOption(
//                       key: Key(e.toLongString()),
//                       child: _buildOption(e),
//                       onPressed: () {
//                         _selectItem(e);
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
      );

  Widget _buildOption(CountryCode e) {
    return Card(
      child: ListTile(
        leading: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Text(
            e.dialCode.toString(),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
        title: Text(
          e.toCountryStringOnly(),
          style: TextStyle(
            fontSize: 20.0,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    )
        /*Container(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          if (widget.showFlag)
            */ /*Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  e.flagUri,
                  package: 'country_code_picker',
                  width: widget.flagWidth,
                ),
              ),
            ),*/ /*
          Expanded(
            flex: 4,
            child: Text(
              widget.showCountryOnly
                  ? e.toCountryStringOnly()
                  : e.toLongString(),
              overflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    )*/
        ;
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return Center(
      child: Text(allTranslations.text('NoCountryFound')),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              e.code.contains(s) ||
              e.dialCode.contains(s) ||
              e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
