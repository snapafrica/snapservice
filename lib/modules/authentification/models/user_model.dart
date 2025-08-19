import 'dart:convert';

class ServiceUser {
  final int id;
  final String pin;
  final String email;
  final String? type;
  final String? name;
  final String? phone;
  final String? shop;
  final String? storeName;
  final String? industry;
  final String? merchant;
  final String? paybill;
  final String? storeId;
  final String? payUrl;
  final String? subscriptionStatus;

  ServiceUser({
    required this.id,
    required this.pin,
    required this.email,
    this.type,
    this.name,
    this.phone,
    this.storeName,
    this.shop,
    this.industry,
    this.merchant,
    this.paybill,
    this.storeId,
    this.payUrl,
    this.subscriptionStatus,
  });

  factory ServiceUser.fromString(String data) {
    return ServiceUser.fromMap(jsonDecode(data) as Map<String, dynamic>);
  }

  factory ServiceUser.fromMap(Map<String, dynamic> json, [String? pin]) =>
      ServiceUser(
        id: json['id'],
        pin: (pin ?? json['pin']) as String,
        name: json['name'],
        type: json['type'],
        phone: json['phone'],
        storeName: json['storeName'],
        email: json['email'],
        shop: json['shop'],
        industry: json['industry'],
        merchant: json['merchant'],
        paybill: json['paybill'],
        storeId: json['storeId'],
        payUrl: json['pay_url'],
        subscriptionStatus: json['subscription_status'],
      );

  @override
  String toString() => jsonEncode({
    'id': id,
    'storeName': storeName,
    'name': name,
    'email': email,
    'pin': pin,
    'phone': phone,
    'shop': shop,
    'type': type,
    'industry': industry,
    'merchant': merchant,
    'paybill': paybill,
    'storeId': storeId,
    'pay_url': payUrl,
    'subscription_status': subscriptionStatus,
  });
}