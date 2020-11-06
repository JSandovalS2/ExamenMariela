import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'homePage.dart';

void main() {
  runApp(AppBlog());
}

class AppBlog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AppBlog",
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
