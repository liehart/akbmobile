part of 'menu_bloc.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuLoadingState extends MenuState {}

class MenuLoadMoreLoadingState extends MenuState {}

class MenuLoadedEmptyState extends MenuState {}

class MenuLoadedState extends MenuState {
  final List<Menu> data;
  final int page;
  final int totalPage;

  MenuLoadedState({
    this.data,
    this.page,
    this.totalPage
  });

  @override
  List<Object> get props => [data, page, totalPage];
}

class MenuErrorState extends MenuState {
  final String message;

  MenuErrorState(this.message);

  @override
  List<Object> get props => [message];
}

class MenuNoDataState extends MenuState {}