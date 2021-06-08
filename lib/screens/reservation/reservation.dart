import 'dart:async';
import 'dart:convert';

import 'package:akbmobile/api/api_helper.dart';
import 'package:akbmobile/models/cart.dart';
import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/models/price.dart';
import 'package:akbmobile/screens/reservation/components/menu_cart_card_component.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReservationScreen extends StatefulWidget {
  ReservationScreen({Key key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class Reservation {
  final String name;
  final int tableNumber;
  final String session;

  Reservation({this.name, this.tableNumber, this.session});

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
        name: json['name'],
        tableNumber: json['table_number'],
        session: json['session'],
      );
}

class Response {
  final Price price;
  final List<Cart> cart;
  final Reservation reservation;

  Response(this.reservation, this.price, this.cart);
}

class _ReservationScreenState extends State<ReservationScreen> {
  StreamController<Response> _streamController;
  String _token;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<Response>();
    _loadToken();
  }

  void _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    setState(() {
      _token = (prefs.getString('token') ?? null);
    });
    fetch();
  }

  void fetch() async {
    final response = await http
        .get(Uri.parse(ApiHelper().getBaseUrl() + 'order/' + _token + '/cart'));

    if (response.statusCode == 200) {
      print(json.decode(response.body.toString()));
      _streamController.add(Response(
        Reservation.fromJson(
            json.decode(response.body.toString())['data']['reservation']),
        Price.fromJson(json.decode(response.body.toString())['data']['price']),
        List<Cart>.from(
          json.decode(response.body.toString())['data']['carts'].map(
                (x) => Cart.fromJson(x),
              ),
        ),
      ));
    } else {
      throw Exception('Failed to load album');
    }
  }

  void _addMenuQuantity(int menuId, int quantity) async {
    final response = await http.put(
      Uri.parse(ApiHelper().getBaseUrl() + 'order/' + _token + '/cart'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        <String, dynamic>{
          'menu_id': menuId,
          'quantity': quantity,
        },
      ),
    );
    print(response.body.toString());
    if (response.statusCode == 200) {
      if (json.decode(response.body.toString())['message'] == 'CART_UPDATED') {
        print(json.decode(response.body.toString()));
      }
      fetch();
    }
  }

  void _createOrder() async {
    print('memesan');
    final response = await http.post(
      Uri.parse(ApiHelper().getBaseUrl() + 'order/' + _token + '/createOrder'),
    );
    print(response.body.toString());
    if (response.statusCode == 200) {
      fetch();
    }
  }

  void _showErrorOnScanQRCode(Menu menu) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        backgroundColor: Colors.white,
        builder: (builder) {
          return Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 8),
            child: Wrap(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 15),
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.black12,
                    ),
                    height: 5,
                    width: 30,
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: menu.imagePath != null
                        ? Image.network(
                            menu.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : null,
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    menu.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    menu.description,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: menu.isAvailable == 1
                      ? Text(
                          menu.price > 0
                              ? NumberFormat.simpleCurrency(
                                      locale: 'id_ID', decimalDigits: 0)
                                  .format(menu.price)
                              : "Gratis",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : Text(
                          "Tidak tersedia",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                            fontSize: 18,
                          ),
                        ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 10, top: 10),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text("Tambah pesanan",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(15)),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) =>
                                      states.contains(MaterialState.disabled)
                                          ? Colors.redAccent.withOpacity(0.7)
                                          : Colors.red,
                                ),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ))),
                            onPressed: (menu.isAvailable == 1) ? () {} : null,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.red,
        centerTitle: false,
        title: Text(
          "ReservasiKu",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: StreamBuilder(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          width: double.infinity,
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: Text(
                                            'Detail Reservasi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Nama Pelanggan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            child: Text(
                                              snapshot.data.reservation.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.chair,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              'Meja dan Sesi',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2,
                                          ),
                                          Container(
                                            child: Text(
                                              'Meja ${snapshot.data.reservation.tableNumber} (${snapshot.data.reservation.session})',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.white,
                          child: Container(
                            margin: EdgeInsets.all(15),
                            child: Text(
                              'Daftar Pesanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        snapshot.data.cart.length > 0
                            ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data.cart.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _showErrorOnScanQRCode(
                                          snapshot.data.cart[index].menu);
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: MenuCartCardComponent(
                                                menu: snapshot
                                                    .data.cart[index].menu),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  NumberFormat.simpleCurrency(
                                                          locale: 'id_ID',
                                                          decimalDigits: 0)
                                                      .format(snapshot
                                                              .data
                                                              .cart[index]
                                                              .menu
                                                              .price *
                                                          snapshot
                                                              .data
                                                              .cart[index]
                                                              .quantity),
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        print('increase');
                                                        _addMenuQuantity(
                                                            snapshot
                                                                .data
                                                                .cart[index]
                                                                .menuId,
                                                            snapshot
                                                                    .data
                                                                    .cart[index]
                                                                    .quantity +
                                                                1);
                                                      },
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "+",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "${snapshot.data.cart[index].quantity}",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        print('decrease');
                                                        _addMenuQuantity(
                                                            snapshot
                                                                .data
                                                                .cart[index]
                                                                .menuId,
                                                            snapshot
                                                                    .data
                                                                    .cart[index]
                                                                    .quantity -
                                                                1);
                                                      },
                                                      child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    8),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            "-",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 100),
                                child: Text('Belum ada pesanan'),
                              ),
                        snapshot.data.cart.length > 0
                            ? Container(
                                width: double.infinity,
                                margin: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Detail Pembayaran',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Harga',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberFormat.simpleCurrency(
                                                    locale: 'id_ID',
                                                    decimalDigits: 0)
                                                .format(
                                                    snapshot.data.price.price),
                                            textAlign: TextAlign.end,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Restaurant service fee',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberFormat.simpleCurrency(
                                                    locale: 'id_ID',
                                                    decimalDigits: 0)
                                                .format(snapshot
                                                    .data.price.service),
                                            textAlign: TextAlign.end,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Tax',
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberFormat.simpleCurrency(
                                                    locale: 'id_ID',
                                                    decimalDigits: 0)
                                                .format(
                                                    snapshot.data.price.tax),
                                            textAlign: TextAlign.end,
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      height: 40,
                                      thickness: 2,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            NumberFormat.simpleCurrency(
                                                    locale: 'id_ID',
                                                    decimalDigits: 0)
                                                .format(
                                                    snapshot.data.price.total),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        snapshot.data.cart.length > 0
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.black12,
                                    ),
                                  ),
                                ),
                                width: double.infinity,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          child: Text("Pesan",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white)),
                                          style: ButtonStyle(
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                      EdgeInsets.all(15)),
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (Set<MaterialState> states) =>
                                                    states.contains(
                                                            MaterialState
                                                                .disabled)
                                                        ? Colors.redAccent
                                                            .withOpacity(0.7)
                                                        : Colors.red,
                                              ),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                              ))),
                                          onPressed: _createOrder,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner.
                  return Container(
                    width: double.infinity,
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height - 50,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
