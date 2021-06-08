import 'package:akbmobile/models/menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuCartCardComponent extends StatelessWidget {
  final Menu menu;

  const MenuCartCardComponent({
    Key key,
    @required this.menu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                                  color: Colors.red.shade600,
                                ),
                              ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
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
                        height: 90,
                        width: 90,
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
