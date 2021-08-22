import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart';

import 'paypal_order_params.dart';

typedef PayPalAccessTokenProvider = Future<String> Function(PayPalServiceMode);

enum PayPalServiceMode {
  sandbox,
  live,
}

extension ModeExtension on PayPalServiceMode {
  String get domain {
    switch (this) {
      case PayPalServiceMode.sandbox:
        return "https://api.sandbox.paypal.com";
      case PayPalServiceMode.live:
        return "https://api.paypal.com";
    }
  }
}

class PaymentRequest {

  final String _executeUrl;
  final String approvalUrl;
  String _accessToken;
  Client _client;

  PaymentRequest._(
    this._executeUrl,
    this.approvalUrl,
    this._accessToken,
    this._client,
  );

  static PaymentRequest fromJson(Map<String, dynamic> body, String accessToken, Client client) {
    String? executeUrl;
    String? approvalUrl;
    if (body["links"] != null && body["links"].length > 0) {
      List links = body["links"];

      final item = links.firstWhere((o) => o["rel"] == "approval_url",
          orElse: () => null);
      if (item != null) {
        approvalUrl = item["href"];
      }
      final item1 = links.firstWhere((o) => o["rel"] == "execute",
          orElse: () => null);
      if (item1 != null) {
        executeUrl = item1["href"];
      }
    }
    if (executeUrl == null || approvalUrl == null) {
      throw Exception("executeUrl or approvalUrl is null: ${body.toString()}");
    }
    return PaymentRequest._(executeUrl, approvalUrl, accessToken, client);
  }

  Future<String> execute(String payerID) =>
      _client.post(Uri.parse(_executeUrl),
          body: convert.jsonEncode({"payer_id": payerID}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + _accessToken
          })
          .then((response) => convert.jsonDecode(response.body))
          .then((body) => body['id']);
}

class PayPalServiceException {

  final Map<String, dynamic> body;

  PayPalServiceException({
    required this.body,
  });

  String toString() {
    if (body['message'] != null) {
      return "${body['message']}: ${body['details']?.toString() ??
          "no details"}";
    } else if (body['error'] != null) {
      return "${body['error']}: ${body['error_description']?.toString() ??
          "no error description"}";
    } else {
      return "${body.toString()}";
    }
  }
}

class PayPalService {

  PayPalService({
    /**
     * A Function which returns a Future<String?> which generates an access token
     */
    required this.accessToken,
    /**
     * The mode to use
     */
    this.mode = PayPalServiceMode.live,
    /**
     * an optional HTTP client
     */
    Client? client,
  }) : this.client = client ?? Client();


  final PayPalAccessTokenProvider accessToken;
  final PayPalServiceMode mode;
  final Client client;

  // create a payment request
  Future<PaymentRequest> createPayment(PayPalOrderParams orderParams) =>
      accessToken
          .call(mode)
          .then((accessToken) => client.post(
            Uri.parse("${mode.domain}/v1/payments/payment"),
            body: jsonEncode(orderParams),
            headers: {
              "content-type": "application/json",
              'Authorization': 'Bearer ' + accessToken,
            },
          ).then((response) {
            final body = convert.jsonDecode(response.body);
            if (response.statusCode == 201) {
              var req = PaymentRequest.fromJson(body, accessToken, client);
              req._accessToken = accessToken;
              req._client = client;
              return req;
            } else {
              throw PayPalServiceException(body: body);
            }
          })
      );
}
