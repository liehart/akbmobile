import 'package:akbmobile/api/api_helper.dart';
import 'package:akbmobile/models/menu_response.dart';

class MenuRepository {
  ApiHelper _helper = ApiHelper();

  Future<MenuResponse> getMenus(int page) async {
    final response = await _helper.get("menu?page=$page");
    return MenuResponse.fromJson(response['data']);
  }
}