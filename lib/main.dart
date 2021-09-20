import 'package:flutter/material.dart';
import 'package:stories/models/storyCell.dart';
import 'stories.dart';
import 'package:stories/data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<StoryCell> storyCells = [cell, cell1, cell2];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: Scaffold(
          body: Stories(
            cells: storyCells,
            stories: stories,
            backgroundColor: Colors.white,
            indicatorColor: Colors.blue,
          ),
        ));
  }
}
