import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'paypal_order_params.dart';
import 'paypal_payment.dart';
import 'paypal_service.dart';

class PayPalButton extends StatelessWidget {
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

  PayPalButton({
    this.onFinish,
    this.onError,
    this.onCancel,
    required this.orderParams,
    required this.service,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PayPalPayment(
              onFinish: onFinish,
              onError: onError,
              onCancel: onCancel,
              orderParams: orderParams,
              service: service,
            ),
          ),
        ),
        child: Text(
          'Pay with PayPal',
          textAlign: TextAlign.center,
        ),
      );
}
