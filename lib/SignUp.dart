import 'dart:convert';
import 'dart:io';
import 'package:flutter_crowdfunding/AppServer.dart';
import 'package:flutter_crowdfunding/Home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'User.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>
{
  String accountName = "Crowdfunding";
  String accountEmail = "",
      accountPass,
      accountPhoto,
      accountType = "0";
  User u;

  GlobalKey<FormState> signUp = new GlobalKey();
  File pickedimage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crowdfunding"),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Form(
          key: signUp,
          child: ListView(
            children: <Widget>[
              CircularProfileAvatar(
                '',
                child: checkImage(),
                borderWidth: 1,
                elevation: 2,
                radius: 50,
              ),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                child: Icon(Icons.camera_alt),
                onPressed: () async {
                  pickedimage =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  List<int> imageBytes = pickedimage.readAsBytesSync();
                  accountPhoto = base64Encode(imageBytes);
                  print(accountPhoto);
                  setState(() {});
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Name",
                  hintText: "Enter Your Name",
                  icon: Icon(Icons.account_circle),
                ),
                validator: (name) => name.isEmpty ? "Name is Required" : null,
                onSaved: (name) => accountName = name,
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "Enter Your Email",
                  icon: Icon(Icons.email),
                ),
                validator: (email) =>
                    email.isEmpty ? "Email is Required" : null,
                onSaved: (email) => accountEmail = email,
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter Your Passowrd",
                  icon: Icon(Icons.lock_outline),
                ),
                validator: (pass) =>
                    pass.isEmpty ? "Password is Required" : null,
                onSaved: (pass) => accountPass = pass,
              ),
              SizedBox(
                height: 30,
              ),
              FlatButton(
                child: Text("Sign Up"),
                color: Colors.purple,
                padding: EdgeInsets.all(20),
                textColor: Colors.white,
                onPressed: () {
                  if (signUp.currentState.validate() && pickedimage != null)
                  {
                    signUp.currentState.save();

                    addUser().then((res)
                    {
                      String jsonsDataString =res.body;// toString of Response's body is assigned to jsonDataString

                      Map<String, dynamic> map = jsonDecode(jsonsDataString); // import 'dart:convert';

                      String result = map['result'];

                      if (result == "success")
                      {
                        //print("ooo");
                        getUser().then((res)
                        {
                          Map<String, dynamic> data = jsonDecode(res.body);

                          u = User(data["u_id"],
                              data["u_name"],
                              data["u_email"],
                              data["u_pass"],
                              data["u_photo"],
                              data["u_type"]);

                          addStringToSF().then((res){

                            Navigator.push(context, MaterialPageRoute(builder: (cxt)
                            {
                              return new Home(user: true,type: u.u_type,);
                            }));

                          });

                        });
                      }
                      else if (result== "failed")
                      {
                        Fluttertoast.showToast(
                            msg: "failed adding user",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    });
                  } else if (pickedimage == null) {
                    Fluttertoast.showToast(
                        msg: "Please pick your photo",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget checkImage() {
    if (pickedimage == null) return Image.asset("images/user.png");

    return Image.file(pickedimage);
  }

  Future<http.Response> addUser() {
    return http.post(AppServer.SIGNUP_IP, body:
    {
      "user_photo": accountPhoto,
      "user_name": accountName,
      "user_email": accountEmail,
      "user_password": accountPass,
      "user_type": accountType,
    });
  }

  Future<bool> addStringToSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', u.u_id);
    prefs.setString('name', u.u_name);
    prefs.setString('pass', u.u_pass);
    prefs.setString('type', u.u_type);
    prefs.setString('photo', u.u_photo);
    return true;
  }

  Future<http.Response> getUser() {

    return http.post(AppServer.LOGIN_IP, body: {
      "user_name": accountName,
      "user_password": accountPass
    });
  }
}
