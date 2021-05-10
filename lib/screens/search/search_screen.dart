import 'package:akbmobile/blocs/menu/menu_bloc.dart';
import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/screens/search/components/menu_card_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key key,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textEditingController = TextEditingController();
  int _selectIndex = 0;

  MenuBloc _bloc;

  List<String> selectChips = ["All", "Main Course", "Side Dish", "Drink"];

  List<Menu> _data = [];
  int _page;
  int _totalPage;

  @override
  void initState() {
    _textEditingController.addListener(() {
      setState(() {});
    });
    _bloc = MenuBloc();
    _bloc.add(GetMenuEvent());
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
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
                controller: _textEditingController,
                maxLines: 1,
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
                          },
                          child: Icon(Icons.clear),
                        )
                      : null,
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 2),
              child: Row(
                children: List.generate(selectChips.length, (index) {
                  return Container(
                    margin: EdgeInsets.only(right: 5),
                    child: ChoiceChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: _selectIndex == index
                                ? Colors.orange
                                : Colors.black12),
                      ),
                      pressElevation: 0,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      selectedColor: Colors.orange.shade50,
                      selected: _selectIndex == index,
                      label: Text(
                        selectChips[index],
                        style: TextStyle(
                            color: _selectIndex == index
                                ? Colors.orange
                                : Colors.black54),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectIndex = index;
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            preferredSize: Size.fromHeight(40.0),
          ),
        ),
        body: BlocBuilder<MenuBloc, MenuState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is MenuLoadedState ||
                  state is MenuLoadMoreLoadingState) {
                if (state is MenuLoadedState) {
                  _data = state.data;
                  _page = state.page;
                  _totalPage = state.totalPage;
                }
                return LazyLoadScrollView(
                  child: ListView(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: MenuCardComponent(
                                    imagePath: _data[index].imagePath,
                                    menuName: _data[index].name,
                                    description: _data[index].description,
                                    price: _data[index].price),
                              ),
                            ),
                          );
                        },
                      ),
                      (_page < _totalPage && state is MenuLoadedState || state is MenuLoadMoreLoadingState)
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
                  onEndOfPage: () {
                    _bloc.add(GetMoreMenuEvent(_page + 1));
                  },
                );
              } else if (state is MenuLoadingState) {
                return Center(child: CircularProgressIndicator());
              } else {
                return Error(
                  errorMessage: state.toString(),
                  onRetryPressed: () {},
                );
              }
            }));
  }
}

class Error extends StatelessWidget {
  final String errorMessage;
  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed}) : super(key: key);

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
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 10,),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10,),
          TextButton(
            child: Text(
              'Coba Lagi',
              style: TextStyle(
                color: Colors.purpleAccent
              ),
            ),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}
