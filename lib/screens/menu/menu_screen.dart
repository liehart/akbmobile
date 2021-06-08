import 'dart:convert';

import 'package:akbmobile/api/api_helper.dart';
import 'package:akbmobile/blocs/menu/menu_bloc.dart';
import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/screens/reservation/reservation.dart';
import 'package:akbmobile/screens/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'components/menu_card_component.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    Key key,
  }) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _categories = [
    {"name": "Semua", "value": ""},
    {"name": "Makanan", "value": "main"},
    {"name": "Side Dish", "value": "side_dish"},
    {"name": "Minuman", "value": "drink"}
  ];

  String _selectedCategory = "";

  MenuBloc _bloc;
  List<Menu> _data = [];
  int _page;
  int _totalPage;
  String _token;

  @override
  void initState() {
    _bloc = MenuBloc();
    _bloc.add(GetMenuEvent());
    _scrollController.addListener(_onScroll);
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    setState(() {
      _token = (prefs.getString('token') ?? null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.shopping_basket),
                tooltip: 'Keranjang',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                tooltip: 'Cari menu',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchScreen()));
                },
              ),
            ],
            centerTitle: false,
            title: Text(
              "Mau makan apa?",
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: IconThemeData(color: Colors.black87),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(55),
              child: Container(
                color: Colors.white,
                height: 55,
                width: double.infinity,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: ClampingScrollPhysics(),
                  children: List.generate(_categories.length, (index) {
                    return Padding(
                      padding: (index == 0)
                          ? EdgeInsets.only(left: 15, right: 12)
                          : EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: (_categories[index]['value'] ==
                                    _selectedCategory)
                                ? Colors.red
                                : Colors.black12.withOpacity(0.07),
                          ),
                        ),
                        backgroundColor: Colors.black12.withOpacity(0.01),
                        selected:
                            _categories[index]['value'] == _selectedCategory,
                        selectedColor: Colors.redAccent.withOpacity(0.3),
                        pressElevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        label: Text(
                          _categories[index]['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: (_categories[index]['value'] ==
                                      _selectedCategory)
                                  ? Colors.red
                                  : Colors.black.withOpacity(0.7)),
                        ),
                        onSelected: (bool value) {
                          setState(() {
                            _selectedCategory = _categories[index]['value'];
                          });
                          if (_selectedCategory.isNotEmpty) {
                            _bloc.add(GetMoreMenuEvent(
                                page: 1,
                                reset: true,
                                category: _selectedCategory));
                          } else {
                            _bloc.add(GetMoreMenuEvent(page: 1, reset: true));
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          BlocBuilder<MenuBloc, MenuState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is MenuLoadedState ||
                  state is MenuLoadMoreLoadingState) {
                if (state is MenuLoadedState) {
                  _data = state.data;
                  _page = state.page;
                  _totalPage = state.totalPage;
                }
                return SliverPadding(
                  padding: EdgeInsets.only(bottom: 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return index >= _data.length
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor:
                                        Colors.redAccent.withOpacity(0.5),
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.red),
                                  ),
                                ),
                              )
                            : Container(
                                child: InkWell(
                                  onTap: () {
                                    _showErrorOnScanQRCode(_data[index]);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: MenuCardComponent(
                                      menu: _data[index],
                                    ),
                                  ),
                                ),
                              );
                      },
                      childCount: (_page < _totalPage)
                          ? _data.length + 1
                          : _data.length,
                    ),
                  ),
                );
              }
              if (state is MenuLoadingState) {
                _scrollController.animateTo(0,
                    duration: new Duration(milliseconds: 1),
                    curve: Curves.ease);
                return SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.redAccent.withOpacity(0.5),
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                  ),
                );
              }
              if (state is MenuLoadedEmptyState) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          child: Image.asset(
                            'assets/images/empty_error.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 20),
                            child: Text(
                              "Sepertinya tidak ada menu dengan kategori ini",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              }
              return SliverFillRemaining(
                hasScrollBody: false,
                fillOverscroll: true,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      _bloc.add(GetMenuEvent());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.1),
                          child: Image.asset(
                            'assets/images/fatal_error.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Text(
                            (state is MenuErrorState)
                                ? (state).message
                                : "Telah terjadi error",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            "Ketuk untuk mengulang",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showErrorOnScanQRCode(Menu menu) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
                    margin: EdgeInsets.only(bottom: 25, top: 10),
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
                            onPressed: (menu.isAvailable == 1 && _token != null)
                                ? () {
                                    _addMenu(menu.id).then((re) {
                                      if (re) {
                                        print(re);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Menu ${menu.name} berhasil ditambahkan'),
                                        ));
                                      } else {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Menu ${menu.name} tidak dapat ditambahkan'),
                                        ));
                                        _bloc.add(GetMenuEvent());
                                      }
                                    });
                                  }
                                : null,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
  }

  Future<bool> _addMenu(int menuId) async {
    final response = await http.post(
      Uri.parse(ApiHelper().getBaseUrl() + 'order/' + _token + '/cart'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(
        <String, dynamic>{'menu_id': menuId},
      ),
    );
    print(response.body.toString());
    if (response.statusCode == 200) {
      if (json.decode(response.body.toString())['message'] == 'CART_CREATED') {
        print(json.decode(response.body.toString()));
        return true;
      } else if (json.decode(response.body.toString())['message'] ==
          'CART_UPDATED') {
        print(json.decode(response.body.toString()));
        return true;
      }
    }
    return false;
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      if (_selectedCategory.isNotEmpty) {
        _bloc.add(GetMoreMenuEvent(
            page: _page + 1, reset: false, category: _selectedCategory));
      } else {
        _bloc.add(GetMoreMenuEvent(page: _page + 1, reset: false));
      }
    }
  }
}
