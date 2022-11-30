import 'package:app/api.dart';
import 'package:app/components/box.dart';
import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/views/staff/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class StaffHome extends StatefulWidget {
  @override
  _StaffHomeState createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  List locations = [];
  List filtered = [];
  List frequents = [];

  final controller = TextEditingController();
  final focus = FocusNode();

  int getLength(frequents) {
    // If there are less than 3 frequently accessed locations, we only need to iterate up to the length of the list
    final length = frequents.length;
    return length >= 3 ? 3 : length;
  }

  Future load() async {
    this.locations = [];
    this.filtered = [];
    this.frequents = [];
    final frequents = await Api().makeGet("/goods/frequents", {});
    if (frequents.length > 0) {
      for (var i = 0; i < getLength(frequents); i++) {
        this.frequents.add(frequents[i]);
      }
    }
    final locations = await Api().makeGet("/booking/locations", {});
    for (var loc in locations["locations"]) {
      this.locations.add(loc);
      this.filtered.add(loc);
    }
    return true;
  }

  void open(int id, String name) {
    Api().makePost("/goods/frequents", {}, {"locationid": id});
    controller.clear();
    focus.unfocus();
    filter("");
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Location(id.toString(), name);
    }));
  }

  void filter(String value) {
    setState(() {
      filtered = [];
      for (var loc in locations) {
        if (loc["name"].toLowerCase().contains(value.toLowerCase()))
          filtered.add(loc);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Staff Home"),
        // Important to prevent a back button automatically appearing and allowing a return to the login page without logging out
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await Api().logout();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: load(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? SpinKitRing(color: Colors.blue)
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        // Only show frequents box if there are some to show
                        if (frequents.length > 0) ...[
                          SizedBox(height: 32),
                          expansion(box(Column(
                            children: [
                              Text("Frequently Accessed"),
                              for (var f in frequents) ...[
                                SizedBox(height: 16),
                                expansion(button(f["name"], () {
                                  open(f["locationid"], f["name"]);
                                })),
                              ],
                            ],
                          )))
                        ],
                        SizedBox(height: 32),
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: "Filter locations...",
                          ),
                          onChanged: (value) => filter(value),
                          controller: controller,
                          focusNode: focus,
                        ),
                        SizedBox(height: 32),
                        Expanded(
                          child: ListView(
                            children: [
                              for (var l in filtered) ...[
                                expansion(button(l["name"], () {
                                  open(l["locationid"], l["name"]);
                                })),
                                SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          }),
    );
  }
}
