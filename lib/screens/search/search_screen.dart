import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/screens/menu/components/menu_card_component.dart';
import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key key,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textEditingController = TextEditingController();
  final _scrollController = ScrollController();

  List<Menu> _data = [];
  String _query = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      print(_scrollController.position);
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            centerTitle: false,
            pinned: true,
            titleSpacing: 0,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: Container(
              margin: EdgeInsets.only(right: 10),
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0x83EAEAEA),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(primaryColor: Colors.black54),
                child: TextField(
                  autofocus: true,
                  controller: _textEditingController,
                  maxLines: 1,
                  onChanged: (text) {
                    if (text.length > 2) {
                      _search(text);
                    } else {
                      setState(() {
                        _data = [];
                      });
                    }
                    setState(() {
                      _query = text;
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.search),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 25,
                      minHeight: 25,
                    ),
                    hintText: "Cari makanan enak",
                    suffixIcon: _textEditingController.text.length > 0
                        ? GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              _textEditingController.clear();
                              _data = [];
                              _query = "";
                              _scrollController.animateTo(0,
                                  duration: new Duration(milliseconds: 1),
                                  curve: Curves.ease);
                            },
                            child: Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.0),
              child: _isSearching
                  ? LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.red.withOpacity(0.3),
                      valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                    )
                  : SizedBox(
                      height: 2,
                    ),
            ),
          ),
          (_data.length > 0 && _query != "")
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: _data.length,
                  ),
                )
              : (_query != "" && _query.length > 2)
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.1),
                              child: Image.asset(
                                'assets/images/empty_error.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Text(
                                "Menu yang kamu cari tidak dapat ditemukan",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  "Coba cari 'Ocha' itu minuman paling enak disini",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )
                  : SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.1),
                              child: Image.asset(
                                'assets/images/conifer-searching.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.7,
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Text(
                                  "Mau makan apa hari ini?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                            Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text(
                                  "Ketik untuk mencari menu favoritmu",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    )
        ],
      ),
    );
  }

  _search(String text) async {
    setState(() {
      _isSearching = true;
    });

    Algolia algolia = Algolia.init(
      applicationId: "K6UHN7KHKC",
      apiKey: "c2b3d0c6c50fa8d2ade43c80d4b555c8",
    );
    AlgoliaQuery query = algolia.instance.index("menus").query(text);
    AlgoliaQuerySnapshot snapshot = await query.getObjects();
    setState(() {
      _data = List<Menu>.from(snapshot.hits.map((x) => Menu.fromJson(x.data)));
      _isSearching = false;
    });
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
}

class Error extends StatelessWidget {
  final String errorMessage;
  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/fatal_error.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          Text(
            "Telah Terjadi Error",
            style: TextStyle(
                color: Colors.purple,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
            child: Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.purpleAccent),
            ),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}
