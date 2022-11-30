import 'package:app/api.dart';
import 'package:app/components/buttons.dart';
import 'package:app/helpers/datetimeutil.dart';
import 'package:app/views/staff/goodlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TrainList extends StatefulWidget {
  final String type;
  final String id;

  TrainList(this.type, this.id);

  @override
  _TrainListState createState() => _TrainListState();
}

class _TrainListState extends State<TrainList> {
  List filters = ["In the next hour", "All day"];
  String current = "In the next hour";
  List trains = [];
  List filteredTrains = [];
  bool loaded = false;

  String getName() {
    if (widget.type == "due") {
      return "Trains due";
    } else {
      return "Trains starting here";
    }
  }

  String getUrl() {
    if (widget.type == "due") {
      return "/get";
    } else {
      return "/getstarting";
    }
  }

  Future load() async {
    final trains =
        await Api().makeGet("/train/${getUrl()}", {"locationid": widget.id});
    for (var train in trains) {
      this.trains.add(train);
    }
    filter();
    setState(() {
      loaded = true;
    });
  }

  void filter() {
    Function function;
    if (current == filters[0]) {
      function = (train) {
        return withinHour(train["time"]);
      };
    } else {
      function = (train) {
        return true;
      };
    }
    filteredTrains = [];
    for (var train in trains) {
      if (function(train)) filteredTrains.add(train);
    }
  }

  void details(int trainid) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return GoodList("train", trainid.toString());
    }));
  }

  Future start(scheduleid) async {
    // Show confirmation after a train is started
    await Api().makePost("/train/start", {}, {"scheduleid": widget.id});
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text("Train started!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) load();

    return Scaffold(
      appBar: AppBar(
        title: Text(getName()),
      ),
      body: !loaded
          ? SpinKitRing(color: Colors.blue)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(height: 32),
                  DropdownButton(
                    items: [
                      for (var filter in filters)
                        DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        ),
                    ],
                    value: current,
                    isExpanded: true,
                    onChanged: (val) => setState(() {
                      current = val;
                      filter();
                    }),
                  ),
                  SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      children: [
                        for (var train in filteredTrains) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "${formatTime(getTime(train["time"]))} to ${train["name"]}",
                                    softWrap: true,
                                  ),
                                ),
                                Spacer(),
                                // Different actions depending on if this is a "trains at" or "trains starting"
                                widget.type == "due"
                                    ? button("Details",
                                        () => details(train["trainid"]))
                                    : button("Start",
                                        () => start(train["scheduleid"])),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
