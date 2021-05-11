import 'package:akbmobile/blocs/menu/menu_bloc.dart';
import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/screens/search/components/menu_card_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

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
    {"name": "Side Dish", "value": "drink"},
    {"name": "Minuman", "value": "side_dish"}
  ];

  String _selectedCategory = "";

  MenuBloc _bloc;
  List<Menu> _data = [];
  int _page;
  int _totalPage;

  @override
  void initState() {
    _bloc = MenuBloc();
    _bloc.add(GetMenuEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, isScrolled) {
          return [
            SliverAppBar(
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              pinned: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Cari menu',
                  onPressed: () {
                    // handle the press
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
                          selected: _categories[index]['value'] ==
                              _selectedCategory,
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
                              _bloc.add(GetMoreMenuEvent(page: 1, reset: true, category: _selectedCategory));
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
          ];
        },
        body: BlocBuilder<MenuBloc, MenuState>(
          bloc: _bloc,
          builder: (context, state) {
            if (state is MenuLoadedState || state is MenuLoadMoreLoadingState) {
              if (state is MenuLoadedState) {
                _data = state.data;
                _page = state.page;
                _totalPage = state.totalPage;
              }
              return LazyLoadScrollView(
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    children: [
                      ListView.builder(
                        key: ObjectKey(_data.hashCode),
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          return Container(
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
                      ),
                      (_page < _totalPage && state is MenuLoadedState ||
                          state is MenuLoadMoreLoadingState)
                          ? Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Center(child: CircularProgressIndicator()),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
                onEndOfPage: () {
                  if (_selectedCategory.isNotEmpty) {
                    _bloc.add(GetMoreMenuEvent(page: _page + 1, reset: false, category: _selectedCategory));
                  } else {
                    _bloc.add(GetMoreMenuEvent(page: _page + 1, reset: false));
                  }
                },
              );
            } else if (state is MenuLoadingState) {
              _scrollController.animateTo(0, duration: new Duration(milliseconds: 1), curve: Curves.ease);
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: Text(state.toString()),
              );
            }
          },
        ),
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
                    child: menu.imagePath != null ? Image.network(
                      menu.imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ) : null,
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
                  child: menu.isAvailable == 1 ? Text(
                    menu.price > 0 ? NumberFormat.simpleCurrency(
                        locale: 'id_ID', decimalDigits: 0)
                        .format(menu.price) : "Gratis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ): Text(
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
                            child: Text(
                                "Tambah pesanan",
                                style: TextStyle(fontSize: 16, color: Colors.white)
                            ),
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) => states.contains(MaterialState.disabled) ? Colors.redAccent.withOpacity(0.7) : Colors.red,
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                    )
                                )
                            ),
                            onPressed: (menu.isAvailable == 1) ? () {} : null,
                        ),
                      ),
                    ],
                  )
                ),
              ],
            ),
          );
        }
    );
  }

}
