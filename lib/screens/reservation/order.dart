import 'dart:async';
import 'dart:convert';

import 'package:akbmobile/api/api_helper.dart';
import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/models/order_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderScreen extends StatefulWidget {
  OrderScreen({Key key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  StreamController<Order> _streamController;
  final f = new DateFormat('hh:mm');

  String _token;

  @override
  void initState() {
    _streamController = StreamController<Order>();
    _loadToken();
    super.initState();
  }

  void _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    setState(() {
      _token = (prefs.getString('token') ?? null);
    });
    fetch();
  }

  void _restartApp() async {
    print('memesan');
    final response = await http.post(
      Uri.parse(ApiHelper().getBaseUrl() + 'order/' + _token + '/finish'),
    );
    print(response.body.toString());
    if (response.statusCode == 200) {
      print('restarting');
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      Navigator.pop(context);
    } else {
      if (json.decode(response.body.toString())['message'] ==
          "ORDER_HASNT_BEEN_FINISHED") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Masih ada menu yang belum di sajikan.'),
        ));
      }
    }
  }

  void fetch() async {
    final response =
        await http.get(Uri.parse(ApiHelper().getBaseUrl() + 'order/' + _token));

    if (response.statusCode == 200) {
      print('adas');
      print(response.body.toString());
      _streamController
          .add(Order.fromJson(json.decode(response.body.toString())['data']));
    } else {
      throw Exception('Failed to load menu');
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
          "PesananKu",
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
              child: StreamBuilder<Order>(
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
                                              snapshot.data.customer.name,
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
                              'Status Pesanan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        snapshot.data.orderDetail.length > 0
                            ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data.orderDetail.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: Colors.white,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Container(
                                        child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          snapshot
                                                              .data
                                                              .orderDetail[
                                                                  index]
                                                              .menu
                                                              .name,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          '${snapshot.data.orderDetail[index].quantity} ${snapshot.data.orderDetail[index].menu.unit}',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                            'Dipesan pada ${f.format(snapshot.data.orderDetail[index].createdAt)}'),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        snapshot
                                                                    .data
                                                                    .orderDetail[
                                                                        index]
                                                                    .readyToServeAt ==
                                                                null
                                                            ? Text(
                                                                'Sedang di siapkan')
                                                            : snapshot
                                                                        .data
                                                                        .orderDetail[
                                                                            index]
                                                                        .servedAt ==
                                                                    null
                                                                ? Text(
                                                                    'Siap di hidangkan')
                                                                : Text(
                                                                    'Telah di hidangkan')
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: snapshot
                                                            .data
                                                            .orderDetail[index]
                                                            .menu
                                                            .imagePath !=
                                                        null
                                                    ? Image.network(
                                                        snapshot
                                                            .data
                                                            .orderDetail[index]
                                                            .menu
                                                            .imagePath,
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
                                    )),
                                  );
                                },
                              )
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 100),
                                child: Text('Belum ada pesanan'),
                              ),
                        snapshot.data.orderDetail.length > 0
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
                        snapshot.data.orderDetail.length > 0
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
                                          child: Text("Selesai",
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
                                          onPressed:
                                              snapshot.data.orderDetail.length >
                                                      0
                                                  ? () {
                                                      _restartApp();
                                                    }
                                                  : null,
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
