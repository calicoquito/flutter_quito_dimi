import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'addmembers.dart';

class EventsInfoEdit extends StatefulWidget {
  final String url;
  EventsInfoEdit({@required this.url});
  EventsInfoEditState createState() => EventsInfoEditState(url: url);
}

class EventsInfoEditState extends State<EventsInfoEdit> {
  final String url;
  EventsInfoEditState({@required this.url});
  //final String url = "http://192.168.100.67:8080/Plone/projects";
  //TextEditingController controller = TextEditingController();
  String textString = "";
  bool isSwitched = false;
  List setval = List();
  var photo = null;
  Map data = Map();
  File croppedFile;


  @override
  void initState() {
    super.initState();
    print(url);
    getdata();

  }

  Map jsonstr = {
      "@type": "project",
      "title": "Project by api 4",
      "description": "Project for tessting purposes",
      "attendees": [],
      "start": "2019-06-12T17:20:00+00:00",
      "end": "2020-06-17T19:00:00+00:00",
      "whole_day": false,
      "open_end": false,
      "sync_uid": null,
      "contact_name": "",
      "contact_email": "",
      "contact_phone": "",
      "event_url": null,
      "location": "Office Quito",
      "recurrence": null,
      "image": {
        "filename": "test.jpg",
        "content-type": "image/jpeg",
        "data": "",
        "encoding": "base64"
      },
      "image_caption": "Image captions",
      "text": {
        "content-type": "text/html",
        "data":
            "<h1><em><strong>This event is just for test that starts at 12 today and goes on until I feel like it should stop</strong></em></h1>",
        "encoding": "utf-8"
      },
      "changeNote": null
    };

  Future<void> _optionsDialogBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Take a photo'),
                        Icon(Icons.camera)
                      ],
                    ),
                    onTap: () {
                      openimg(ImageSource.camera);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Select from gallery'),
                        Icon(Icons.image)
                      ],
                    ),
                    onTap: () {
                      openimg(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<String> getdata() async {
    var resp = await http.get(url, headers: {
      "Accept": "application/json",
    });
    print(resp.statusCode);
    data = json.decode(resp.body);


      setState(() {
        photo = data['image'] == null ? null : Image.network(data['image']['download']);
      });

    return "Success!";
  }

  Future openimg(ImageSource source) async {
    var file = await ImagePicker.pickImage(source: source);
    cropImage(file);
    file = photo;
    var base64Image = file != null ? base64Encode(file.readAsBytesSync()) : "";
    jsonstr["image"]["data"] = base64Image;
  }

  Future cropImage(File imageFile) async {
    croppedFile = await ImageCropper.cropImage(
      toolbarColor: Color(0xff7e1946),
      //check this color
      statusBarColor: Colors.blueGrey,
      toolbarWidgetColor: Colors.white,
      sourcePath: imageFile.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );
    setState(() {
      photo = Image.file(croppedFile);
    });
    Navigator.of(context, rootNavigator: true).pop(context);
  }

  Future<String> uploadImg() async {
    String imgstring = croppedFile == null ? "" : base64Encode(croppedFile.readAsBytesSync());
    jsonstr["image"]["data"] = data["image"] != null ? File.fromUri(data['image']['download']) :
     imgstring ;
    var bytes = utf8.encode("admin:admin");
    var credentials = base64.encode(bytes);
    
    var resp = await http.patch(url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Basic $credentials"
        },
        body: jsonEncode(jsonstr));
    print(resp.statusCode);
    print(resp.body);
    return "Success!";
  }

  Widget inputWidget(
      {icon: Icon, use_switch = "", txt: Text, drop: DropdownButton}) {
    setState(() {
      jsonstr[txt] = data[txt];
    });

    String diplaytxt = txt.replaceAll(new RegExp(r'_'), ' ');
    diplaytxt = '${diplaytxt[0].toUpperCase()}${diplaytxt.substring(1)}';
    double width = MediaQuery.of(context).size.width;
    var padtext = Text(
      diplaytxt,
      style: TextStyle(fontFamily: 'Nunito', fontSize: 20.0),
    );
    var text = TextFormField(
      initialValue: jsonstr[txt].runtimeType == String ? jsonstr[txt] : '',
      autocorrect: true,
      //controller: controller,
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        labelText: diplaytxt,
        contentPadding: EdgeInsets.all(14.0),
      ),
      onFieldSubmitted: (string) {
        setState(() {
          jsonstr[txt] = string;
          //print(jsonstr);
        });
      },
      onEditingComplete: () {
        //controller.clear();
      },
    );
    var switch_true = Switch(
        value: jsonstr[use_switch] == true ? true : false,
        onChanged: (value) {
          setState(() {
            jsonstr[use_switch] = value;
          });
        });
    return Container(
        padding: EdgeInsets.only(top: 4.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(left: 4.0, right: 8.0),
                      child: icon),
                  use_switch == ""
                      ? Container(
                          width: width * .7,
                          child: text,
                        )
                      : Container(
                          width: width * .7,
                          child: padtext,
                        ),
                  use_switch == "" ? Text("") : switch_true
                ],
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Edit Project',
        style: TextStyle(fontFamily: 'Nunito', fontSize: 20.0),
      )),
      body: ListView(children: <Widget>[
        Container(
          color: Colors.black54,
          //padding: EdgeInsets.all(20.0),
          child: FlatButton(
            padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
            color: Colors.black54,
            child: photo == null
                ? Icon(
                    Icons.add_a_photo,
                    size: 80.0,
                    color: Colors.white,
                  )
                : photo,
            onPressed: () {
              _optionsDialogBox();
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, left: 50.0, right: 50.0),
          child: Container(
              height: 60,
              child: RaisedButton(
                onPressed: () async {
                  List addedPersons = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return AddMembersPage();
                  }));
                  setState(() {
                    jsonstr["attendees"] = json.encode(addedPersons);
                  });
                },
                child: Icon(
                  Icons.group_add,
                  color: Colors.white,
                ),
              )),
        ),
        Container(
            padding: EdgeInsets.symmetric(vertical: 30.0),
            child: Text(
              jsonstr["attendees"] == null
                  ? "No one assigned yet"
                  : '${jsonstr["attendees"].length} person(s) added to this project',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            )),
        inputWidget(icon: Icon(Icons.title), txt: jsonstr.keys.elementAt(1)),
        inputWidget(
            icon: Icon(Icons.import_contacts), txt: jsonstr.keys.elementAt(2)),
        inputWidget(
            icon: Icon(Icons.access_time),
            txt: jsonstr.keys.elementAt(6),
            use_switch: jsonstr.keys.elementAt(6)),
        inputWidget(
            icon: Icon(Icons.timer_off),
            txt: jsonstr.keys.elementAt(7),
            use_switch: jsonstr.keys.elementAt(7)),
        inputWidget(icon: Icon(Icons.contacts), txt: jsonstr.keys.elementAt(9)),
        inputWidget(icon: Icon(Icons.email), txt: jsonstr.keys.elementAt(10)),
        inputWidget(icon: Icon(Icons.phone), txt: jsonstr.keys.elementAt(11)),
        inputWidget(
            icon: Icon(Icons.add_location), txt: jsonstr.keys.elementAt(13)),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          uploadImg();
          Navigator.of(context, rootNavigator: true).pop(context);
        },
        tooltip: 'Create Project',
        child: Icon(Icons.check),
      ),
    );
  }
}
