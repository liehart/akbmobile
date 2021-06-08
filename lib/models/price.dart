class Price {
  final int price;
  final int tax;
  final int service;
  final int total;

  Price({this.price, this.service, this.tax, this.total});

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        price: json['price'],
        service: json['service'],
        tax: json['tax'],
        total: json['total'],
      );
}
