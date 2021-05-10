import 'package:akbmobile/models/menu.dart';

class MenuResponse {
  final int currentPage;
  final int totalPage;
  final List<Menu> data;

  MenuResponse({
    this.currentPage,
    this.totalPage,
    this.data
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
    currentPage: json['current_page'],
    totalPage: json['last_page'],
    data: List<Menu>.from(
      json['data'].map((x) => Menu.fromJson(x))
    )
  );
}