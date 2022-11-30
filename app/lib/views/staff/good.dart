import 'package:app/api.dart';
import 'package:app/components/box.dart';
import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/helpers/datetimeutil.dart';
import 'package:app/helpers/mostrelevantpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Good extends StatefulWidget {
  final String id;

  Good(this.id);

  @override
  _GoodState createState() => _GoodState();
}

class _GoodState extends State<Good> {
  int volume;
  String type;
  String origin;
  String dest;
  bool waitToReceive = false;
  bool handOver = false;
  bool loadOn = false;
  bool unload = false;
  List details = [];
  dynamic most;

  bool loaded = false;

  Future load() async {
    dynamic details =
        await Api().makeGet("/goods/details", {"goodid": widget.id});
    type = details[0]["goodtype"].toLowerCase();
    volume = details[0]["number"];
    origin = details[0]["name"];
    dest = details[0]["destination"].substring(0, 18) + "...";
    for (var detail in details) {
      this.details.add(detail);
    }
    this.details.sort(compare);
    if (!details[0]["received"]) {
      waitToReceive = true;
    } else if (allDone(details)) {
      handOver = true;
    } else {
      most = getMostRelevantPoint(this.details);
      loadOn = most["unload"] != true;
      unload = most["unload"] == true;
    }
    setState(() {
      loaded = true;
    });
  }

  bool allDone(details) {
    // if any one point hasn't been completed then the whole jounrey isn't complete
    bool done = true;
    for (var detail in details) {
      if (detail["completed"] != true) done = false;
    }
    return done;
  }

  void update(body) async {
    await Api().makePost("/goods/update", {}, {"goodid": widget.id, ...body});
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: Text("Updated!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) load();

    return Scaffold(
      appBar: AppBar(
        title: Text("Good details"),
      ),
      body: !loaded
          ? SpinKitRing(color: Colors.blue)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32),
                  Text(
                    "ID: ${widget.id}",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 16),
                  Text("Volume: $volume $type"),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.circle_outlined),
                      SizedBox(width: 8),
                      Text(origin),
                      Spacer(),
                      Icon(Icons.place_outlined, color: Colors.red),
                      SizedBox(width: 8),
                      Text(dest),
                    ],
                  ),
                  SizedBox(height: 32),
                  box(Column(
                    children: [
                      if (waitToReceive) ...[
                        Text(
                            "Due to arrive at $origin by ${formatTime(getTime(details[0]["time"]))}."),
                        SizedBox(height: 16),
                        Text(
                            "Due to leave on the ${formatTime(getTime(details[0]["time"]))} to ${details[0]["name3"]}."),
                      ],
                      if (handOver) ...[
                        Text(
                            "Due to be handed over to a local delivery partner."),
                      ],
                      if (loadOn || unload) ...[
                        Text(
                            "Due to ${loadOn ? "leave" : "arrive"} on the ${formatTime(getTime(most["time"]))} to ${most["name3"]}."),
                      ],
                    ],
                  )),
                  SizedBox(height: 32),
                  if (waitToReceive)
                    expansion(button("Confirm Good Received", () async {
                      update({"goodStatus": true, "status": "received"});
                    })),
                  if (handOver)
                    expansion(button("Confirm Handed to Delivery", () async {
                      update({"goodStatus": true, "status": "handedover"});
                    })),
                  if (loadOn || unload)
                    expansion(button(
                        "Confirm ${loadOn ? "Loaded Onto Train" : "Unloaded"}",
                        () async {
                      update({
                        "trainid": most["trainid"],
                        "locationid": most["locationid"],
                        "unload": unload
                      });
                    })),
                ],
              ),
            ),
    );
  }
}
