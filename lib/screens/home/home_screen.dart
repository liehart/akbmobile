import 'dart:math' as math;
import 'dart:ui';

import 'package:akbmobile/screens/scanqr/scanqr_screen.dart';
import 'package:akbmobile/screens/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

const double minHeight = 400;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  double get maxHeight => MediaQuery.of(context).size.height;

  PanelController _panelController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 60),
    );
    _panelController = PanelController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> popularMenus = [
      {
        "imagePath": "assets/images/makanan_image.png",
        "menuName": "Beef Short Plate",
        "price": 20000,
        "description":
            "Potongan daging sapi dari bagian otot perut, bentuknya panjang dan datar"
      },
      {
        "imagePath": "assets/images/makanan_image.png",
        "menuName": "Beef Short Plate",
        "price": 20000,
        "description":
            "Potongan daging sapi dari bagian otot perut, bentuknya panjang dan datar"
      },
      {
        "imagePath": "assets/images/makanan_image.png",
        "menuName": "Beef Short Plate",
        "price": 20000,
        "description":
            "Potongan daging sapi dari bagian otot perut, bentuknya panjang dan datar"
      },
      {
        "imagePath": "assets/images/makanan_image.png",
        "menuName": "Beef Short Plate",
        "price": 20000,
        "description":
            "Potongan daging sapi dari bagian otot perut, bentuknya panjang dan datar"
      },
      {
        "imagePath": "assets/images/makanan_image.png",
        "menuName": "Beef Short Plate",
        "price": 20000,
        "description":
            "Potongan daging sapi dari bagian otot perut, bentuknya panjang dan datar"
      },
      {
        "imagePath": "assets/images/makanan_image.png",
        "menuName": "Beef Short Plate",
        "price": 20000,
        "description":
            "Potongan daging sapi dari bagian otot perut, bentuknya panjang dan datar"
      }
    ];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Container(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.22),
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(color: Colors.purpleAccent),
          child: Image.asset(
            'assets/images/bg.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: SlidingUpPanel(
            controller: _panelController,
            boxShadow: [],
            color: Colors.transparent,
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: 310,
            panelBuilder: (scrollController) {
              return Container(
                child: Container(
                  padding: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white
                        ],
                        stops: [0.0, 0.02, 0.98, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstOut,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          MainHeader(),
                          SizedBox(
                            height: 20,
                          ),
                          MainSearch(),
                          SizedBox(
                            height: 20,
                          ),
                          DefaultSeparator(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: "Kategori",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          'assets/images/makanan_image.png',
                                          fit: BoxFit.cover,
                                          height: 120,
                                          width: 200,
                                        ),
                                        Container(
                                          child: Material(
                                            child: InkWell(
                                              splashColor: Colors.white12,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: () {},
                                              child: Container(
                                                alignment: Alignment.bottomLeft,
                                                height: 120,
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  'Makanan',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            color: Colors.transparent,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Color(0xFF343434)
                                                    .withOpacity(0.7),
                                                Color(0x00000000)
                                                    .withOpacity(0.15),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          children: [
                                            Image.asset(
                                              'assets/images/side_dish_image.png',
                                              fit: BoxFit.cover,
                                              height: 55,
                                              width: 200,
                                            ),
                                            Container(
                                              child: Material(
                                                child: InkWell(
                                                  splashColor: Colors.white12,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text('Tap'),
                                                    ));
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    height: 55,
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    child: Text(
                                                      'Side Dish',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                color: Colors.transparent,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Color(0xFF343434)
                                                        .withOpacity(0.7),
                                                    Color(0x00000000)
                                                        .withOpacity(0.15),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          children: [
                                            Image.asset(
                                              'assets/images/minuman_image.png',
                                              fit: BoxFit.cover,
                                              height: 55,
                                              width: 200,
                                            ),
                                            Container(
                                              child: Material(
                                                child: InkWell(
                                                  splashColor: Colors.white12,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: () {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text('Tap'),
                                                    ));
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    height: 55,
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    child: Text(
                                                      'Minuman',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                color: Colors.transparent,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Color(0xFF343434)
                                                        .withOpacity(0.7),
                                                    Color(0x00000000)
                                                        .withOpacity(0.15),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          DefaultSeparator(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: "Reservasi",
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: 150,
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Container(
                                    color: Colors.purpleAccent,
                                  ),
                                  Image.asset(
                                    'assets/images/reservation.png',
                                    fit: BoxFit.contain,
                                    height: 150,
                                    width: 150,
                                  ),
                                  Container(
                                    child: Material(
                                      child: InkWell(
                                        splashColor: Colors.white12,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: (context) => ScanQRScreen()
                                          ));
                                        },
                                        child: Container(
                                          alignment: Alignment.bottomRight,
                                          height: 150,
                                          padding: EdgeInsets.all(12.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                child: Text(
                                                  "Reservation Inactive",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.purpleAccent,
                                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Buat Pesanan',
                                                    style: TextStyle(
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Ketuk untuk scan QR code reservasi',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ),
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        colors: [
                                          Color(0xFF343434)
                                              .withOpacity(0.6),
                                          Colors.transparent
                                        ],
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // ReservationBottomSheet(),
      ]),
    );
  }

  void _showPanel() {
    _panelController.show();
  }

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    _controller.fling(velocity: isOpen ? -2 : 2);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta / maxHeight;
    print('Naikkk');
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0) {
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    } else if (flingVelocity > 0.0) {
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    } else {
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
    }
  }
}

class MainSearch extends StatefulWidget {
  @override
  _MainSearch createState() => _MainSearch();
}

class _MainSearch extends State<MainSearch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xD5EEEEEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              "Cari makanan enak",
            ),
          ],
        ),
      ),
    );
  }
}

class MainHeader extends StatelessWidget {
  const MainHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Mau makan apa hari ini?",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 42,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class PopularMenuCard extends StatelessWidget {
  final String imagePath;
  final String menuName;
  final String description;
  final int price;

  const PopularMenuCard({
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
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              height: 90,
              width: 90,
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

class DefaultSeparator extends StatelessWidget {
  final String title;
  final String subTitle;
  final EdgeInsets margin;

  const DefaultSeparator(
      {Key key, @required this.title, this.subTitle, this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subTitle != null)
              TextSpan(
                text: "\n$subTitle",
                style: TextStyle(color: Colors.black45),
              )
          ],
        ),
      ),
    );
  }
}
