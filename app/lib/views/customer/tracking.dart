import 'package:app/api.dart';
import 'package:app/components/box.dart';
import 'package:app/components/expansion.dart';
import 'package:app/helpers/datetimeutil.dart';
import 'package:app/helpers/mostrelevantpoint.dart';
import 'package:app/helpers/textcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';

class Tracking extends StatefulWidget {
  final String id;

  Tracking(this.id);

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  String origin;
  String destination;
  String arrivalDate;
  String arrivalTime;
  Color alert;
  String alertText;
  bool received = true;
  bool handedover = false;
  bool delivered = false;
  bool loaded = false;
  dynamic tracking = [];

  // flutter_map specific variables
  LatLng center;
  List<Marker> markers = [];
  List<Polyline> lines = [];
  final controller = MapController();

  Future load() async {
    final tracking = (await Api()
        .makeGet("/booking/tracking", {"bookingid": widget.id}))["tracking"];
    origin = tracking[0]["name"];
    destination = tracking[0]["destination"];
    arrivalDate = formatDate(getArrivalDate(tracking).toIso8601String());
    arrivalTime = getArrivalTime(tracking);
    // the sort method alters the original variable rather than returning a new list
    tracking.sort(compare);
    final status = getTrackingStatus(tracking);
    alert = status[1];
    alertText = status[0];
    final point = getMostRelevantPoint(tracking);
    center = getLatLng(point);
    prepareMap(tracking);
    setState(() {
      loaded = true;
    });
  }

  void prepareMap(tracking) {
    dynamic prev;
    List<LatLng> points = [];
    for (var point in tracking) {
      if (point["unload"]) this.tracking.add(point);
      if (!points.contains(getLatLng(point))) {
        // Markers represent an icon on the map at an individual point
        markers.add(Marker(
          point: getLatLng(point),
          width: 20,
          height: 20,
          builder: (context) {
            return expansion(Container(
              decoration: BoxDecoration(
                color: point["completed"] == null || !point["completed"]
                    ? Colors.blue
                    : Colors.green,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ));
          },
        ));
        points.add(getLatLng(point));
        if (prev != null) {
          // Polylines join up multiple points
          lines.add(Polyline(
            points: [getLatLng(point), getLatLng(prev)],
            color: Colors.grey,
            borderColor: Colors.black,
            strokeWidth: 5,
            borderStrokeWidth: 2,
          ));
        }
        prev = point;
      }
    }
    // We want to the whole journey to fit on the map. Once the map has initalised, it makes a method available to achieve this.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.fitBounds(LatLngBounds.fromPoints(points));
    });
  }

  // flutter_map asks for points to be represented in a specific LatLng data type
  LatLng getLatLng(point) {
    return LatLng(double.parse(point["lat"]), double.parse(point["long"]));
  }

  DateTime getArrivalDate(tracking) {
    // The arrival date can be found on the point with the greatest date listed. 0 milliseconds since the epoch is a safe date to start the comparisons against.
    DateTime date = DateTime.fromMillisecondsSinceEpoch(0);
    for (var point in tracking) {
      final pointDate = DateTime.parse(point["date"]);
      if (date.compareTo(pointDate) < 0) date = pointDate;
    }
    return date;
  }

  String getArrivalTime(tracking) {
    final arrivalDate = getArrivalDate(tracking);
    DateTime time =
        DateTime(arrivalDate.year, arrivalDate.month, arrivalDate.day, 0, 0);
    for (var point in tracking) {
      int delay = point["delay"] != null ? point["delay"] : 0;
      final dateTime = getDateTime(point).add(Duration(minutes: delay));
      if (time.compareTo(dateTime) < 0) time = dateTime;
    }
    return formatTime(TimeOfDay.fromDateTime(time.add(Duration(hours: 2))));
  }

  List getTrackingStatus(tracking) {
    if (tracking[0]["received"] == false) {
      received = false;
      return ["Waiting to recieve goods...", Colors.grey];
    } else if (tracking[0]["handedover"] == true) {
      handedover = true;
      return ["Out for final delivery...", Colors.blue];
    } else if (tracking[0]["complete"] == true) {
      delivered = true;
      return ["Order complete!", Colors.green];
    } else {
      final status = getMostRelevantPoint(tracking);
      if (status["unload"]) {
        return ["Goods on train...", Colors.orange];
      } else {
        return ["Goods waiting to be loaded...", Colors.orange];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) load();

    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking"),
      ),
      body: !loaded
          ? SpinKitRing(color: Colors.blue)
          : Column(
              children: [
                expansion(Container(
                  color: alert,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      alertText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor(alert),
                        fontSize: 16,
                      ),
                    ),
                  ),
                )),
                box(Row(
                  children: [
                    Icon(Icons.circle_outlined),
                    SizedBox(width: 16),
                    Text(origin),
                    Spacer(),
                    Icon(Icons.place_outlined, color: Colors.red),
                    SizedBox(width: 16),
                    Text("${destination.substring(0, 18)}..."),
                  ],
                )),
                Expanded(
                  child: FlutterMap(
                    mapController: controller,
                    options: MapOptions(
                      center: center,
                    ),
                    layers: [
                      // Use open street map as the base map layer
                      TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      PolylineLayerOptions(
                        polylines: lines,
                      ),
                      // Position the markers above the polylines to cover the ends of the lines
                      MarkerLayerOptions(
                        markers: markers,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 16, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: received
                            ? [
                                Icon(Icons.done, color: Colors.green),
                                SizedBox(width: 16),
                                Text("Goods received"),
                              ]
                            : [
                                Icon(Icons.more_horiz),
                                SizedBox(width: 16),
                                Text("Waiting to receive goods"),
                              ],
                      ),
                      for (var point in tracking) ...[
                        SizedBox(height: 8),
                        Row(
                          children: point["completed"]
                              ? [
                                  Icon(Icons.done, color: Colors.green),
                                  SizedBox(width: 16),
                                  Text("Arrived at hub"),
                                ]
                              : [
                                  Icon(Icons.more_horiz),
                                  SizedBox(width: 16),
                                  Text("Due to arrive at hub"),
                                ],
                        ),
                      ],
                      SizedBox(height: 8),
                      Row(
                        children: handedover
                            ? [
                                Icon(Icons.done, color: Colors.green),
                                SizedBox(width: 16),
                                Text("Goods handed to final delivery"),
                              ]
                            : [
                                Icon(Icons.more_horiz),
                                SizedBox(width: 16),
                                Text("Not yet out for delivery"),
                              ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: delivered
                            ? [
                                Icon(Icons.done, color: Colors.green),
                                SizedBox(width: 16),
                                Text("Goods delivered"),
                              ]
                            : [
                                Icon(Icons.more_horiz),
                                SizedBox(width: 16),
                                Text("Not yet delivered"),
                              ],
                      ),
                    ],
                  ),
                ),
                box(Padding(
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 24),
                  child: Column(
                    children: [
                      Text("Estimated arrival"),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text(arrivalDate),
                          Spacer(),
                          SizedBox(height: 16),
                          Icon(Icons.schedule),
                          SizedBox(width: 16),
                          Text(arrivalTime),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
    );
  }
}
