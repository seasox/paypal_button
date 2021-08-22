

///
/// The classes in this file describe order parameters for a PayPal Transaction.
/// You can create a simple transaction using the PayPalOrderParams.create method.
/// This method should suffice for purchases containing exactly one item.
/// You can also create your own PayPalOrderParams item. See PayPal API documentation
/// for further information about the PayPalOrderParams object
///
/// The resulting JSON for a PayPalTransaction looks something like this:
/// {
///     "intent": "sale",
///     "payer": {"payment_method": "paypal"},
///     "transactions": [
///       {
///        "amount": {
///          "total": "1.99",
///          "currency": "EUR",
///          "details": {
///            "subtotal": "1.49",
///            "shipping": "0.50",
///            "shipping_discount": "0",
///          }
///        },
///        "description": "The payment transaction description.",
///        "payment_options": {
///          "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
///        },
///        "item_list": {
///          "items": [
///            {
///              "name": "iPhone X",
///              "quantity": "1",
///              "price": "1.99",
///              "currency": defaultCurrency["currency"]
///            }
///          ],
///          "shipping_address": {
///            "recipient_name": "John Doe",
///            "line1": "21 Jump Street",
///            "line2": "Second Floor",
///            "city": "London",
///            "country_code": "UK",
///            "postal_code": "23113",
///            "phone": "+447911123456",
///            "state": "England"
///          }
///        }
///      }
///     ],
///     "note_to_payer": "Contact us for any questions on your order.",
///     "redirect_urls": {
///       "return_url": "https://example.com/payment_done",
///       "cancel_url": "https://example.com/payment_canceled"
///     }
/// }
///

class PayPalPaymentOptions {
  PayPalPaymentOptions({
    required this.allowedPaymentMethod,
  });

  final String allowedPaymentMethod;

  Map<String, dynamic> toJson() =>
      {
        "allowed_payment_method": allowedPaymentMethod,
      };
}

class PayPalTransactionAmountDetails {
  PayPalTransactionAmountDetails({
    required this.subtotal,
    required this.shipping,
    required this.shippingDiscount,
  });

  final String subtotal;
  final String shipping;
  final String shippingDiscount;

  Map<String, dynamic> toJson() =>
      {
        "subtotal": subtotal,
        "shipping": shipping,
        "shipping_discount": shippingDiscount,
      };
}

class PayPalTransactionAmount {
  PayPalTransactionAmount({
    required this.total,
    required this.currency,
    required this.details,
  });

  final String total;
  final String currency;
  final PayPalTransactionAmountDetails details;

  Map<String, dynamic> toJson() =>
      {
        "total": total,
        "currency": currency,
        "details": details,
      };
}

class PayPalPayer {
  PayPalPayer({
    required this.paymentMethod,
  });

  final String paymentMethod; // usually "paypal"

  Map<String, dynamic> toJson() =>
      {
        "payment_method": paymentMethod,
      };
}

class PayPalShippingAddress {
  PayPalShippingAddress({
    required this.recipientName,
    required this.line1,
    required this.line2,
    required this.city,
    required this.countryCode,
    required this.postalCode,
    required this.phone,
    required this.state,
  });

  final String recipientName;
  final String line1;
  final String line2;
  final String city;
  final String countryCode;
  final String postalCode;
  final String phone;
  final String state;

  Map<String, dynamic> toJson() =>
      {
        "recipient_name": recipientName,
        "line1": line1,
        "line2": line2,
        "city": city,
        "country_code": countryCode,
        "postal_code": postalCode,
        "phone": phone,
        "state": state,
      };
}

class PayPalItemList {
  PayPalItemList({
    required this.items,
    this.shippingAddress,
  });

  final List<PayPalItem> items;
  final PayPalShippingAddress? shippingAddress;

  Map<String, dynamic> toJson() =>
      {
        "items": items,
        if (shippingAddress != null) "shipping_address": shippingAddress,
      };
}

class PayPalTransaction {
  PayPalTransaction({
    required this.amount,
    required this.description,
    required this.paymentOptions,
    required this.itemList,
  });
  final PayPalTransactionAmount amount;
  final String description;
  final PayPalPaymentOptions paymentOptions;
  final PayPalItemList itemList;

  Map<String, dynamic> toJson() =>
      {
        "amount": amount,
        "description": description,
        "payment_options": paymentOptions,
        "item_list": itemList,
      };
}

class PayPalRedirectUrls {
  PayPalRedirectUrls({
    required this.returnUrl,
    required this.cancelUrl,
  });

  final String returnUrl;
  final String cancelUrl;

  Map<String, dynamic> toJson() =>
      {
        "return_url": returnUrl,
        "cancel_url": cancelUrl,
      };
}

class PayPalOrderParams {
  PayPalOrderParams({
    required this.intent,
    required this.payer,
    required this.transactions,
    required this.noteToPayer,
    required this.redirectUrls,
  });

  final String intent;
  final PayPalPayer payer;
  final List<PayPalTransaction> transactions;
  final String noteToPayer;
  final PayPalRedirectUrls redirectUrls;

  Map<String, dynamic> toJson() =>
      {
        "intent": intent,
        "payer": payer,
        "transactions": transactions,
        "note_to_payer": noteToPayer,
        "redirect_urls": redirectUrls,
      };

  static PayPalOrderParams create(
      String amount,
      String description,
      String currency,
      double shipping,
      String noteToPayer,
      List<PayPalItem> items,
      String returnUrl,
      String cancelUrl,
      ) {
    final itemsTotal = items.map((i) => i.price).reduce((a, b) => a+b);
    return PayPalOrderParams(
      intent: "sale",
      payer: PayPalPayer(
        paymentMethod: "paypal",
      ),
      transactions: [
        PayPalTransaction(
          amount: PayPalTransactionAmount(
            currency: currency,
            total: (itemsTotal + shipping).toString(),
            details: PayPalTransactionAmountDetails(
              subtotal: itemsTotal.toString(),
              shippingDiscount: '0',
              shipping: shipping.toString(),
            ),
          ),
          description: description,
          paymentOptions: PayPalPaymentOptions(
            allowedPaymentMethod: 'INSTANT_FUNDING_SOURCE',
          ),
          itemList: PayPalItemList(
            items: items,
          ),
        )
      ],
      noteToPayer: noteToPayer,
      redirectUrls: PayPalRedirectUrls(
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
      ),
    );
  }
}

class PayPalItem {
  String name;
  int quantity;
  double price;
  String currency;

  PayPalItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "quantity": quantity,
      "price": price.toString(),
      "currency": currency,
    };
  }
}
