import 'dart:async';

import 'package:akbmobile/models/menu.dart';
import 'package:akbmobile/repository/menu_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuRepository _repository = MenuRepository();
  List<Menu> _data = [];
  int _currentPage;
  int _totalPage;
  bool _isLastPage;

  MenuBloc() : super(MenuLoadingState());


  @override
  Stream<Transition<MenuEvent, MenuState>> transformEvents(
      Stream<MenuEvent> events,
      TransitionFunction<MenuEvent, MenuState> transitionFn) {
    return super.transformEvents(events.debounceTime(Duration(milliseconds: 500)), transitionFn);
  }

  @override
  Stream<MenuState> mapEventToState(
    MenuEvent event,
  ) async* {
    if (event is GetMenuEvent) {
      yield* _mapEventToState();
    } else if (event is GetMoreMenuEvent) {
      yield* _mapEventToState(event.page);
    }
  }

  Stream<MenuState> _mapEventToState([int page = 1]) async* {
    try {
      print(_isLastPage);
      print(_currentPage);
      if (state is MenuLoadedState) {
        _data = (state as MenuLoadedState).data;
        _currentPage = (state as MenuLoadedState).page;
        _totalPage = (state as MenuLoadedState).totalPage;
      }

      if (_currentPage != null) {
        yield MenuLoadMoreLoadingState();
      } else {
        yield MenuLoadingState();
      }

      if (_currentPage == null || _isLastPage == null || !_isLastPage) {
        final req = await _repository.getMenus(page);

        print(req.currentPage);
        print(req.totalPage);

        if (req.currentPage == req.totalPage) {
          _isLastPage = true;
        }

        if (req.data.isNotEmpty) {
          _data.addAll(req.data);
          _currentPage = req.currentPage;
          _totalPage = req.totalPage;
        }
      }
      yield MenuLoadedState(data: _data, page: _currentPage, totalPage: _totalPage);
    } catch (e) {
      yield MenuErrorState(e.toString());
    }
  }
}
