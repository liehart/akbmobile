import 'package:akbmobile/models/menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuCardComponent extends StatelessWidget {
  final Menu menu;

  const MenuCardComponent({
    Key key,
    @required this.menu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      menu.description,
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    menu.isAvailable == 1
                        ? Text(
                            menu.price > 0
                                ? NumberFormat.simpleCurrency(
                                        locale: 'id_ID', decimalDigits: 0)
                                    .format(menu.price)
                                : "Gratis",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Text(
                            "Tidak tersedia",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade600),
                          ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 15,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: menu.imagePath != null
                ? Image.network(
                    menu.imagePath,
                    fit: BoxFit.cover,
                    height: 80,
                    width: 80,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
