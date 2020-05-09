import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();

  String usertname;

  submit() {
    _formKey.currentState.save();
  } 

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(context, titletext: 'Set Up Your Profile'),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text(
                      'Create A Username',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            fontSize: 15,
                          ),
                          hintText: 'Must be 3 Characters',
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
