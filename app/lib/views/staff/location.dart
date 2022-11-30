import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/views/staff/goodlist.dart';
import 'package:app/views/staff/trainlist.dart';
import 'package:flutter/material.dart';

class Location extends StatefulWidget {
  final String name;
  final String id;

  // Location page needs to know it's name and ID in order to create the next level of pages
  Location(this.id, this.name);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  void goodList(String type) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return GoodList(type, widget.id);
    }));
  }

  void trainList(String type) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TrainList(type, widget.id);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  expansion(button("Goods due to arrive", () {
                    goodList("due");
                  })),
                  SizedBox(height: 16),
                  expansion(button("Goods at this location", () {
                    goodList("at");
                  })),
                  SizedBox(height: 16),
                  expansion(button("Trains Due", () {
                    trainList("due");
                  })),
                  SizedBox(height: 16),
                  expansion(button("Trains Starting Here", () {
                    trainList("starting");
                  })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
