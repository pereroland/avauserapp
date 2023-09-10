import 'package:avauserapp/components/CountryCodePicker/country_code.dart';
import 'package:avauserapp/components/CountryCodePicker/country_codes.dart';
import 'package:avauserapp/components/CountryCodePicker/selection_dialog.dart';
import 'package:flutter/material.dart';

export 'country_code.dart';

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<CountryCode>? onChanged;
  final ValueChanged<CountryCode>? onInit;
  final String? initialSelection;
  final String? showText;
  final List<String> favorite;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? dialogTextStyle;
  final WidgetBuilder? emptySearchBuilder;
  final Function(CountryCode)? builder;
  final bool enabled;
  final TextOverflow textOverflow;

  /// the size of the selection dialog
  final Size? dialogSize;

  /// used to customize the country list
  final List<String>? countryFilter;

  /// shows the name of the country instead of the dialcode
  final bool showOnlyCountryWhenClosed;

  /// aligns the flag and the Text left
  ///
  /// additionally this option also fills the available space of the widget.
  /// this is especially useful in combination with [showOnlyCountryWhenClosed],
  /// because longer country names are displayed in one line
  final bool? alignLeft;

  /// shows the flag
  final bool? showFlag;

  final bool? hideMainText;

  final bool? showFlagMain;

  final bool? showFlagDialog;

  /// Width of the flag images
  final double flagWidth;

  /// Use this property to change the order of the options
  final Comparator<CountryCode>? comparator;

  /// Set to true if you want to hide the search part
  final bool hideSearch;

  CountryCodePicker({
    required this.onChanged,
    this.onInit,
    this.initialSelection,
    this.showText,
    this.favorite = const [],
    this.textStyle,
    this.padding = const EdgeInsets.all(0.0),
    this.showCountryOnly = false,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.dialogTextStyle,
    this.emptySearchBuilder,
    this.alignLeft = false,
    this.showFlag = true,
    this.showFlagDialog,
    this.hideMainText = false,
    this.showFlagMain,
    this.builder,
    this.flagWidth = 32.0,
    this.enabled = true,
    this.textOverflow = TextOverflow.ellipsis,
    this.comparator,
    this.countryFilter,
    this.hideSearch = false,
    this.dialogSize,
    Key? key,
    required this.showOnlyCountryWhenClosed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    List<Map<String, String>> jsonList = codes;

    List<CountryCode> elements =
        jsonList.map((json) => CountryCode.fromJson(json)).toList();

    elements.sort(comparator);

    if (countryFilter != null) {
      if (countryFilter!.isNotEmpty) {
        final uppercaseCustomList =
            countryFilter!.map((c) => c.toUpperCase()).toList();
        elements = elements
            .where((c) =>
                uppercaseCustomList.contains(c.code) ||
                uppercaseCustomList.contains(c.name) ||
                uppercaseCustomList.contains(c.dialCode))
            .toList();
      }
    }

    return CountryCodePickerState(elements, showText ?? "");
  }
}

class CountryCodePickerState extends State<CountryCodePicker> {
  late CountryCode selectedItem;
  List<CountryCode> elements = [];
  List<CountryCode> favoriteElements = [];
  String showText = '';

  CountryCodePickerState(this.elements, this.showText);

  @override
  Widget build(BuildContext context) {
    Widget _widget;
    if (widget.builder != null)
      _widget = InkWell(
        onTap: showCountryCodePickerDialog,
        child: widget.builder!(selectedItem),
      );
    else {
      _widget = MaterialButton(
        padding: widget.padding,
        onPressed: widget.enabled ? showCountryCodePickerDialog : null,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // widget.showFlagMain != null
            //     ? widget.showFlagMain
            //     : widget.showFlag,
            /* Flexible(
                flex: widget.alignLeft ? 0 : 1,
                fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
                child: Padding(
                  padding: widget.alignLeft
                      ? const EdgeInsets.only(right: 16.0, left: 8.0)
                      : const EdgeInsets.only(right: 16.0),
                  child: Image.asset(
                    selectedItem.flagUri,
                    package: 'country_code_picker',
                    width: widget.flagWidth,
                  ),
                ),
              ),*/
            showTextData(),
          ],
        ),
      );
    }
    return _widget;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.elements = elements.map((e) => e.localize(context)).toList();
    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements.firstWhere(
            (e) =>
                (e.code.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()) ||
                (e.dialCode == widget.initialSelection) ||
                (e.name.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()),
            orElse: () => elements[0]);
      } else {
        selectedItem = elements[0];
      }
      _onInit(selectedItem);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
          (e) =>
              (e.code.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()) ||
              (e.dialCode == widget.initialSelection) ||
              (e.name.toUpperCase() == widget.initialSelection!.toUpperCase()),
          orElse: () => elements[0]);
    } else {
      selectedItem = elements[0];
    }

    favoriteElements = elements
        .where((e) => widget.favorite
            .firstWhere((f) =>
                e.code.toUpperCase() == f.toUpperCase() ||
                e.dialCode == f ||
                e.name.toUpperCase() == f.toUpperCase())
            .isNotEmpty)
        .toList();
  }

  void showCountryCodePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => SelectionDialog(
        elements,
        favoriteElements,
        showCountryOnly: widget.showCountryOnly,
        emptySearchBuilder: widget.emptySearchBuilder,
        searchDecoration: widget.searchDecoration,
        searchStyle: widget.searchStyle ?? TextStyle(),
        textStyle: widget.dialogTextStyle ?? TextStyle(),
        showFlag: widget.showFlagDialog != null
            ? widget.showFlagDialog!
            : widget.showFlag!,
        flagWidth: widget.flagWidth,
        size: widget.dialogSize,
        hideSearch: widget.hideSearch,
      ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });

        _publishSelection(e);
      }
    });
  }

  void _publishSelection(CountryCode e) {
    if (widget.onChanged != null) {
      widget.onChanged!(e);
    }
  }

  void _onInit(CountryCode e) {
    if (widget.onInit != null) {
      widget.onInit!(e);
    }
  }

  showTextData() {
    if (!widget.hideMainText!) {
      return Text(
        widget.showOnlyCountryWhenClosed
            ? selectedItem.toCountryStringOnly()
            : selectedItem.toString(),
        style: TextStyle(fontSize: 18.0),
        textAlign: TextAlign.end,
        overflow: widget.textOverflow,
      );
    } else {
      return Text(
        showText,
        style: TextStyle(fontSize: 18.0),
        textAlign: TextAlign.end,
        overflow: widget.textOverflow,
      );
    }
  }
}
