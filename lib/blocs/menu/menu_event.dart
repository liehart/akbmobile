part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class GetMenuEvent extends MenuEvent {}

class GetMoreMenuEvent extends MenuEvent {
  final int page;

  GetMoreMenuEvent(this.page);

  @override
  List<Object> get props => [page];
}