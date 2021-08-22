library paypal_button;

import 'dart:core';

import 'package:flutter/material.dart';
import 'package:paypal_button/paypal_order_params.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'paypal_service.dart';

class PayPalPayment extends StatefulWidget {
  /// The Order to execute
  final PayPalOrderParams orderParams;

  /// The PayPalService to use
  final PayPalService service;

  /// A Function which will be called with the PayPal Order ID after the order
  /// has been processed. Return `true` to close the window and false to do
  /// nothing (i.e. show the return page provided via orderParams)
  final Function(BuildContext, String)? onFinish;

  /// Error Handler, called with Error Description and context.
  final NavigationDecision Function(BuildContext, String)? onError;

  /// Cancel Handler, called with the widget's context. This allows the
  /// implementation to intercept return and cancel events. If this is unset,
  /// the Cancel Page (as provided in orderParams) will be navigated to and left
  /// open. To not display the Cancel Page, return NavigationDecision.prevent
  /// from this callback
  final NavigationDecision Function(BuildContext)? onCancel;

  PayPalPayment({
    required this.onFinish,
    required this.onError,
    required this.onCancel,
    required this.orderParams,
    required this.service,
  });

  @override
  State<StatefulWidget> createState() {
    return PayPalPaymentState();
  }
}

class PayPalPaymentState extends State<PayPalPayment> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder<PaymentRequest>(
          future: widget.service.createPayment(widget.orderParams),
          builder: (context, state) {
            if (state.hasData) {
              return WebView(
                  initialUrl: state.data!.approvalUrl,
                  javascriptMode: JavascriptMode.unrestricted,
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.contains(
                        widget.orderParams.redirectUrls.returnUrl)) {
                      final uri = Uri.parse(request.url);
                      final payerID = uri.queryParameters['PayerID'];
                      if (payerID != null) {
                        state.data!
                            .execute(payerID)
                            .then((id) {
                          widget.onFinish?.call(context, id);
                        });
                      } else {
                        return widget.onError?.call(context, "payerID is null") ?? NavigationDecision.navigate;
                      }
                    } else if (request.url.contains(widget.orderParams.redirectUrls.cancelUrl)) {
                      if (widget.onCancel != null) {
                        return widget.onCancel!(context);
                      }
                      Navigator.pop(context);
                    }
                    return NavigationDecision.navigate;
                  }
              );
            } else if (state.hasError) {
              widget.onError?.call(context, state.error!.toString());
              return Center(child: Text(state.error!.toString()));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
    );
  }
}
