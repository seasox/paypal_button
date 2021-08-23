import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_auth/http_auth.dart';
import 'package:paypal_button/paypal_button.dart';
import 'package:paypal_button/paypal_order_params.dart';
import 'package:paypal_button/paypal_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void onPayPalFinish(BuildContext context, String orderId) {
    print(orderId);
    Navigator.pop(context);
  }

  // for getting the access token from Paypal
  Future<String> createPayPalAccessTokenLocal(PayPalServiceMode mode) async {
    // create access token locally.
    // !!! DO NOT SHIP YOUR PAYPAL API SECRET WITH YOUR APP !!!
    String clientId = 'YOUR_CLIENT_ID';
    String secret = 'YOUR_CLIENT_SECRET';
    var client = BasicAuthClient(clientId, secret);
    var response = await client.post(Uri.parse(
        '${mode.domain}/v1/oauth2/token?grant_type=client_credentials'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["access_token"];
    } else {
      throw Exception("HTTP error ${response.statusCode}: ${response.body}");
    }
  }

  Future<String> createPayPalAccessToken(PayPalServiceMode mode) {
    // depending on mode, create a PayPal AccessToken using your clientId and secretId
    // You might want to do a HTTP request to your backend, which in turn
    // creates an Access Token using the appropriate PayPal API. A simple example
    // using HTTP Basic Auth:
    // curl -v 'https://YOUR_CLIENT_ID:YOUR_CLIENT_SECRET@api.sandbox.paypal.com/v1/oauth2/token?grant_type=client_credentials
    return Future.delayed(
        Duration(seconds: 2), () => "YOUR_PAYPAL_BEARER_ACCESS_TOKEN");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    PayPalService service = PayPalService(
      accessToken: createPayPalAccessToken,
    );
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Click the Button to start a PayPal payment flow!'),
            PayPalButton(
                onFinish: onPayPalFinish,
                orderParams: PayPalOrderParams.create(
                    "1",
                    "iPhone X Special Offer",
                    "EUR",
                    0,
                    "For questions about yur purchase, contact us at mail@shop.example.org",
                    [
                      PayPalItem(
                        name: "iPhone X",
                        quantity: 1,
                        price: 399.99,
                        currency: "EUR",
                      ),
                    ],
                    "https://example.org/purchase_done",
                    "https://example.com/purchase_cancel"),
                service: service),
            Text(
                'This Example will not run as-is, because you must provide your own HTTP Bearer Token from the createPayPalAccessToken callback.')
          ],
        ),
      ),
    );
  }
}
