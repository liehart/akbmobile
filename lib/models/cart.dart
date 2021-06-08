import 'package:akbmobile/models/menu.dart';

class Cart {
  final int orderId;
  final int menuId;
  final int quantity;
  final Menu menu;

  Cart({this.orderId, this.menuId, this.quantity, this.menu});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        orderId: json['order_id'],
        menuId: json['menu_id'],
        quantity: json['quantity'],
        menu: Menu.fromJson(json['menu']),
      );
}
