import 'dart:developer';

import 'package:case_records/controller/create_sheet_controller.dart';
import 'package:case_records/service/form_controller_factory.dart';
import 'package:case_records/view/form_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert' as convert;

import 'package:google_sign_in/google_sign_in.dart';

class AppScriptForm extends StatefulWidget {
  final Function? onSubmit;
  final GoogleSignInAccount googleSignInAccount;
  const AppScriptForm({Key? key, this.onSubmit, required this.googleSignInAccount}) : super(key: key);
  @override
  _AppScriptFormState createState() => _AppScriptFormState();
}

class _AppScriptFormState extends State<AppScriptForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController appScriptUrlController =
  new TextEditingController();
  final TextEditingController sheetIdController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Material(
            child: Scaffold(
                body: Form(
                    key: _formKey,
                    child: Container(
                        margin: EdgeInsets.all(30),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(children: <Widget>[
                          TextFormField(
                            key: Key("sheet_id"),
                            controller: sheetIdController,
                            decoration: createInputDecoration("Sheet ID"),
                            validator: (value) {
                              if (value == null || value == "")
                                return "Sheet Id is Required";
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: _createSheet,
                              child: const Text('Create Sheet'),
                            ),
                          ),
                        ]))))));
  }
  void _createSheet() async{
    log("_createSheet: Create sheet clicked => " + appScriptUrlController.text);
    if(appScriptUrlController.text == ""){
      SheetController controller = await SheetControllerSingletonExtension.instance(widget.googleSignInAccount);
      controller.createSheet(_setSheetId).whenComplete(() => _submitForm());
      return;
    }
    _submitForm();
  }
  void _setSheetId(sheetId){
    print("_createSheet: Sheet created" + sheetId);
    setState((){
      sheetIdController.text = sheetId;
    });
  }
  void _submitForm() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      var sheetId = sheetIdController.text;
      dynamic dbData = {'sheetId': sheetId};
      await FormControllerSingletonExtension.storage
          .writeData(convert.jsonEncode(dbData))
          .then((any) {
        if (widget.onSubmit != null) {
          widget.onSubmit!();
        }
      });
    }
  }


}