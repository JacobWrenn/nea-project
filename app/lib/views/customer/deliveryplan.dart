import 'package:app/api.dart';
import 'package:app/components/buttons.dart';
import 'package:app/components/expansion.dart';
import 'package:app/helpers/datetimeutil.dart';
import 'package:app/views/customer/tracking.dart';
import 'package:flutter/material.dart';

class DeliveryPlan extends StatefulWidget {
  final deliveryPlan;
  final data;
  final origin;
  final address;

  // the delivery plan needs to take in data from the booking form in order to facilitate the confirmation and rejection options
  DeliveryPlan(this.deliveryPlan, this.data, this.origin, this.address);

  @override
  _DeliveryPlanState createState() => _DeliveryPlanState();
}

class _DeliveryPlanState extends State<DeliveryPlan> {
  // simple maths to calculate percentage CO2 saving from the server provided delivery plan
  int getSaving() {
    final lorry = widget.deliveryPlan["co2"]["lorry"];
    final route = widget.deliveryPlan["co2"]["route"];
    final diff = lorry - route;
    final percent = diff / lorry * 100;
    return percent.round();
  }

  Future accept() async {
    int id = (await Api().makePost("/booking/accept", {}, widget.data))["id"];
    // Before navigating to the tracking page, pop this page and the booking form from the navigation stack. This will allow the back arrow on the tracking page to return the user straight to the list of bookings.
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Tracking(id.toString());
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery Plan"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle_outlined),
                              SizedBox(width: 16),
                              Text(widget.origin),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.place_outlined, color: Colors.red),
                              SizedBox(width: 16),
                              // Truncate the address so it doesn't overflow the side of the phone
                              Text("${widget.address.substring(0, 28)}..."),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.credit_card),
                              SizedBox(width: 16),
                              Text("£${widget.deliveryPlan["price"]}"),
                            ],
                          ),
                          SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(color: Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text("Latest drop off time"),
                              ),
                              Expanded(
                                child: Divider(color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 16),
                              Text(formatDate(
                                  widget.deliveryPlan["start"]["date"])),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.schedule),
                              SizedBox(width: 16),
                              Text(widget.deliveryPlan["start"]["time"]),
                            ],
                          ),
                          SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(color: Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text("Estimated arrival"),
                              ),
                              Expanded(
                                child: Divider(color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.calendar_today),
                              SizedBox(width: 16),
                              Text(formatDate(
                                  widget.deliveryPlan["end"]["date"])),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.schedule),
                              SizedBox(width: 16),
                              Text(widget.deliveryPlan["end"]["time"]),
                            ],
                          ),
                          SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(color: Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text("CO2 Estimate"),
                              ),
                              Expanded(
                                child: Divider(color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text("${getSaving()}% CO2 emission saving"),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.train),
                              SizedBox(width: 16),
                              Text(
                                  "${widget.deliveryPlan["co2"]["route"]}kg CO2e"),
                              SizedBox(width: 32),
                              Icon(Icons.local_shipping),
                              SizedBox(width: 16),
                              Text(
                                  "${widget.deliveryPlan["co2"]["lorry"]}kg CO2e"),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            expansion(button("Cancel", () {
              Navigator.pop(context);
            }, color: Colors.red)),
            SizedBox(height: 16),
            expansion(button("Accept", accept, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
