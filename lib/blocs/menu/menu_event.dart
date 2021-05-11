part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class GetMenuEvent extends MenuEvent {}

class GetMoreMenuEvent extends MenuEvent {
  final int page;
  final String query;
  final String category;
  final bool reset;

  GetMoreMenuEvent({this.page, this.query, this.category, this.reset});

  @override
  List<Object> get props => [page, query, category, reset];
}