import 'dart:convert';

import 'package:dpay_flutter/CheckoutOptions.dart';
import 'package:dpay_flutter/dpay_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

const PRODUCTION_ORDERS_URL = "api.durianpay.id";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  var durianpay;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.all(25),
            child: FlatButton(
              child: Text(
                'Click here',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                loadCheckout();
              },
            ),
          ),
        ]),
      ),
    ));
  }

  void loadCheckout() {
    Durianpay durianpay = Durianpay.getInstance(context);
    DCheckoutOptions checkoutOptions = new DCheckoutOptions();
    checkoutOptions.locale = "en";
    checkoutOptions.environment = "production";
    checkoutOptions.siteName = "MovieTicket";
    checkoutOptions.customerId = "cust001";
    checkoutOptions.customerGivenName = "jade cusper";
    checkoutOptions.customerEmail = "abc@gmail.com";
    checkoutOptions.amount = "10000";
    checkoutOptions.currency = "IDR";
    checkoutOptions.darkMode = true;
    createOrder().then((value) => {
          checkoutOptions.accessToken = value.access_token,
          checkoutOptions.orderId = value.order_id,
          durianpay.clear(),
          durianpay.checkout(checkoutOptions),
        });
  }
}

class OrderResponse {
  final String order_id;
  final String access_token;

  OrderResponse({this.order_id, this.access_token});

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      order_id: json['data']['id'],
      access_token: json['data']['access_token'],
    );
  }
}

Future<OrderResponse> createOrder() async {
  List items = [];
  var itemDetails = {'name': "Shoes", 'qty': 1, 'price': "20000"};
  items.add(itemDetails);

  var body = jsonEncode(<String, dynamic>{
    'amount': '150000',
    'currency': "IDR",
    'customer': {
      "customer_ref_id": "cust user170390",
      "email": "joedoe@gmail.com",
      "given_name": "John Doe"
    },
    "items": items,
    "order_ref_id": "order170390"
  });

  final http.Response response =
      await http.post(Uri.https(PRODUCTION_ORDERS_URL, "/orders"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': '<base encoded secret key>',
          },
          body: body);
  if (response.statusCode == 200 || response.statusCode == 201) {
    // logger.i(jsonDecode(response.body));
    return OrderResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load');
  }
}
