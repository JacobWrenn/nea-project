import 'package:app/api.dart';
import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/views/customer/newbooking.dart';
import 'package:app/views/customer/tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomerHome extends StatefulWidget {
  @override
  _CustomerHomeState createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  List bookings = [];
  List filteredBookings = [];
  bool filtering = false;

  final controller = TextEditingController();
  final focus = FocusNode();

  Future loadBookings() async {
    if (filtering) {
      filtering = false;
    } else {
      final res = await Api().makeGet("/booking", {});
      bookings = [];
      filteredBookings = [];
      // We need to iterate to "copy" the array. Otherwise both would end up with a reference to the same structure in memory and not be able to differ.
      for (var booking in res["bookings"]) {
        bookings.add(booking);
        filteredBookings.add(booking);
      }
    }
    return true;
  }

  void filter(String value) {
    filteredBookings = [];
    for (var booking in bookings) {
      // check using lowercase values as searching shouldn't be case sensitive
      if (booking["label"].toLowerCase().contains(value.toLowerCase()))
        filteredBookings.add(booking);
    }
    setState(() {
      filtering = true;
    });
  }

  void track(int id) {
    // When the tracking page is opened, reset the text box so it doesn't stay activated
    controller.clear();
    focus.unfocus();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Tracking(id.toString());
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Home"),
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
        future: loadBookings(),
        builder: (context, snapshot) {
          return !snapshot.hasData
              ? SpinKitRing(color: Colors.blue)
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(height: 32),
                      expansion(button("New Booking", () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return NewBooking();
                          },
                        ));
                      })),
                      SizedBox(height: 32),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: "Filter bookings...",
                        ),
                        onChanged: filter,
                        controller: controller,
                        focusNode: focus,
                      ),
                      SizedBox(height: 32),
                      Expanded(
                        // ListView creates a scrollable list of UI elements in Flutter
                        child: ListView(
                          children: [
                            // Using iteration to populate the ListView
                            for (var booking in filteredBookings)
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black)),
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(booking["label"]),
                                    button("Track", () {
                                      track(booking["bookingid"]);
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
