import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/views/customer/deliveryplan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

class NewBooking extends StatefulWidget {
  @override
  _NewBookingState createState() => _NewBookingState();
}

class _NewBookingState extends State<NewBooking> {
  // final data to be sent to server
  int hub;
  String address;
  int volume;
  String label;
  String type;
  DateTime initialDate = DateTime.now().add(Duration(days: 1));

  // values to configure the booking form
  String postcode;
  DateTime firstDate = DateTime.now().add(Duration(days: 1));
  DateTime lastDate = DateTime.now().add(Duration(days: 31));

  // data fetched from server
  List<String> addresses = [];
  List<String> types = [];
  List<Map<String, dynamic>> hubs = [];
  bool loaded = false;

  Future addressSearch() async {
    final key = "HY58-XG15-UH83-BX67";
    String url =
        "https://api.addressy.com/Capture/Interactive/Find/v1.10/json3.ws?Key=$key&Text=$postcode&Countries=GB";
    Response res = await get(Uri.parse(url));
    Map<String, dynamic> json = jsonDecode(res.body);
    if (json["Items"][0]["Type"] == "Postcode") {
      String id = json["Items"][0]["Id"];
      // Container ID represents a postcode and is used to fetch the associated addresses
      url = url + "&Container=$id";
      res = await get(Uri.parse(url));
      json = jsonDecode(res.body);
    }
    // Remove addresses from any previous search
    addresses = [];
    address = null;
    for (var address in json["Items"]) {
      this.addresses.add("${address["Text"]} $postcode");
    }
    setState(() {});
  }

  Future load() async {
    final hubsJson =
        (await Api().makeGet("/booking/locations", {}))["locations"];
    for (var hub in hubsJson) {
      if (hub["hub"])
        hubs.add({"locationid": hub["locationid"], "name": hub["name"]});
    }
    final typesJson = (await Api().makeGet("/booking/types", {}))["types"];
    for (var type in typesJson) {
      types.add(type["goodtype"]);
    }
    setState(() {
      loaded = true;
    });
  }

  Future generatePlan() async {
    // Ensure all fields are not empty before submitting
    if (label == null ||
        hub == null ||
        address == null ||
        type == null ||
        volume == null) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(title: Text("Please complete all fields!"));
          });
    } else {
      final data = {
        "origin": hub,
        "address": address,
        "arrival": initialDate.millisecondsSinceEpoch,
        "type": type,
        "volume": volume,
        "label": label
      };
      final deliveryPlan =
          await Api().makePost("/booking/deliveryplan", {}, data);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return DeliveryPlan(deliveryPlan, data, getHubName(), address);
      }));
    }
  }

  // Find the name matching a location ID
  String getHubName() {
    for (var hub in hubs) {
      if (hub["locationid"] == this.hub) return hub["name"];
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) load();

    return Scaffold(
      appBar: AppBar(
        title: Text("New Booking"),
      ),
      body: !loaded
          ? SpinKitRing(color: Colors.blue)
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  SizedBox(height: 32),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Label this booking...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      label = value;
                    },
                    initialValue: label,
                  ),
                  SizedBox(height: 16),
                  DropdownButton(
                    hint: Text("Select origin logistics hub"),
                    // Map the list of locations to a list of dropwdown options
                    items: hubs
                        .map((hub) => DropdownMenuItem(
                              child: Text(hub["name"]),
                              value: hub["locationid"],
                            ))
                        .toList(),
                    value: hub,
                    isExpanded: true,
                    onChanged: (val) => setState(() {
                      hub = val;
                    }),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Enter delivery postcode",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      postcode = value;
                    },
                    initialValue: postcode,
                  ),
                  SizedBox(height: 16),
                  expansion(button("Search for addresses", addressSearch)),
                  SizedBox(height: 16),
                  DropdownButton(
                    hint: Text("Specify exact address"),
                    items: addresses
                        .map((address) => DropdownMenuItem(
                              child: Text(address),
                              value: address,
                            ))
                        .toList(),
                    value: address,
                    isExpanded: true,
                    onChanged: (val) => setState(() {
                      address = val;
                    }),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text("Select arrival date"),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      // Flutter provides a material design style date picker
                      initialDate = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
                        firstDate: firstDate,
                        lastDate: lastDate,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButton(
                    hint: Text("Select type of goods"),
                    items: types
                        .map((type) => DropdownMenuItem(
                              child: Text(type),
                              value: type,
                            ))
                        .toList(),
                    value: type,
                    isExpanded: true,
                    onChanged: (val) => setState(() {
                      type = val;
                    }),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Input volume",
                      border: OutlineInputBorder(),
                    ),
                    // Validation to ensure the form can never be submitted with a non-integer value as volume
                    onChanged: (value) {
                      volume = value == "" ? null : int.parse(value);
                    },
                    initialValue: volume == null ? null : volume.toString(),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  ),
                  SizedBox(height: 16),
                  expansion(button("Generate Delivery Plan", generatePlan)),
                ],
              ),
            ),
    );
  }
}
