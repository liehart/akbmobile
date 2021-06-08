import 'package:akbmobile/models/price.dart';

import 'menu.dart';

class Order {
  final int totalMenu;
  final int totalItem;
  final DateTime orderDate;
  final DateTime finishAt;
  final List<OrderDetail> orderDetail;
  final Waiter waiter;
  final Customer customer;
  final Reservation reservation;
  final Price price;

  Order(
      {this.totalMenu,
      this.totalItem,
      this.orderDate,
      this.finishAt,
      this.orderDetail,
      this.waiter,
      this.customer,
      this.reservation,
      this.price});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      totalMenu: json['total_menu'],
      totalItem: json['total_item'],
      orderDate: DateTime.parse(json['order_date']),
      finishAt:
          json['finish_at'] == null ? null : DateTime.parse(json['finish_at']),
      customer: Customer.fromJson(json['reservation']['customer']),
      orderDetail: List<OrderDetail>.from(
          json['details'].map((x) => OrderDetail.fromJson(x))),
      waiter: Waiter.fromJson(json['waiter']),
      reservation: Reservation.fromJson(json['reservation']),
      price: Price.fromJson(json['price']),
    );
  }
}

class Waiter {
  final String name;

  Waiter({this.name});

  factory Waiter.fromJson(Map<String, dynamic> json) {
    return Waiter(name: json['name']);
  }
}

class Reservation {
  final String session;
  final int tableNumber;

  Reservation({this.session, this.tableNumber});

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      session: json['session'],
      tableNumber: json['table_number'],
    );
  }
}

class Customer {
  final String name;
  final String email;
  final String phone;

  Customer({this.name, this.email, this.phone});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class OrderDetail {
  final int quantity;
  final DateTime readyToServeAt;
  final DateTime servedAt;
  final DateTime createdAt;
  final Menu menu;

  OrderDetail(
      {this.quantity,
      this.readyToServeAt,
      this.servedAt,
      this.createdAt,
      this.menu});

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      quantity: json['quantity'],
      readyToServeAt: json['ready_to_serve_at'] == null
          ? null
          : DateTime.parse(json['ready_to_serve_at']),
      servedAt:
          json['served_at'] == null ? null : DateTime.parse(json['served_at']),
      createdAt: DateTime.parse(json['created_at']),
      menu: Menu.fromJson(json['menu']),
    );
  }
}
