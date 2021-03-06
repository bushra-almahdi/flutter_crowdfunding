
import 'dart:convert';
import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crowdfunding/AppServer.dart';
import 'package:flutter_crowdfunding/Home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCampaign extends StatefulWidget {
  @override
  _CreateCampaignState createState() => _CreateCampaignState();
}

class _CreateCampaignState extends State<CreateCampaign> {
  GlobalKey<FormState> createCampaign = new GlobalKey();
  File pickedimage;
  String cTitle,cCost,cDisc,cPhoto;
  DateTime dateTime=new DateTime.now();
  String date;
  String startDate;
  String uId;
  @override
  Widget build(BuildContext context)
  {
    getStringValuesSF().then((res){
      uId=res;
    });
    startDate=formatDate(DateTime(dateTime.year, dateTime.month, dateTime.day), [dd, '/', mm, '/', yyyy]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Crowdfunding"),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Form(
          key: createCampaign,
          child: ListView(
            children: <Widget>[
              Container(
                child:checkImage(),
                height: 200,
                width: double.infinity,
              ),
              SizedBox(
                height: 10,
              ),
              FlatButton(
                child: Icon(Icons.camera_alt),
                onPressed: () async
                {
                  pickedimage = await ImagePicker.pickImage(source: ImageSource.gallery);
                  List<int> imageBytes = pickedimage.readAsBytesSync();
                  cPhoto = base64Encode(imageBytes);
                  print(cPhoto);
                  setState(() {});
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Title",
                  hintText: "Enter Project Title",
                  icon: Icon(Icons.title),
                ),
                validator: (title) => title.isEmpty ? "Title is Required" : null,
                onSaved: (title) => cTitle = title,
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Cost",
                  hintText: "Enter Project Cost",
                  icon: Icon(Icons.monetization_on),
                ),
                validator: (cost) =>
                cost.isEmpty ? "Cost is Required" : null,
                onSaved: (cost) => cCost = cost,
              ),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: "Discription",
                  hintText: "Enter Project Description",
                  icon: Icon(Icons.text_fields),
                ),
                validator: (disc) =>
                disc.isEmpty ? "Description is Required" : null,
                onSaved: (disc) => cDisc = disc,
              ),
              SizedBox(
                height: 30,
              ),
              FlatButton(
                child: Text("Create Campaign"),
                color: Colors.purple,
                padding: EdgeInsets.all(20),
                textColor: Colors.white,
                onPressed: ()
                {
                  if (createCampaign.currentState.validate()&& pickedimage != null)
                  {
                    createCampaign.currentState.save();
                    createNewCampaign().then((data)
                    {
                      print(data.body);

                      Navigator.push(context, MaterialPageRoute(builder: (context) => Home(user: true,type: "0",),),);
                    });

                  }
                  else if(pickedimage==null)
                  {
                    Fluttertoast.showToast(
                        msg: "Please pick Project photo",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
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
    if (pickedimage == null) return Image.asset("images/placeHolder.png");

    return Image.file(pickedimage);
  }

  Future<http.Response>createNewCampaign()
  {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    DateTime today = new DateTime(now.year,now.month,now.day);
    DateTime DaysAgo = today.add(new Duration(days: 20));
    String formattedDate2 = DateFormat('dd-MM-yyyy').format(DaysAgo);
    return http.post(AppServer.IP+"add_campaign.php", body: {
      "cPhoto": cPhoto,
      "uId": uId,
      "cTitle": cTitle,
      "cCost": cCost,
      "cDisc": cDisc,
      "cStartDate":formattedDate,
      "cEndDate":formattedDate2,
    });}

  Future <String> getStringValuesSF() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String id = prefs.getString('id');
    return id;
  }
}
