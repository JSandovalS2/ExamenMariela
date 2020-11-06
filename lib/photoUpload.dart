import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'homePage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:intl/intl.dart';

class PhotoUpload extends StatefulWidget {
  @override
  _PhotoUploadState createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  File sampleImage;
  String _myValue; //descripcion
  String url; //url de imagen

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Image"),
        centerTitle: true,),
      body: Center(
        child: sampleImage == null ? Text("Select an Image") : enableUpload(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: "Add Image",
        child: Icon(Icons.add_a_photo),
      ),

    );
  }

  Future getImage() async{
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  Widget enableUpload(){
    return SingleChildScrollView (
        child: Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),

              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Image.file(sampleImage, height: 300.0,width: 600.0,),
                    SizedBox(height:15.0,),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Descripción"),
                      validator: (value){
                        return value.isEmpty ? "Una Descripcion es requerida" : null;
                      },
                      onSaved: (value){
                        return _myValue = value;
                      },
                    ),

                    SizedBox(
                      height: 15.00,
                    ),

                    RaisedButton(
                      elevation: 10.0,
                      child: Text("Añadir un nuevo Post"),
                      textColor: Colors.white,
                      color: Colors.green,
                      onPressed: uploadStatusImage,
                    )


                  ],
                ),
              ),
            )));
  }

  void uploadStatusImage() async
  {
    if(validateAndSave())
    {
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Post Images");

      var timeKey = DateTime.now();
      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString()+".jpg").putFile(sampleImage);
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();

      url = imageUrl.toString();
      print("Image url "+url);

      //guarda el post a firebase
      savetodatabase(url);


      //regresa a home
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return HomePage();}));
    }
  }

  void savetodatabase(String url)
  {
    //guardar un post (image, descripcion, date, time
    var dbTimeKey = DateTime.now();
    var formatDate = DateFormat("MM d, yyy");
    var formatTime = DateFormat("EEEE, hh:mm aaa");

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
    };

    ref.child("Posts").push().set(data);
  }




  bool validateAndSave(){
    final form = formKey.currentState;

    if(form.validate()){
      form.save();
      return true;
    }else{
      return false;
    }
  }
}
