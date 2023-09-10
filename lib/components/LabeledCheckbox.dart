import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    required this.padding,
    required this.value,
    required this.onChanged,
  });

  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Checkbox(
          value: value,
          onChanged: (bool? newValue) {
            onChanged(newValue);
          },
        ),
      ),
    );
  }
}
