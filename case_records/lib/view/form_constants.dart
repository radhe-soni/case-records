import 'package:flutter/material.dart';

final Color PRIMARY_COLOR = Colors.lightGreen[900]!;

final _formLabelStyle = TextStyle(
  color: Colors.black87,
  fontSize: 17,
  fontWeight: FontWeight.normal,
);
final _focusedBorder = UnderlineInputBorder(
  borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0),
);
final _enabledBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0));

InputDecoration createInputDecoration(String label) {
  return InputDecoration(
      labelText: label,
      labelStyle: _formLabelStyle,
      focusedBorder: _focusedBorder,
      enabledBorder: _enabledBorder);
}

InputDecoration createLeadingTextInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
      labelStyle: _formLabelStyle,
      focusedBorder: _focusedBorder,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 5.0)
      ));
}