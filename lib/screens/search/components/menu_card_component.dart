import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuCardComponent extends StatelessWidget {
  final String imagePath;
  final String menuName;
  final String description;
  final int price;

  const MenuCardComponent({
    Key key,
    @required this.imagePath,
    @required this.menuName,
    @required this.description,
    @required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath != null ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ) : Image.asset(
              'assets/images/no_image.png',
              fit: BoxFit.cover,
              height: 100,
              width: 100,
            ),
          ),
          SizedBox(
            width: 15,
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          menuName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          NumberFormat.simpleCurrency(
                              locale: 'id_ID', decimalDigits: 0)
                              .format(price),
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      description,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}