import 'package:app/api.dart';
import 'package:app/components/buttons.dart';
import 'package:app/helpers/datetimeutil.dart';
import 'package:app/views/staff/good.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class GoodList extends StatefulWidget {
  final String type;
  final String id;

  GoodList(this.type, this.id);

  @override
  _GoodListState createState() => _GoodListState();
}

class _GoodListState extends State<GoodList> {
  List filters = [];
  String current;
  List goods = [];
  List filteredGoods = [];
  bool loaded = false;

  @override
  void initState() {
    filters = widget.type == "train"
        ? ["Display all", "Display unloads here"]
        : ["In the next hour", "All day"];
    current = filters[0];
    super.initState();
  }

  String getName() {
    if (widget.type == "due") return "Goods due to arrive";
    if (widget.type == "at") return "Goods at this location";
    if (widget.type == "train") return "Goods on train";
    return "";
  }

  // Depending on what type of good list has been intialised, the URL and headers of the API request will need to be adjusted to ensure the correct list of goods is returned
  String getUrl() {
    if (widget.type == "train") {
      return "/getontrain";
    } else {
      return "/get";
    }
  }

  Map<String, String> getHeaders() {
    if (widget.type == "train") {
      return {"trainid": widget.id};
    } else {
      return {
        "locationid": widget.id,
        "due": widget.type == "due" ? "true" : "false"
      };
    }
  }

  Future load() async {
    final goods = await Api().makeGet("/goods/${getUrl()}", getHeaders());
    for (var good in goods) {
      this.goods.add(good);
    }
    filter();
    setState(() {
      loaded = true;
    });
  }

  void filter() {
    Function function;
    if (widget.type == "train") {
      if (current == filters[0]) {
        function = (good) {
          return true;
        };
      } else {
        function = (good) {
          return good["unloadshere"] == true;
        };
      }
    } else {
      if (current == filters[0]) {
        function = (good) {
          return withinHour(good["time"]);
        };
      } else {
        function = (good) {
          return true;
        };
      }
    }
    filteredGoods = [];
    for (var good in goods) {
      if (function(good)) filteredGoods.add(good);
    }
  }

  void details(int goodid) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Good(goodid.toString());
    }));
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
                        for (var good in filteredGoods) ...[
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text("ID: ${good["goodid"]}"),
                                SizedBox(width: 16),
                                // Different info needs to be displayed for goods depending on the type of list being shown
                                widget.type == "train"
                                    ? Text(good["unloadshere"]
                                        ? "Unloads here"
                                        : "")
                                    : Text(
                                        "${widget.type == "due" ? "Due" : "Leaving"}: ${formatTime(getTime(good["time"]))}"),
                                Spacer(),
                                button(
                                    "Details", () => details(good["goodid"])),
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
